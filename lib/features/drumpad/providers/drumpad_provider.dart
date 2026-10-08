import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/drum_pad_model.dart';

class DrumPadProvider extends ChangeNotifier {
  int _activePadId = -1;

  int get activePadId => _activePadId;

  void triggerPad(DrumPadModel pad) {
    _activePadId = pad.id;
    AudioEngine().playDrumPad(pad.soundKey);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 120), () {
      if (_activePadId == pad.id) {
        _activePadId = -1;
        notifyListeners();
      }
    });
  }
}
