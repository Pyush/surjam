import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';

class HarmoniumProvider extends ChangeNotifier {
  int _octave = 4;
  String _activeDrone = 'none'; // 'sa', 'pa', 'dha', 'none'
  final Set<int> _activeKeys = {};

  int get octave => _octave;
  String get activeDrone => _activeDrone;
  Set<int> get activeKeys => _activeKeys;

  void setOctave(int oct) {
    _octave = oct.clamp(3, 5);
    notifyListeners();
  }

  void onKeyTap(int midi) {
    _activeKeys.add(midi);
    AudioEngine().playHarmoniumNote(midi);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 300), () {
      _activeKeys.remove(midi);
      notifyListeners();
    });
  }

  void toggleDrone(String sur) {
    if (_activeDrone == sur) {
      stopDrone();
    } else {
      startDrone(sur);
    }
  }

  void startDrone(String sur) {
    _activeDrone = sur;
    notifyListeners();

    int droneMidi = (sur == 'sa') ? 48 : (sur == 'pa' ? 55 : 57);
    AudioEngine().startDrone(droneMidi);
  }

  void stopDrone() {
    _activeDrone = 'none';
    AudioEngine().stopDrone();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_activeDrone != 'none') AudioEngine().stopDrone();
    super.dispose();
  }
}
