import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/storage/storage_service.dart';

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

class PianoProvider extends ChangeNotifier {
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
  bool _isLearnMode = false;
  List<int> _learnSequence = [];
  int _currentLearnStep = 0;
  int _learnScore = 0;
  int _totalLearnSteps = 0;

  PianoProvider() {
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
  int get learnScore => _learnScore;
  int get totalLearnSteps => _totalLearnSteps;

  int? get targetLearnMidiNote {
    if (!_isLearnMode || _currentLearnStep >= _learnSequence.length) return null;
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
        _learnScore += 100;
        _currentLearnStep++;
        if (_currentLearnStep >= _learnSequence.length) {
          // Completed Exercise!
          _isLearnMode = false;
        }
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
  void startLearnExercise(List<int> midiSequence) {
    _isLearnMode = true;
    _learnSequence = midiSequence;
    _currentLearnStep = 0;
    _learnScore = 0;
    _totalLearnSteps = midiSequence.length;
    _selectedScale = null;
    _selectedChord = null;
    notifyListeners();
  }

  void stopLearnExercise() {
    _isLearnMode = false;
    _learnSequence.clear();
    _currentLearnStep = 0;
    notifyListeners();
  }
}
