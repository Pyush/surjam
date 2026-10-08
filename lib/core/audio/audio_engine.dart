import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'sound_synthesizer.dart';

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
  AudioPlayer? _dronePlayer;

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

  Future<void> playPianoNote(int midiNote) => _play(
        'piano_$midiNote',
        () => SoundSynthesizer.generatePianoWav(SoundSynthesizer.midiToFrequency(midiNote)),
      );

  Future<void> playFluteNote(int midiNote, {double vibratoAmount = 0.0}) {
    // Vibrato changes the waveform, so it is part of the key (in 10% steps).
    final vibratoStep = (vibratoAmount.clamp(0.0, 1.0) * 10).round();
    return _play(
      'flute_${midiNote}_v$vibratoStep',
      () => SoundSynthesizer.generateFluteWav(SoundSynthesizer.midiToFrequency(midiNote), vibratoAmount: vibratoStep / 10),
    );
  }

  Future<void> playUkuleleNote(int midiNote) => _play(
        'ukulele_$midiNote',
        () => SoundSynthesizer.generateUkuleleWav(SoundSynthesizer.midiToFrequency(midiNote)),
      );

  Future<void> playXylophoneNote(int midiNote) => _play(
        'xylophone_$midiNote',
        () => SoundSynthesizer.generateXylophoneWav(SoundSynthesizer.midiToFrequency(midiNote)),
      );

  Future<void> playSitarNote(int midiNote, {int bendSemitones = 0}) {
    final targetMidi = midiNote + bendSemitones;
    return _play(
      'sitar_$targetMidi',
      () => SoundSynthesizer.generateSitarWav(SoundSynthesizer.midiToFrequency(targetMidi)),
    );
  }

  Future<void> playGuitarNote(int midiNote) => _play(
        'guitar_$midiNote',
        () => SoundSynthesizer.generateGuitarWav(SoundSynthesizer.midiToFrequency(midiNote)),
      );

  Future<void> playHarmoniumNote(int midiNote) => _play(
        'harmonium_$midiNote',
        () => SoundSynthesizer.generateHarmoniumWav(SoundSynthesizer.midiToFrequency(midiNote)),
      );

  Future<void> playViolinNote(int midiNote) => _play(
        'violin_$midiNote',
        () => SoundSynthesizer.generateViolinWav(SoundSynthesizer.midiToFrequency(midiNote)),
      );

  Future<void> playDrumPad(String padType, {String kit = 'classic'}) => _play(
        'drum_${kit}_${padType.toLowerCase()}',
        () => SoundSynthesizer.generateDrumPadWav(padType, kit: kit),
      );

  Future<void> playTablaBol(String bol) {
    final key = bol.toLowerCase();
    return _play('tabla_$key', () => SoundSynthesizer.generateTablaBolWav(key));
  }

  Future<void> playDholakStroke(String stroke) {
    final key = stroke.toLowerCase();
    return _play('dholak_$key', () => SoundSynthesizer.generateDholakWav(key));
  }

  Future<void> playDJLoopTrack(String trackId, {double filterCutoff = 1.0, int bpm = 124, String packId = 'electro_house'}) {
    // Loops are one bar long, so a BPM or pack change makes every generated loop obsolete.
    final context = '${packId}_$bpm';
    if (context != _djLoopCacheContext) {
      _forgetSounds('dj_');
      _djLoopCacheContext = context;
    }
    final double roundedCutoff = (filterCutoff * 10).round() / 10;
    return _play(
      'dj_${context}_${trackId.toLowerCase()}_${(roundedCutoff * 10).round()}',
      () => SoundSynthesizer.generateDJLoopWav(trackId, filterCutoff: roundedCutoff, bpm: bpm, packId: packId),
    );
  }

  /// Starts a continuous, looping drone on [midiNote], replacing any drone already playing.
  /// It uses its own player so keyboard notes never cut it off.
  Future<void> startDrone(int midiNote) async {
    final path = await _soundFile(
      'drone_$midiNote',
      () => SoundSynthesizer.generateHarmoniumDroneWav(SoundSynthesizer.midiToFrequency(midiNote)),
    );
    if (path == null) return;
    try {
      final player = _dronePlayer ??= AudioPlayer();
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(DeviceFileSource(path));
    } catch (e) {
      debugPrint('AudioEngine: drone failed: $e');
    }
  }

  Future<void> stopDrone() async {
    try {
      await _dronePlayer?.stop();
    } catch (_) {}
  }

  Future<void> playClick({bool isAccent = false}) async {
    final key = isAccent ? 'na' : 'ke';
    await playTablaBol(key);
  }

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
      final directory = await (_soundDirectory ??= _prepareSoundDirectory());
      final file = File('${directory.path}/$key.wav');
      await file.writeAsBytes(generate(), flush: true);
      _soundFiles[key] = file.path;
      return file.path;
    } catch (e) {
      debugPrint('AudioEngine: could not prepare $key: $e');
      return null;
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
    _dronePlayer?.dispose();
    _dronePlayer = null;
    _initialization = null;
  }
}
