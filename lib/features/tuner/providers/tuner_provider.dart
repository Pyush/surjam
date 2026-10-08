import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/tuner_model.dart';
import '../utils/microphone_input.dart';
import '../utils/pitch_converter.dart';
import '../utils/pitch_detector.dart';

enum TunerStatus { idle, listening, permissionDenied, unavailable }

class TunerProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const int captureSampleRate = 44100;
  // Microphone audio is averaged down by 2 before analysis: plenty for notes up
  // to ~1.5 kHz and a quarter of the YIN work.
  static const int analysisSampleRate = captureSampleRate ~/ 2;
  static const int _hopSize = 1024;

  final MicrophoneInput _microphone;
  final PitchDetector _detector = const PitchDetector(sampleRate: analysisSampleRate);

  TunerPreset _selectedPreset = TunerPreset.preloadedPresets[0]; // Guitar
  late TunerTargetNote _selectedTargetNote;
  double _currentFrequency = 0.0;
  int _detectedMidi = 69;
  double _centsOffset = 0.0;
  bool _isInTune = false;
  bool _hasSignal = false;
  bool _autoSelectTarget = true;
  TunerStatus _status = TunerStatus.idle;
  bool _resumeOnForeground = false;
  bool _disposed = false;
  final List<double> _pitchHistory = [];
  final List<double> _recentPitches = [];

  StreamSubscription<Uint8List>? _audioSubscription;
  final List<double> _analysisBuffer = [];
  int? _pendingByte;
  double? _pendingSample;

  TunerProvider({MicrophoneInput? microphone}) : _microphone = microphone ?? RecordMicrophoneInput() {
    _selectedTargetNote = _selectedPreset.targetNotes.last;
    WidgetsBinding.instance.addObserver(this);
  }

  TunerPreset get selectedPreset => _selectedPreset;
  TunerTargetNote get selectedTargetNote => _selectedTargetNote;
  double get currentFrequency => _currentFrequency;
  int get detectedMidi => _detectedMidi;
  double get centsOffset => _centsOffset;
  bool get isInTune => _isInTune;
  bool get hasSignal => _hasSignal;
  bool get autoSelectTarget => _autoSelectTarget;
  TunerStatus get status => _status;
  bool get isTuningActive => _status == TunerStatus.listening;
  List<double> get pitchHistory => List.unmodifiable(_pitchHistory);

  void setPreset(TunerPreset preset) {
    _selectedPreset = preset;
    _selectedTargetNote = preset.targetNotes.first;
    _autoSelectTarget = true;
    _recalculateCents();
    notifyListeners();
  }

  /// Locks the tuner to [note]; detection no longer jumps to the nearest string.
  void setTargetNote(TunerTargetNote note) {
    _selectedTargetNote = note;
    _autoSelectTarget = false;
    _recalculateCents();
    notifyListeners();
  }

  void setAutoSelectTarget(bool enabled) {
    _autoSelectTarget = enabled;
    notifyListeners();
  }

  void playReferenceTone() {
    AudioEngine().playPianoNote(_selectedTargetNote.midiNote);
  }

  Future<void> startListening() async {
    if (_status == TunerStatus.listening) return;

    final bool granted;
    try {
      granted = await _microphone.requestPermission();
    } catch (_) {
      _status = TunerStatus.unavailable;
      notifyListeners();
      return;
    }
    if (!granted) {
      _status = TunerStatus.permissionDenied;
      notifyListeners();
      return;
    }

    try {
      final stream = await _microphone.start(captureSampleRate);
      _resetAnalysis();
      _audioSubscription = stream.listen(addPcm16Audio, onError: (_) => stopListening());
      _status = TunerStatus.listening;
    } catch (_) {
      _status = TunerStatus.unavailable;
    }
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    if (_status == TunerStatus.listening) {
      try {
        await _microphone.stop();
      } catch (_) {}
      _status = TunerStatus.idle;
    }
    _hasSignal = false;
    _resetAnalysis();
    notifyListeners();
  }

  /// Feeds mono 16-bit little-endian PCM captured at [captureSampleRate].
  /// Chunks may split samples or sample pairs at any byte boundary.
  void addPcm16Audio(Uint8List bytes) {
    int index = 0;
    if (_pendingByte != null && bytes.isNotEmpty) {
      _addCapturedSample(_pcm16ToDouble(_pendingByte!, bytes[0]));
      _pendingByte = null;
      index = 1;
    }
    for (; index + 1 < bytes.length; index += 2) {
      _addCapturedSample(_pcm16ToDouble(bytes[index], bytes[index + 1]));
    }
    if (index < bytes.length) _pendingByte = bytes[index];

    final int frameSize = _detector.frameSize;
    while (_analysisBuffer.length >= frameSize) {
      final double? pitch = _detector.detect(Float64List.fromList(_analysisBuffer.sublist(0, frameSize)));
      _analysisBuffer.removeRange(0, _hopSize);
      if (pitch != null) {
        onPitchDetected(pitch);
      } else if (_hasSignal) {
        _hasSignal = false;
        _recentPitches.clear();
        notifyListeners();
      }
    }
  }

  /// Updates the meter for a detected pitch, smoothed over the last three detections.
  @visibleForTesting
  void onPitchDetected(double frequency) {
    if (frequency <= 0) return;

    _recentPitches.add(frequency);
    if (_recentPitches.length > 3) _recentPitches.removeAt(0);
    final sorted = List.of(_recentPitches)..sort();
    final double smoothed = sorted[sorted.length ~/ 2];

    if (_autoSelectTarget) {
      _selectedTargetNote = _nearestTargetNote(smoothed);
    }

    _currentFrequency = smoothed;
    _detectedMidi = PitchConverter.frequencyToMidi(smoothed);
    _hasSignal = true;
    _recalculateCents();

    _pitchHistory.add(smoothed);
    if (_pitchHistory.length > 30) {
      _pitchHistory.removeAt(0);
    }
    notifyListeners();
  }

  TunerTargetNote _nearestTargetNote(double frequency) {
    TunerTargetNote nearest = _selectedPreset.targetNotes.first;
    double nearestDistance = double.infinity;
    for (final note in _selectedPreset.targetNotes) {
      final double distance = PitchConverter.calculateCents(frequency, note.midiNote).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = note;
      }
    }
    return nearest;
  }

  void _recalculateCents() {
    if (!_hasSignal) {
      _centsOffset = 0.0;
      _isInTune = false;
      return;
    }
    _centsOffset = PitchConverter.calculateCents(_currentFrequency, _selectedTargetNote.midiNote).clamp(-50.0, 50.0);
    _isInTune = _centsOffset.abs() <= 4.0;
  }

  void _addCapturedSample(double sample) {
    if (_pendingSample == null) {
      _pendingSample = sample;
    } else {
      _analysisBuffer.add((_pendingSample! + sample) / 2);
      _pendingSample = null;
    }
  }

  static double _pcm16ToDouble(int low, int high) {
    int value = low | (high << 8);
    if (value >= 0x8000) value -= 0x10000;
    return value / 32768.0;
  }

  void _resetAnalysis() {
    _analysisBuffer.clear();
    _recentPitches.clear();
    _pendingByte = null;
    _pendingSample = null;
  }

  // Release the microphone while the app is in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (_status == TunerStatus.listening) {
        _resumeOnForeground = true;
        stopListening();
      }
    } else if (state == AppLifecycleState.resumed && _resumeOnForeground) {
      _resumeOnForeground = false;
      startListening();
    }
  }

  // Permission prompts and stream start-up are async and can finish after the screen closes.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _audioSubscription?.cancel();
    if (_status == TunerStatus.listening) {
      _microphone.stop().catchError((_) {});
    }
    _microphone.dispose().catchError((_) {});
    super.dispose();
  }
}
