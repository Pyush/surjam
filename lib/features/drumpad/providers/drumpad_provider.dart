import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/feedback/tap_feedback.dart';
import '../models/drum_pad_model.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';

class DrumPadProvider extends ChangeNotifier with SafeChangeNotifier {
  int _activePadId = -1;
  DrumKit _selectedKit = DrumKit.kits.first;

  int get activePadId => _activePadId;
  DrumKit get selectedKit => _selectedKit;

  void selectKit(DrumKit kit) {
    _selectedKit = kit;
    notifyListeners();
  }

  void triggerPad(DrumPadModel pad) {
    _activePadId = pad.id;
    AudioEngine().playDrumPad(pad.soundKey, kit: _selectedKit.id);
    TapFeedback.strike();
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 120), () {
      if (_activePadId == pad.id) {
        _activePadId = -1;
        notifyListeners();
      }
    });
  }
}
