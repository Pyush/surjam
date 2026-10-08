import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/guitar_chord_model.dart';

class GuitarProvider extends ChangeNotifier {
  GuitarChordModel _selectedChord = GuitarChordModel.preloadedChords.first;
  String _chordCategory = GuitarChordModel.categories.first;
  bool _isAutoStrumming = false;
  int _bpm = 100;
  Timer? _strumTimer;
  int _strumStep = 0; // Down / Up strum state

  int _pluckedStringIndex = -1;

  GuitarChordModel get selectedChord => _selectedChord;
  String get chordCategory => _chordCategory;
  List<GuitarChordModel> get chordsInCategory =>
      GuitarChordModel.preloadedChords.where((c) => c.category == _chordCategory).toList();
  bool get isAutoStrumming => _isAutoStrumming;
  int get bpm => _bpm;
  int get pluckedStringIndex => _pluckedStringIndex;

  // Changing category only filters the palette; the current chord stays selected.
  void setChordCategory(String category) {
    _chordCategory = category;
    notifyListeners();
  }

  void selectChord(GuitarChordModel chord) {
    _selectedChord = chord;
    notifyListeners();
  }

  void setBpm(int newBpm) {
    _bpm = newBpm.clamp(40, 240);
    notifyListeners();
    if (_isAutoStrumming) {
      _restartStrumTimer();
    }
  }

  void strumChord({bool isDownStrum = true}) {
    // Play notes in sequence from low string to high string (down) or vice versa (up)
    final notes = isDownStrum
        ? _selectedChord.midiNotes
        : _selectedChord.midiNotes.reversed.toList();

    for (int i = 0; i < notes.length; i++) {
      Future.delayed(Duration(milliseconds: i * 25), () {
        AudioEngine().playGuitarNote(notes[i]);
      });
    }

    _pluckedStringIndex = isDownStrum ? 0 : 5;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 200), () {
      _pluckedStringIndex = -1;
      notifyListeners();
    });
  }

  void pluckString(int stringIndex, int midiNote) {
    _pluckedStringIndex = stringIndex;
    AudioEngine().playGuitarNote(midiNote);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 200), () {
      _pluckedStringIndex = -1;
      notifyListeners();
    });
  }

  void toggleAutoStrum() {
    if (_isAutoStrumming) {
      stopAutoStrum();
    } else {
      startAutoStrum();
    }
  }

  void startAutoStrum() {
    _isAutoStrumming = true;
    _strumStep = 0;
    notifyListeners();
    _restartStrumTimer();
  }

  void stopAutoStrum() {
    _isAutoStrumming = false;
    _strumTimer?.cancel();
    _strumTimer = null;
    notifyListeners();
  }

  void _restartStrumTimer() {
    _strumTimer?.cancel();
    int intervalMs = (60000 / _bpm).round();

    _strumStepOnTick();

    _strumTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _strumStepOnTick();
    });
  }

  void _strumStepOnTick() {
    bool isDown = (_strumStep % 2 == 0);
    strumChord(isDownStrum: isDown);
    _strumStep++;
  }

  @override
  void dispose() {
    _strumTimer?.cancel();
    super.dispose();
  }
}
