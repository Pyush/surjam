import 'dart:async';
import 'package:flutter/foundation.dart';
import 'audio_engine.dart';
import '../lifecycle/safe_change_notifier.dart';
import '../lifecycle/playback_guard.dart';

class MetronomeService extends ChangeNotifier with SafeChangeNotifier {
  MetronomeService() {
    PlaybackGuard.register(this, stop);
  }

  Timer? _timer;
  bool _isPlaying = false;
  int _bpm = 120;
  int _beatsPerMeasure = 4;
  int _currentBeat = 0; // 0-indexed

  bool get isPlaying => _isPlaying;
  int get bpm => _bpm;
  int get beatsPerMeasure => _beatsPerMeasure;
  int get currentBeat => _currentBeat;

  void setBpm(int newBpm) {
    _bpm = newBpm.clamp(30, 300);
    notifyListeners();
    if (_isPlaying) {
      _restartTimer();
    }
  }

  void setBeatsPerMeasure(int beats) {
    _beatsPerMeasure = beats.clamp(1, 16);
    _currentBeat = 0;
    notifyListeners();
  }

  void start() {
    if (_isPlaying) return;
    _isPlaying = true;
    _currentBeat = 0;
    notifyListeners();
    _restartTimer();
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    _currentBeat = 0;
    notifyListeners();
  }

  void toggle() {
    if (_isPlaying) {
      stop();
    } else {
      start();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    int intervalMs = (60000 / _bpm).round();

    // Fire first beat immediately
    _onTick();

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _onTick();
    });
  }

  void _onTick() {
    bool isAccent = (_currentBeat == 0);
    AudioEngine().playClick(isAccent: isAccent);
    
    notifyListeners();
    _currentBeat = (_currentBeat + 1) % _beatsPerMeasure;
  }

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _timer?.cancel();
    super.dispose();
  }
}
