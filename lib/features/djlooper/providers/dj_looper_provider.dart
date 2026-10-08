import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/dj_looper_model.dart';

class DJLooperProvider extends ChangeNotifier {
  DJSoundPack _selectedPack = DJSoundPack.soundPacks[0]; // Electro House
  final Set<String> _activeTrackIds = {};
  int _masterBpm = 124;
  double _filterCutoff = 1.0;
  bool _isMasterPlaying = false;
  int _pulseIndex = 0;
  Timer? _bpmPulseTimer;

  DJSoundPack get selectedPack => _selectedPack;
  Set<String> get activeTrackIds => Set.unmodifiable(_activeTrackIds);
  int get masterBpm => _masterBpm;
  double get filterCutoff => _filterCutoff;
  bool get isMasterPlaying => _isMasterPlaying;
  int get pulseIndex => _pulseIndex;

  void setSoundPack(DJSoundPack pack) {
    _selectedPack = pack;
    _masterBpm = pack.defaultBpm;
    if (_isMasterPlaying) {
      _startBpmTimer();
    } else {
      notifyListeners();
    }
  }

  void setMasterBpm(int bpm) {
    _masterBpm = bpm.clamp(90, 160);
    notifyListeners();
    if (_isMasterPlaying) {
      _startBpmTimer();
    }
  }

  void setFilterCutoff(double value) {
    _filterCutoff = value.clamp(0.1, 1.0);
    notifyListeners();
  }

  void toggleTrack(String trackId) {
    if (_activeTrackIds.contains(trackId)) {
      _activeTrackIds.remove(trackId);
    } else {
      _activeTrackIds.add(trackId);
      AudioEngine().playDJLoopTrack(trackId, filterCutoff: _filterCutoff);
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
    notifyListeners();

    int intervalMs = ((60.0 / _masterBpm) * 1000 / 2).toInt(); // 8th note pulses
    _bpmPulseTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!_isMasterPlaying || _activeTrackIds.isEmpty) return;

      _pulseIndex = (_pulseIndex + 1) % 4;

      // Loop audio play on bar boundaries
      if (_pulseIndex == 0) {
        for (String trackId in _activeTrackIds) {
          AudioEngine().playDJLoopTrack(trackId, filterCutoff: _filterCutoff);
        }
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _bpmPulseTimer?.cancel();
    super.dispose();
  }
}
