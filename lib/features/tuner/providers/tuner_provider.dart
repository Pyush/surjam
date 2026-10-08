import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/tuner_model.dart';
import '../utils/pitch_converter.dart';

class TunerProvider extends ChangeNotifier {
  TunerPreset _selectedPreset = TunerPreset.preloadedPresets[0]; // Guitar
  late TunerTargetNote _selectedTargetNote;
  double _currentFrequency = 440.0;
  int _detectedMidi = 69;
  double _centsOffset = 0.0;
  bool _isInTune = true;
  final bool _isTuningActive = true;
  final List<double> _pitchHistory = [];
  Timer? _vocalSimulationTimer;

  TunerProvider() {
    _selectedTargetNote = _selectedPreset.targetNotes.last;
    _updatePitchState(PitchConverter.midiToFrequency(_selectedTargetNote.midiNote));
  }

  TunerPreset get selectedPreset => _selectedPreset;
  TunerTargetNote get selectedTargetNote => _selectedTargetNote;
  double get currentFrequency => _currentFrequency;
  int get detectedMidi => _detectedMidi;
  double get centsOffset => _centsOffset;
  bool get isInTune => _isInTune;
  bool get isTuningActive => _isTuningActive;
  List<double> get pitchHistory => List.unmodifiable(_pitchHistory);

  void setPreset(TunerPreset preset) {
    _selectedPreset = preset;
    _selectedTargetNote = preset.targetNotes.first;
    _updatePitchState(PitchConverter.midiToFrequency(_selectedTargetNote.midiNote));
    notifyListeners();
  }

  void setTargetNote(TunerTargetNote note) {
    _selectedTargetNote = note;
    _updatePitchState(PitchConverter.midiToFrequency(note.midiNote));
    notifyListeners();
  }

  void updateFrequency(double freq) {
    if (freq <= 0) return;
    _updatePitchState(freq);
    notifyListeners();
  }

  void playReferenceTone() {
    AudioEngine().playPianoNote(_selectedTargetNote.midiNote);
  }

  void nukeCentsFlat() {
    double targetFreq = PitchConverter.midiToFrequency(_selectedTargetNote.midiNote);
    updateFrequency(targetFreq * 0.985); // -25 cents Flat
  }

  void nukeCentsSharp() {
    double targetFreq = PitchConverter.midiToFrequency(_selectedTargetNote.midiNote);
    updateFrequency(targetFreq * 1.015); // +25 cents Sharp
  }

  void setPerfectInTune() {
    double targetFreq = PitchConverter.midiToFrequency(_selectedTargetNote.midiNote);
    updateFrequency(targetFreq); // 0 cents In-Tune
  }

  void _updatePitchState(double freq) {
    _currentFrequency = freq;
    _detectedMidi = PitchConverter.frequencyToMidi(freq);
    _centsOffset = PitchConverter.calculateCents(freq, _selectedTargetNote.midiNote).clamp(-50.0, 50.0);
    _isInTune = _centsOffset.abs() <= 4.0;

    _pitchHistory.add(freq);
    if (_pitchHistory.length > 30) {
      _pitchHistory.removeAt(0);
    }
  }

  @override
  void dispose() {
    _vocalSimulationTimer?.cancel();
    super.dispose();
  }
}
