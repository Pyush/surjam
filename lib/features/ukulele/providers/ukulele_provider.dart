import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/ukulele_model.dart';

class UkuleleProvider extends ChangeNotifier {
  UkuleleChord _selectedChord = UkuleleChord.popularChords[0]; // C Major
  int? _activePluckedString;
  bool _isStrumming = false;

  UkuleleChord get selectedChord => _selectedChord;
  int? get activePluckedString => _activePluckedString;
  bool get isStrumming => _isStrumming;

  void selectChord(UkuleleChord chord) {
    _selectedChord = chord;
    notifyListeners();
  }

  void pluckString(int stringIndex) {
    if (stringIndex < 0 || stringIndex >= 4) return;
    _activePluckedString = stringIndex;

    final string = UkuleleString.standardStrings[stringIndex];
    int fret = _selectedChord.frets[stringIndex];
    int midi = string.baseMidi + fret;

    AudioEngine().playUkuleleNote(midi);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (_activePluckedString == stringIndex) {
        _activePluckedString = null;
        notifyListeners();
      }
    });
  }

  void strumChord() {
    _isStrumming = true;
    notifyListeners();

    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 45), () {
        pluckString(i);
        if (i == 3) {
          _isStrumming = false;
          notifyListeners();
        }
      });
    }
  }
}
