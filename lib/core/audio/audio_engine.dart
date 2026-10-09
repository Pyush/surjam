import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../recording/jam_recorder.dart';
import '../progress/practice_tracker.dart';
import 'sound_event.dart';

/// Plays synthesized instrument sounds.
///
/// Sounds are generated once, written to a temporary WAV file and played from that file.
/// Android's low-latency mode (SoundPool) cannot play in-memory bytes, but it loads a file
/// once and keeps it in memory, so repeat taps start immediately.
class AudioEngine {
  static final AudioEngine _instance = AudioEngine._internal();
  factory AudioEngine() => _instance;
  AudioEngine._internal();

  static const int _poolSize = 16;
  final List<AudioPlayer> _players = [];
  int _currentPlayerIndex = 0;

  /// Sound key -> generated WAV file on disk.
  final Map<String, String> _soundFiles = {};
  final Map<String, Future<String?>> _pendingSoundFiles = {};
  Future<Directory>? _soundDirectory;

  String? _djLoopCacheContext;
  // Held sounds (drone, shehnai): two players per channel so a new note can start while the
  // previous one fades out.
  final Map<String, List<AudioPlayer>> _holdPlayers = {};
  final Map<String, int> _holdActive = {};
  final Map<AudioPlayer, int> _holdGeneration = {};

  Future<void>? _initialization;

  /// Where generated sounds are written. Tests point this at a scratch directory.
  @visibleForTesting
  static Future<Directory> Function() baseDirectoryProvider = getTemporaryDirectory;

  /// Safe to call many times; work happens once. Not awaited at startup so the first frame
  /// is not held up by creating players.
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioMode: AndroidAudioMode.normal,
          ),
        ),
      );
    } catch (e) {
      debugPrint('AudioEngine: audio context not set: $e');
    }

    final players = await Future.wait(List.generate(_poolSize, (_) async {
      final player = AudioPlayer();
      try {
        await player.setPlayerMode(PlayerMode.lowLatency);
      } catch (e) {
        debugPrint('AudioEngine: low-latency mode unavailable: $e');
      }
      return player;
    }));
    _players.addAll(players);
  }

  /// Plays [sound], and adds it to the recording if one is running.
  Future<void> play(SoundEvent sound) {
    JamRecorder.instance.capture(sound);
    PracticeTracker.instance.onSoundPlayed();
    return playWithoutRecording(sound);
  }

  /// Plays [sound] without recording it: metronome clicks and replays of saved recordings.
  Future<void> playWithoutRecording(SoundEvent sound) {
    if (sound.isHoldStart) return _startHold(sound);
    if (sound.isHoldStop) return _stopHold(sound.holdChannel!);
    if (sound.type == SoundType.djLoop) {
      // Loops are one bar long, so a BPM or pack change makes every generated loop obsolete.
      final context = '${sound.kit}_${sound.bpm}';
      if (context != _djLoopCacheContext) {
        _forgetSounds('dj_');
        _djLoopCacheContext = context;
      }
    }
    return _play(sound.cacheKey, sound.generate);
  }

  Future<void> playPianoNote(int midiNote) => play(SoundEvent.note(SoundType.piano, midiNote));

  Future<void> playFluteNote(int midiNote, {double vibratoAmount = 0.0}) =>
      play(SoundEvent.flute(midiNote, vibrato: vibratoAmount));

  Future<void> playUkuleleNote(int midiNote) => play(SoundEvent.note(SoundType.ukulele, midiNote));

  Future<void> playXylophoneNote(int midiNote) => play(SoundEvent.note(SoundType.xylophone, midiNote));

  Future<void> playSitarNote(int midiNote, {int bendSemitones = 0}) =>
      play(SoundEvent.note(SoundType.sitar, midiNote + bendSemitones));

  Future<void> playGuitarNote(int midiNote) => play(SoundEvent.note(SoundType.guitar, midiNote));

  Future<void> playHarmoniumNote(int midiNote) => play(SoundEvent.note(SoundType.harmonium, midiNote));

  Future<void> playViolinNote(int midiNote) => play(SoundEvent.note(SoundType.violin, midiNote));

  Future<void> playSantoorNote(int midiNote) => play(SoundEvent.note(SoundType.santoor, midiNote));

  Future<void> playVeenaNote(int midiNote) => play(SoundEvent.note(SoundType.veena, midiNote));

  Future<void> playDrumPad(String padType, {String kit = 'classic'}) => play(SoundEvent.drum(padType, kit: kit));

  Future<void> playTablaBol(String bol) => play(SoundEvent.tabla(bol));

  Future<void> playDholakStroke(String stroke) => play(SoundEvent.dholak(stroke));

  Future<void> playDJLoopTrack(String trackId, {double filterCutoff = 1.0, int bpm = 124, String packId = 'electro_house'}) =>
      play(SoundEvent.djLoop(trackId, filterCutoff: filterCutoff, bpm: bpm, pack: packId));

  /// Starts a continuous, looping drone on [midiNote], replacing any drone already playing.
  /// It uses its own player so keyboard notes never cut it off.
  Future<void> startDrone(int midiNote) => play(SoundEvent.droneStart(midiNote));

  Future<void> stopDrone() => play(SoundEvent.droneStopEvent);

  /// Starts holding a shehnai note until [stopShehnai] or the next note, which glides in.
  Future<void> startShehnai(int midiNote, {bool vibrato = true}) =>
      play(SoundEvent.shehnaiStart(midiNote, vibrato: vibrato));

  Future<void> stopShehnai() => play(SoundEvent.shehnaiStopEvent);

  /// Stops every held sound: used when replaying a recording ends.
  Future<void> stopAllHolds() async {
    for (final channel in List.of(_holdPlayers.keys)) {
      await _stopHold(channel);
    }
  }

  Future<void> _startHold(SoundEvent sound) async {
    final path = await _soundFile(sound.cacheKey, sound.generate);
    if (path == null) return;
    final channel = sound.holdChannel!;
    final players = _holdPlayers.putIfAbsent(channel, () => [AudioPlayer(), AudioPlayer()]);
    final previous = _holdActive[channel];
    final next = previous == null ? 0 : 1 - previous;
    _holdActive[channel] = next;
    final player = players[next];
    final generation = (_holdGeneration[player] ?? 0) + 1;
    _holdGeneration[player] = generation;
    try {
      await player.stop();
      await player.setVolume(1);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(DeviceFileSource(path));
    } catch (e) {
      debugPrint('AudioEngine: held sound failed: $e');
    }
    if (previous != null) _fadeOut(players[previous]);
  }

  Future<void> _stopHold(String channel) async {
    final active = _holdActive.remove(channel);
    final players = _holdPlayers[channel];
    if (active == null || players == null) return;
    await _fadeOut(players[active]);
  }

  /// A quick fade instead of an abrupt stop, which would click. Gives up if the player is
  /// reused for a new note mid-fade.
  Future<void> _fadeOut(AudioPlayer player) async {
    final generation = _holdGeneration[player];
    try {
      for (final volume in const [0.55, 0.25]) {
        await player.setVolume(volume);
        await Future<void>.delayed(const Duration(milliseconds: 25));
        if (_holdGeneration[player] != generation) return;
      }
      await player.stop();
      await player.setVolume(1);
    } catch (_) {}
  }

  /// Metronome tick. Never recorded, so it does not end up in jams.
  Future<void> playClick({bool isAccent = false}) =>
      playWithoutRecording(SoundEvent.tabla(isAccent ? 'na' : 'ke'));

  Future<void> _play(String key, Uint8List Function() generate) async {
    await initialize();
    final path = await _soundFile(key, generate);
    if (path == null || _players.isEmpty) return;

    final player = _players[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;

    try {
      await player.stop();
      await player.play(DeviceFileSource(path));
    } catch (e) {
      debugPrint('AudioEngine: could not play $key: $e');
    }
  }

  /// Path of the WAV file for [key], generating and writing it on first use.
  /// Concurrent requests for the same sound share one write.
  Future<String?> _soundFile(String key, Uint8List Function() generate) {
    final existing = _soundFiles[key];
    if (existing != null) return Future.value(existing);
    // Block body: returning the removed Future from whenComplete would make it wait on itself.
    return _pendingSoundFiles[key] ??= _writeSoundFile(key, generate).whenComplete(() {
      _pendingSoundFiles.remove(key);
    });
  }

  Future<String?> _writeSoundFile(String key, Uint8List Function() generate) async {
    try {
      return await _storeSoundFile(key, generate());
    } catch (e) {
      debugPrint('AudioEngine: could not prepare $key: $e');
      return null;
    }
  }

  Future<String> _storeSoundFile(String key, Uint8List bytes) async {
    final directory = await (_soundDirectory ??= _prepareSoundDirectory());
    final file = File('${directory.path}/$key.wav');
    await file.writeAsBytes(bytes, flush: true);
    _soundFiles[key] = file.path;
    return file.path;
  }

  /// Generates [sounds] ahead of time on a background isolate, so the first tap on each one
  /// starts instantly and generation never blocks the UI. Already-prepared sounds are skipped.
  Future<void> preload(Iterable<SoundEvent> sounds) async {
    final missing = {
      for (final sound in sounds)
        if (!sound.isHoldStop && !_soundFiles.containsKey(sound.cacheKey)) sound.cacheKey: sound,
    }.values.toList();
    if (missing.isEmpty) return;
    try {
      final generated = await Isolate.run(() => [for (final sound in missing) sound.generate()]);
      for (int i = 0; i < missing.length; i++) {
        if (!_soundFiles.containsKey(missing[i].cacheKey)) {
          await _storeSoundFile(missing[i].cacheKey, generated[i]);
        }
      }
    } catch (e) {
      debugPrint('AudioEngine: preload failed: $e');
    }
  }

  /// A fresh directory each launch, so sounds always match the current synthesizer.
  Future<Directory> _prepareSoundDirectory() async {
    final base = await baseDirectoryProvider();
    final directory = Directory('${base.path}/surjam_sounds');
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    return directory.create(recursive: true);
  }

  void _forgetSounds(String keyPrefix) {
    final keys = _soundFiles.keys.where((k) => k.startsWith(keyPrefix)).toList();
    for (final key in keys) {
      final path = _soundFiles.remove(key)!;
      File(path).delete().catchError((_) => File(path));
    }
  }

  void dispose() {
    for (final player in _players) {
      player.dispose();
    }
    _players.clear();
    for (final players in _holdPlayers.values) {
      for (final player in players) {
        player.dispose();
      }
    }
    _holdPlayers.clear();
    _holdActive.clear();
    _initialization = null;
  }
}
