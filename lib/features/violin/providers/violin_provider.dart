import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';

class ViolinProvider extends ChangeNotifier with SafeChangeNotifier {
  int _activeStringIndex = -1;
  int _activeMidiNote = -1;

  int get activeStringIndex => _activeStringIndex;
  int get activeMidiNote => _activeMidiNote;

  final List<int> openStrings = [55, 62, 69, 76]; // G3, D4, A4, E5

  void onFingerTap(int stringIdx, int noteOffset) {
    _activeStringIndex = stringIdx;
    _activeMidiNote = openStrings[stringIdx] + noteOffset;
    AudioEngine().playViolinNote(_activeMidiNote);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _activeStringIndex = -1;
      _activeMidiNote = -1;
      notifyListeners();
    });
  }
}
