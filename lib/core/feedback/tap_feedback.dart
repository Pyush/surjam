import 'package:flutter/services.dart';
import '../storage/storage_service.dart';

/// Light vibration when the player strikes a drum, so pads feel like real surfaces.
/// Only for direct taps; automated playback (loops, sequencers) stays silent.
class TapFeedback {
  static void strike() {
    if (StorageService().getHapticsEnabled()) {
      HapticFeedback.lightImpact();
    }
  }
}
