import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/storage/storage_service.dart';
import '../models/taal_model.dart';

class TablaStrokeEvent {
  final String bol;
  final int timestampMs;
  TablaStrokeEvent(this.bol, this.timestampMs);

  Map<String, dynamic> toJson() => {
    'bol': bol,
    'timestampMs': timestampMs,
  };
}

class TablaProvider extends ChangeNotifier {
  TaalModel _selectedTaal = TaalModel.preloadedTaals.first;
  bool _isPlayingTaal = false;
  int _bpm = 120;
  int _currentBeatIndex = 0;
  Timer? _taalTimer;

  // Active drum hit animation triggers
  bool _isDayanHit = false;
  bool _isBayanHit = false;
  String _lastBolHit = '';

  // Recording State
  bool _isRecording = false;
  DateTime? _recordStartTime;
  final List<TablaStrokeEvent> _recordedStrokes = [];

  TaalModel get selectedTaal => _selectedTaal;
  bool get isPlayingTaal => _isPlayingTaal;
  int get bpm => _bpm;
  int get currentBeatIndex => _currentBeatIndex;
  
  bool get isDayanHit => _isDayanHit;
  bool get isBayanHit => _isBayanHit;
  String get lastBolHit => _lastBolHit;

  bool get isRecording => _isRecording;
  List<TablaStrokeEvent> get recordedStrokes => List.unmodifiable(_recordedStrokes);

  void selectTaal(TaalModel taal) {
    _selectedTaal = taal;
    _currentBeatIndex = 0;
    notifyListeners();
    if (_isPlayingTaal) {
      _restartTaalTimer();
    }
  }

  void setBpm(int newBpm) {
    _bpm = newBpm.clamp(40, 280);
    notifyListeners();
    if (_isPlayingTaal) {
      _restartTaalTimer();
    }
  }

  void toggleTaalPlayer() {
    if (_isPlayingTaal) {
      stopTaalPlayer();
    } else {
      startTaalPlayer();
    }
  }

  void startTaalPlayer() {
    _isPlayingTaal = true;
    _currentBeatIndex = 0;
    notifyListeners();
    _restartTaalTimer();
  }

  void stopTaalPlayer() {
    _isPlayingTaal = false;
    _taalTimer?.cancel();
    _taalTimer = null;
    _currentBeatIndex = 0;
    notifyListeners();
  }

  void _restartTaalTimer() {
    _taalTimer?.cancel();
    int intervalMs = (60000 / _bpm).round();

    _playCurrentBeat();

    _taalTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _playCurrentBeat();
    });
  }

  void _playCurrentBeat() {
    if (_selectedTaal.beats.isEmpty) return;

    final beat = _selectedTaal.beats[_currentBeatIndex];
    triggerBol(beat.bol, isAutomated: true);

    _currentBeatIndex = (_currentBeatIndex + 1) % _selectedTaal.totalBeats;
    notifyListeners();
  }

  /// Triggers manual or automated Bol stroke
  void triggerBol(String bol, {bool isAutomated = false}) {
    _lastBolHit = bol;
    AudioEngine().playTablaBol(bol);

    // Determine drum animation triggers
    final key = bol.toLowerCase();
    if (['dha', 'dhin'].contains(key)) {
      _animateDayan();
      _animateBayan();
    } else if (['ge', 'ghe', 'ke', 'ka'].contains(key)) {
      _animateBayan();
    } else {
      _animateDayan();
    }

    if (!isAutomated && _isRecording && _recordStartTime != null) {
      int elapsed = DateTime.now().difference(_recordStartTime!).inMilliseconds;
      _recordedStrokes.add(TablaStrokeEvent(bol, elapsed));
    }

    notifyListeners();
  }

  void _animateDayan() {
    _isDayanHit = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      _isDayanHit = false;
      notifyListeners();
    });
  }

  void _animateBayan() {
    _isBayanHit = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      _isBayanHit = false;
      notifyListeners();
    });
  }

  void startRecording() {
    _isRecording = true;
    _recordStartTime = DateTime.now();
    _recordedStrokes.clear();
    notifyListeners();
  }

  Future<void> stopRecordingAndSave(String title) async {
    if (!_isRecording) return;
    _isRecording = false;

    if (_recordedStrokes.isNotEmpty) {
      final recordingData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'instrument': 'Tabla',
        'createdAt': DateTime.now().toIso8601String(),
        'durationMs': _recordedStrokes.last.timestampMs,
        'events': _recordedStrokes.map((e) => e.toJson()).toList(),
      };
      await StorageService().saveRecording(recordingData);
    }

    _recordStartTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _taalTimer?.cancel();
    super.dispose();
  }
}
