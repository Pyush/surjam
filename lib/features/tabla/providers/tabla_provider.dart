import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/feedback/tap_feedback.dart';
import '../models/taal_model.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';
import '../../../core/lifecycle/playback_guard.dart';

class TablaProvider extends ChangeNotifier with SafeChangeNotifier {
  TablaProvider() {
    PlaybackGuard.register(this, stopTaalPlayer);
  }

  TaalModel _selectedTaal = TaalModel.preloadedTaals.first;
  bool _isPlayingTaal = false;
  int _bpm = 120;
  int _currentBeatIndex = 0;
  Timer? _taalTimer;

  // Active drum hit animation triggers
  bool _isDayanHit = false;
  bool _isBayanHit = false;
  String _lastBolHit = '';


  TaalModel get selectedTaal => _selectedTaal;
  bool get isPlayingTaal => _isPlayingTaal;
  int get bpm => _bpm;
  int get currentBeatIndex => _currentBeatIndex;
  
  bool get isDayanHit => _isDayanHit;
  bool get isBayanHit => _isBayanHit;
  String get lastBolHit => _lastBolHit;


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
    if (!isAutomated) TapFeedback.strike();

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

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _taalTimer?.cancel();
    super.dispose();
  }
}
