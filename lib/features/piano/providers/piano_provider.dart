import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';
import '../../../core/lifecycle/playback_guard.dart';

class NoteEvent {
  final int midiNote;
  final int timestampMs;
  NoteEvent(this.midiNote, this.timestampMs);

  Map<String, dynamic> toJson() => {
    'midiNote': midiNote,
    'timestampMs': timestampMs,
  };

  factory NoteEvent.fromJson(Map<String, dynamic> json) =>
      NoteEvent(json['midiNote'], json['timestampMs']);
}

class PianoProvider extends ChangeNotifier with SafeChangeNotifier {
  int _octave = 4; // Default starting octave (Middle C = 60)
  bool _sustain = false;
  String _keyLabelMode = 'english'; // 'english', 'sargam', 'none'
  
  final Set<int> _activePressedKeys = {};
  
  String? _selectedScale;
  String? _selectedChord;
  
  // Recording State
  bool _isRecording = false;
  DateTime? _recordStartTime;
  final List<NoteEvent> _recordedEvents = [];

  // Learn Mode State
  static const int pointsPerCorrectNote = 100;
  static const int pointsPerWrongNote = 25;

  bool _isLearnMode = false;
  bool _isLearnComplete = false;
  String? _learnExerciseId;
  List<int> _learnSequence = [];
  int _currentLearnStep = 0;
  int _learnScore = 0;
  int _learnMistakes = 0;
  int _totalLearnSteps = 0;
  List<int>? _learnFingers;
  List<double>? _learnBeats;
  int _learnBpm = 90;

  // "Listen" demo: plays the rest of the lesson and lights each key.
  bool _isDemoPlaying = false;
  int? _demoNote;
  Timer? _demoTimer;

  PianoProvider() {
    PlaybackGuard.register(this, stopLearnDemo);
    _keyLabelMode = StorageService().getKeyLabelMode();
  }

  int get octave => _octave;
  bool get sustain => _sustain;
  String get keyLabelMode => _keyLabelMode;
  Set<int> get activePressedKeys => _activePressedKeys;
  String? get selectedScale => _selectedScale;
  String? get selectedChord => _selectedChord;
  
  bool get isRecording => _isRecording;
  List<NoteEvent> get recordedEvents => List.unmodifiable(_recordedEvents);
  
  bool get isLearnMode => _isLearnMode;
  List<int> get learnSequence => _learnSequence;
  int get currentLearnStep => _currentLearnStep;
  bool get isLearnComplete => _isLearnComplete;
  int get learnScore => _learnScore;
  int get learnMistakes => _learnMistakes;
  int get totalLearnSteps => _totalLearnSteps;
  bool get isDemoPlaying => _isDemoPlaying;
  int? get demoNote => _demoNote;

  /// Suggested right-hand finger for the next note, if the lesson has fingering.
  int? get targetLearnFinger {
    final fingers = _learnFingers;
    if (targetLearnMidiNote == null || fingers == null) return null;
    return fingers[_currentLearnStep];
  }
  int get learnBestScore =>
      _learnExerciseId == null ? 0 : StorageService().getExerciseScore(_learnExerciseId!);

  int? get targetLearnMidiNote {
    if (!_isLearnMode || _isLearnComplete || _currentLearnStep >= _learnSequence.length) return null;
    return _learnSequence[_currentLearnStep];
  }

  void setOctave(int newOctave) {
    _octave = newOctave.clamp(2, 6);
    notifyListeners();
  }

  void toggleSustain() {
    _sustain = !_sustain;
    notifyListeners();
  }

  void setKeyLabelMode(String mode) {
    _keyLabelMode = mode;
    StorageService().setKeyLabelMode(mode);
    notifyListeners();
  }

  void selectScale(String? scaleName) {
    _selectedScale = scaleName;
    _selectedChord = null;
    notifyListeners();
  }

  void selectChord(String? chordName) {
    _selectedChord = chordName;
    _selectedScale = null;
    notifyListeners();
  }

  void clearHighlights() {
    _selectedScale = null;
    _selectedChord = null;
    notifyListeners();
  }

  // Trigger Note Down
  void onNoteDown(int midiNote) {
    // The player taking over stops the demo.
    if (_isDemoPlaying) _stopDemo();
    _activePressedKeys.add(midiNote);
    AudioEngine().playPianoNote(midiNote);

    // Record Event
    if (_isRecording && _recordStartTime != null) {
      int elapsed = DateTime.now().difference(_recordStartTime!).inMilliseconds;
      _recordedEvents.add(NoteEvent(midiNote, elapsed));
    }

    // Learn Mode Step Check
    if (_isLearnMode && targetLearnMidiNote != null) {
      if (midiNote == targetLearnMidiNote) {
        _learnScore += pointsPerCorrectNote;
        _currentLearnStep++;
        if (_currentLearnStep >= _learnSequence.length) {
          _completeLearnExercise();
        }
      } else {
        _learnMistakes++;
        _learnScore = (_learnScore - pointsPerWrongNote).clamp(0, 1 << 30);
      }
    }

    notifyListeners();
  }

  // Trigger Note Up
  void onNoteUp(int midiNote) {
    if (!_sustain) {
      _activePressedKeys.remove(midiNote);
    }
    notifyListeners();
  }

  void releaseAllKeys() {
    _activePressedKeys.clear();
    notifyListeners();
  }

  // Start / Stop Recording
  void startRecording() {
    _isRecording = true;
    _recordStartTime = DateTime.now();
    _recordedEvents.clear();
    notifyListeners();
  }

  Future<void> stopRecordingAndSave(String title) async {
    if (!_isRecording) return;
    _isRecording = false;
    
    if (_recordedEvents.isNotEmpty) {
      final recordingData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'instrument': 'Piano',
        'createdAt': DateTime.now().toIso8601String(),
        'durationMs': _recordedEvents.last.timestampMs,
        'events': _recordedEvents.map((e) => e.toJson()).toList(),
      };
      await StorageService().saveRecording(recordingData);
    }
    
    _recordStartTime = null;
    notifyListeners();
  }

  // Start Learn Exercise
  void startLearnExercise(
    String exerciseId,
    List<int> midiSequence, {
    List<int>? fingers,
    List<double>? beats,
    int bpm = 90,
  }) {
    _stopDemo();
    _isLearnMode = true;
    _learnFingers = fingers == null ? null : List.of(fingers);
    _learnBeats = beats == null ? null : List.of(beats);
    _learnBpm = bpm;
    // Show the two octaves that contain the lesson, whatever octave the player left it on.
    if (midiSequence.isNotEmpty) {
      final lowest = midiSequence.reduce((a, b) => a < b ? a : b);
      _octave = ((lowest ~/ 12) - 1).clamp(2, 6);
    }
    _isLearnComplete = false;
    _learnExerciseId = exerciseId;
    _learnSequence = List.of(midiSequence);
    _currentLearnStep = 0;
    _learnScore = 0;
    _learnMistakes = 0;
    _totalLearnSteps = midiSequence.length;
    _selectedScale = null;
    _selectedChord = null;
    notifyListeners();
  }

  void restartLearnExercise() {
    if (_learnExerciseId == null) return;
    startLearnExercise(_learnExerciseId!, _learnSequence, fingers: _learnFingers, beats: _learnBeats, bpm: _learnBpm);
  }

  // The exercise stays on screen after completion so the result can be shown;
  // stopLearnExercise() dismisses it.
  void _completeLearnExercise() {
    _isLearnComplete = true;
    if (_learnExerciseId != null) {
      StorageService().saveExerciseScore(_learnExerciseId!, _learnScore);
    }
  }

  /// Plays the lesson from the current note to the end at its tempo, lighting each key,
  /// so the player can hear how it should sound. Calling it again stops the demo.
  void toggleLearnDemo() {
    if (_isDemoPlaying) {
      _stopDemo();
      notifyListeners();
      return;
    }
    if (!_isLearnMode || _isLearnComplete) return;
    _isDemoPlaying = true;
    _playDemoNote(_currentLearnStep);
  }

  void _playDemoNote(int index) {
    if (!_isDemoPlaying || index >= _learnSequence.length) {
      _stopDemo();
      notifyListeners();
      return;
    }
    final note = _learnSequence[index];
    _demoNote = note;
    AudioEngine().playPianoNote(note);
    notifyListeners();

    final beats = _learnBeats?[index] ?? 1.0;
    final duration = Duration(milliseconds: (beats * 60000 / _learnBpm).round());
    _demoTimer = Timer(duration, () => _playDemoNote(index + 1));
  }

  void stopLearnDemo() {
    if (!_isDemoPlaying) return;
    _stopDemo();
    notifyListeners();
  }

  /// The piano screen closed: stop the demo and keep an unfinished recording rather than
  /// losing it. (The provider itself lives for the whole app session.)
  Future<void> onScreenClosed() async {
    stopLearnDemo();
    if (_isRecording) {
      await stopRecordingAndSave(StorageService.autoSavedRecordingTitle('Piano jam'));
    }
  }

  void _stopDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;
    _isDemoPlaying = false;
    _demoNote = null;
  }

  void stopLearnExercise() {
    _stopDemo();
    _isLearnMode = false;
    _isLearnComplete = false;
    _learnExerciseId = null;
    _learnSequence = [];
    _currentLearnStep = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _stopDemo();
    super.dispose();
  }
}
