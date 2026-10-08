import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';

class XylophoneProvider extends ChangeNotifier with SafeChangeNotifier {
  int? _activeKeyMidi;
  bool _useSargam = false;

  int? get activeKeyMidi => _activeKeyMidi;
  bool get useSargam => _useSargam;

  void toggleLabelMode() {
    _useSargam = !_useSargam;
    notifyListeners();
  }

  void playKey(int midi) {
    _activeKeyMidi = midi;
    AudioEngine().playXylophoneNote(midi);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (_activeKeyMidi == midi) {
        _activeKeyMidi = null;
        notifyListeners();
      }
    });
  }
}
