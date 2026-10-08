import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'sound_synthesizer.dart';

class AudioEngine {
  static final AudioEngine _instance = AudioEngine._internal();
  factory AudioEngine() => _instance;
  AudioEngine._internal();

  static const int _poolSize = 16;
  final List<AudioPlayer> _players = [];
  int _currentPlayerIndex = 0;

  final Map<int, Uint8List> _pianoCache = {};
  final Map<int, Uint8List> _fluteCache = {};
  final Map<int, Uint8List> _guitarCache = {};
  final Map<int, Uint8List> _ukuleleCache = {};
  final Map<int, Uint8List> _xylophoneCache = {};
  final Map<int, Uint8List> _sitarCache = {};
  final Map<int, Uint8List> _harmoniumCache = {};
  final Map<int, Uint8List> _violinCache = {};
  final Map<String, Uint8List> _drumPadCache = {};
  final Map<String, Uint8List> _tablaCache = {};
  final Map<String, Uint8List> _dholakCache = {};
  final Map<String, Uint8List> _djLoopCache = {};
  String? _djLoopCacheContext;
  final Map<int, Uint8List> _droneCache = {};
  AudioPlayer? _dronePlayer;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioMode: AndroidAudioMode.normal,
          ),
        ),
      );
    } catch (_) {}

    try {
      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        _players.add(player);
      }
    } catch (_) {}

    _isInitialized = true;
  }

  Future<void> playPianoNote(int midiNote) async {
    if (!_isInitialized) await initialize();
    Uint8List? bytes = _pianoCache[midiNote];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(midiNote);
      bytes = SoundSynthesizer.generatePianoWav(freq);
      _pianoCache[midiNote] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playFluteNote(int midiNote, {double vibratoAmount = 0.0}) async {
    if (!_isInitialized) await initialize();
    Uint8List? bytes = _fluteCache[midiNote];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(midiNote);
      bytes = SoundSynthesizer.generateFluteWav(freq, vibratoAmount: vibratoAmount);
      _fluteCache[midiNote] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playUkuleleNote(int midiNote) async {
    if (!_isInitialized) await initialize();
    Uint8List? bytes = _ukuleleCache[midiNote];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(midiNote);
      bytes = SoundSynthesizer.generateUkuleleWav(freq);
      _ukuleleCache[midiNote] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playXylophoneNote(int midiNote) async {
    if (!_isInitialized) await initialize();
    Uint8List? bytes = _xylophoneCache[midiNote];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(midiNote);
      bytes = SoundSynthesizer.generateXylophoneWav(freq);
      _xylophoneCache[midiNote] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playSitarNote(int midiNote, {int bendSemitones = 0}) async {
    if (!_isInitialized) await initialize();
    int targetMidi = midiNote + bendSemitones;
    Uint8List? bytes = _sitarCache[targetMidi];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(targetMidi);
      bytes = SoundSynthesizer.generateSitarWav(freq);
      _sitarCache[targetMidi] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playGuitarNote(int midiNote) async {
    if (!_isInitialized) await initialize();
    Uint8List? bytes = _guitarCache[midiNote];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(midiNote);
      bytes = SoundSynthesizer.generateGuitarWav(freq);
      _guitarCache[midiNote] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playHarmoniumNote(int midiNote) async {
    if (!_isInitialized) await initialize();
    Uint8List? bytes = _harmoniumCache[midiNote];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(midiNote);
      bytes = SoundSynthesizer.generateHarmoniumWav(freq);
      _harmoniumCache[midiNote] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playViolinNote(int midiNote) async {
    if (!_isInitialized) await initialize();
    Uint8List? bytes = _violinCache[midiNote];
    if (bytes == null) {
      double freq = SoundSynthesizer.midiToFrequency(midiNote);
      bytes = SoundSynthesizer.generateViolinWav(freq);
      _violinCache[midiNote] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playDrumPad(String padType, {String kit = 'classic'}) async {
    if (!_isInitialized) await initialize();
    final key = '${kit}_${padType.toLowerCase()}';
    Uint8List? bytes = _drumPadCache[key];
    if (bytes == null) {
      bytes = SoundSynthesizer.generateDrumPadWav(padType, kit: kit);
      _drumPadCache[key] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playTablaBol(String bol) async {
    if (!_isInitialized) await initialize();
    final key = bol.toLowerCase();
    Uint8List? bytes = _tablaCache[key];
    if (bytes == null) {
      bytes = SoundSynthesizer.generateTablaBolWav(key);
      _tablaCache[key] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playDholakStroke(String stroke) async {
    if (!_isInitialized) await initialize();
    final key = stroke.toLowerCase();
    Uint8List? bytes = _dholakCache[key];
    if (bytes == null) {
      bytes = SoundSynthesizer.generateDholakWav(key);
      _dholakCache[key] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  Future<void> playDJLoopTrack(String trackId, {double filterCutoff = 1.0, int bpm = 124, String packId = 'electro_house'}) async {
    if (!_isInitialized) await initialize();
    // Loops are one bar long, so a BPM or pack change invalidates every cached loop.
    final context = '${packId}_$bpm';
    if (context != _djLoopCacheContext) {
      _djLoopCache.clear();
      _djLoopCacheContext = context;
    }
    final double roundedCutoff = (filterCutoff * 10).round() / 10;
    final key = '${trackId.toLowerCase()}_${(roundedCutoff * 10).round()}';
    Uint8List? bytes = _djLoopCache[key];
    if (bytes == null) {
      bytes = SoundSynthesizer.generateDJLoopWav(trackId, filterCutoff: roundedCutoff, bpm: bpm, packId: packId);
      _djLoopCache[key] = bytes;
    }
    await _playWavFromBytes(bytes);
  }

  /// Starts a continuous, looping drone on [midiNote], replacing any drone already playing.
  /// It uses its own player so keyboard notes never cut it off.
  Future<void> startDrone(int midiNote) async {
    Uint8List? bytes = _droneCache[midiNote];
    if (bytes == null) {
      bytes = SoundSynthesizer.generateHarmoniumDroneWav(SoundSynthesizer.midiToFrequency(midiNote));
      _droneCache[midiNote] = bytes;
    }
    try {
      final player = _dronePlayer ??= AudioPlayer();
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(BytesSource(bytes));
    } catch (_) {}
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

  Future<void> _playWavFromBytes(Uint8List bytes) async {
    if (_players.isEmpty) return;
    final player = _players[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _poolSize;

    try {
      await player.stop();
      await player.play(BytesSource(bytes));
    } catch (_) {}
  }

  void dispose() {
    for (final player in _players) {
      player.dispose();
    }
    _players.clear();
    _dronePlayer?.dispose();
    _dronePlayer = null;
    _droneCache.clear();
    _pianoCache.clear();
    _sitarCache.clear();
    _fluteCache.clear();
    _ukuleleCache.clear();
    _xylophoneCache.clear();
    _guitarCache.clear();
    _harmoniumCache.clear();
    _violinCache.clear();
    _drumPadCache.clear();
    _tablaCache.clear();
    _dholakCache.clear();
    _djLoopCache.clear();
  }
}
