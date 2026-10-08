import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/dj_looper_model.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';
import '../../../core/lifecycle/playback_guard.dart';

class DJLooperProvider extends ChangeNotifier with SafeChangeNotifier {
  DJLooperProvider() {
    PlaybackGuard.register(this, stopAll);
  }

  DJSoundPack _selectedPack = DJSoundPack.soundPacks[0]; // Electro House
  final Set<String> _activeTrackIds = {};
  int _masterBpm = 124;
  double _filterCutoff = 1.0;
  bool _isMasterPlaying = false;
  int _pulseIndex = 0;
  int _timerBpm = 124;
  Timer? _bpmPulseTimer;

  static const int pulsesPerBar = 8;

  DJSoundPack get selectedPack => _selectedPack;
  Set<String> get activeTrackIds => Set.unmodifiable(_activeTrackIds);
  int get masterBpm => _masterBpm;
  double get filterCutoff => _filterCutoff;
  bool get isMasterPlaying => _isMasterPlaying;
  int get pulseIndex => _pulseIndex;

  // Pack and tempo changes take effect at the next bar line, so loops never
  // overlap at two different tempos.
  void setSoundPack(DJSoundPack pack) {
    _selectedPack = pack;
    _masterBpm = pack.defaultBpm;
    notifyListeners();
  }

  void setMasterBpm(int bpm) {
    _masterBpm = bpm.clamp(90, 160);
    notifyListeners();
  }

  void setFilterCutoff(double value) {
    _filterCutoff = value.clamp(0.1, 1.0);
    notifyListeners();
  }

  // A track switched on while others are playing joins at the next bar line,
  // like a clip launcher.
  void toggleTrack(String trackId) {
    if (_activeTrackIds.contains(trackId)) {
      _activeTrackIds.remove(trackId);
    } else {
      _activeTrackIds.add(trackId);
    }

    if (_activeTrackIds.isNotEmpty && !_isMasterPlaying) {
      _startBpmTimer();
    } else if (_activeTrackIds.isEmpty && _isMasterPlaying) {
      stopAll();
    } else {
      notifyListeners();
    }
  }

  void stopAll() {
    _activeTrackIds.clear();
    _isMasterPlaying = false;
    _bpmPulseTimer?.cancel();
    _bpmPulseTimer = null;
    notifyListeners();
  }

  void _startBpmTimer() {
    _bpmPulseTimer?.cancel();
    _isMasterPlaying = true;
    _pulseIndex = 0;
    _playActiveTracks();
    _schedulePulseTimer();
    notifyListeners();
  }

  // 8th-note pulses; every 8th pulse is a bar line where the one-bar loops restart.
  void _schedulePulseTimer() {
    _timerBpm = _masterBpm;
    final interval = Duration(microseconds: (60e6 / _timerBpm / 2).round());
    _bpmPulseTimer = Timer.periodic(interval, (_) {
      if (!_isMasterPlaying || _activeTrackIds.isEmpty) return;

      _pulseIndex = (_pulseIndex + 1) % pulsesPerBar;
      if (_pulseIndex == 0) {
        _playActiveTracks();
        if (_timerBpm != _masterBpm) {
          _bpmPulseTimer?.cancel();
          _schedulePulseTimer();
        }
      }

      notifyListeners();
    });
  }

  void _playActiveTracks() {
    for (String trackId in _activeTrackIds) {
      AudioEngine().playDJLoopTrack(
        trackId,
        filterCutoff: _filterCutoff,
        bpm: _masterBpm,
        packId: _selectedPack.id,
      );
    }
  }

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _bpmPulseTimer?.cancel();
    super.dispose();
  }
}
