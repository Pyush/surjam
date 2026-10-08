import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/bansuri_model.dart';

class BansuriProvider extends ChangeNotifier {
  BansuriPreset _selectedPreset = BansuriPreset.preloadedPresets[0]; // C Natural
  List<double> _holeCoverages = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]; // All closed = Sa
  int _octaveRegister = 1; // 0: Mandra (-12), 1: Madhya (0), 2: Taar (+12)
  double _breathPressure = 0.8;
  double _vibratoAmount = 0.0;
  String _activeSwaraName = 'Sa';
  int _activeMidiNote = 60;
  bool _isPlaying = false;
  Timer? _playingTimer;

  BansuriPreset get selectedPreset => _selectedPreset;
  List<double> get holeCoverages => List.unmodifiable(_holeCoverages);
  int get octaveRegister => _octaveRegister;
  double get breathPressure => _breathPressure;
  double get vibratoAmount => _vibratoAmount;
  String get activeSwaraName => _activeSwaraName;
  int get activeMidiNote => _activeMidiNote;
  bool get isPlaying => _isPlaying;

  void setPreset(BansuriPreset preset) {
    _selectedPreset = preset;
    _recalculateAndPlayNote();
  }

  void setRegister(int reg) {
    _octaveRegister = reg.clamp(0, 2);
    _recalculateAndPlayNote();
  }

  void toggleHoleCoverage(int holeIndex) {
    if (holeIndex < 0 || holeIndex >= 6) return;
    // Cycle: 1.0 (Closed) -> 0.5 (Half) -> 0.0 (Open) -> 1.0
    double current = _holeCoverages[holeIndex];
    if (current == 1.0) {
      _holeCoverages[holeIndex] = 0.5;
    } else if (current == 0.5) {
      _holeCoverages[holeIndex] = 0.0;
    } else {
      _holeCoverages[holeIndex] = 1.0;
    }
    _recalculateAndPlayNote();
  }

  void setHoleCoverage(int holeIndex, double coverage) {
    if (holeIndex < 0 || holeIndex >= 6) return;
    _holeCoverages[holeIndex] = coverage.clamp(0.0, 1.0);
    _recalculateAndPlayNote();
  }

  void applyFingering(FingeringPattern pattern) {
    _holeCoverages = List.from(pattern.holeCoverages);
    _recalculateAndPlayNote();
  }

  void setVibratoAmount(double amount) {
    _vibratoAmount = amount.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setBreathPressure(double p) {
    _breathPressure = p.clamp(0.1, 1.0);
    notifyListeners();
  }

  void _recalculateAndPlayNote() {
    // Determine semitone offset based on hole coverages
    int semitones = 0;
    String swara = 'Sa';

    // Find best matching fingering pattern or calculate approximation
    double closedCount = _holeCoverages.reduce((a, b) => a + b);
    // closedCount ranges from 0.0 (all open = Ni) to 6.0 (all closed = Sa)
    if (closedCount >= 5.8) {
      semitones = 0; swara = 'Sa';
    } else if (closedCount >= 5.2) {
      semitones = 1; swara = 're';
    } else if (closedCount >= 4.8) {
      semitones = 2; swara = 'Re';
    } else if (closedCount >= 4.2) {
      semitones = 3; swara = 'ga';
    } else if (closedCount >= 3.8) {
      semitones = 4; swara = 'Ga';
    } else if (closedCount >= 2.8) {
      semitones = 5; swara = 'Ma';
    } else if (closedCount >= 2.2) {
      semitones = 6; swara = 'MA';
    } else if (closedCount >= 1.8) {
      semitones = 7; swara = 'Pa';
    } else if (closedCount >= 1.2) {
      semitones = 8; swara = 'dha';
    } else if (closedCount >= 0.8) {
      semitones = 9; swara = 'Dha';
    } else if (closedCount >= 0.3) {
      semitones = 10; swara = 'ni';
    } else {
      semitones = 11; swara = 'Ni';
    }

    int registerOffset = (_octaveRegister - 1) * 12;
    _activeMidiNote = _selectedPreset.rootMidi + semitones + registerOffset;
    _activeSwaraName = swara;
    _isPlaying = true;

    AudioEngine().playFluteNote(_activeMidiNote, vibratoAmount: _vibratoAmount);
    notifyListeners();

    _playingTimer?.cancel();
    _playingTimer = Timer(const Duration(milliseconds: 350), () {
      _isPlaying = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _playingTimer?.cancel();
    super.dispose();
  }
}
