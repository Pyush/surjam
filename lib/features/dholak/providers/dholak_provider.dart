import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/feedback/tap_feedback.dart';
import '../models/dholak_model.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';
import '../../../core/lifecycle/playback_guard.dart';

class DholakProvider extends ChangeNotifier with SafeChangeNotifier {
  DholakProvider() {
    PlaybackGuard.register(this, stopLoop);
  }

  DholakFolkPattern? _selectedPattern;
  bool _isLoopPlaying = false;
  int _currentBeatIndex = 0;
  int _bpm = 135;
  Timer? _loopTimer;
  String? _activeStrokeId;
  String? _activeHitHead; // 'treble', 'bass', 'both'

  DholakFolkPattern? get selectedPattern => _selectedPattern;
  bool get isLoopPlaying => _isLoopPlaying;
  int get currentBeatIndex => _currentBeatIndex;
  int get bpm => _bpm;
  String? get activeStrokeId => _activeStrokeId;
  String? get activeHitHead => _activeHitHead;

  void playStroke(DholakStroke stroke, {bool isAutomated = false}) {
    _activeStrokeId = stroke.id;
    if (stroke.isTreble && stroke.isBass) {
      _activeHitHead = 'both';
    } else if (stroke.isTreble) {
      _activeHitHead = 'treble';
    } else {
      _activeHitHead = 'bass';
    }

    AudioEngine().playDholakStroke(stroke.id);
    if (!isAutomated) TapFeedback.strike();
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_activeStrokeId == stroke.id) {
        _activeHitHead = null;
        notifyListeners();
      }
    });
  }

  void playStrokeById(String id, {bool isAutomated = false}) {
    final stroke = DholakStroke.allStrokes.firstWhere(
      (s) => s.id == id,
      orElse: () => DholakStroke.allStrokes.first,
    );
    playStroke(stroke, isAutomated: isAutomated);
  }

  void setPattern(DholakFolkPattern? pattern) {
    _selectedPattern = pattern;
    if (pattern != null) {
      _bpm = pattern.defaultBpm;
    }
    if (_isLoopPlaying) {
      startLoop();
    } else {
      notifyListeners();
    }
  }

  void setBpm(int newBpm) {
    _bpm = newBpm.clamp(60, 240);
    notifyListeners();
    if (_isLoopPlaying) {
      startLoop();
    }
  }

  void toggleLoop() {
    if (_isLoopPlaying) {
      stopLoop();
    } else {
      startLoop();
    }
  }

  void startLoop() {
    _loopTimer?.cancel();
    _selectedPattern ??= DholakFolkPattern.preloadedPatterns[0];
    _isLoopPlaying = true;
    _currentBeatIndex = 0;
    notifyListeners();

    int intervalMs = ((60.0 / _bpm) * 1000).toInt();
    _loopTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!_isLoopPlaying || _selectedPattern == null) return;
      final seq = _selectedPattern!.sequence;
      String strokeId = seq[_currentBeatIndex % seq.length];
      playStrokeById(strokeId, isAutomated: true);
      _currentBeatIndex = (_currentBeatIndex + 1) % seq.length;
    });
  }

  void stopLoop() {
    _isLoopPlaying = false;
    _loopTimer?.cancel();
    _loopTimer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _loopTimer?.cancel();
    super.dispose();
  }
}
