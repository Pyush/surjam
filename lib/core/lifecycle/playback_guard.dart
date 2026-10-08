import 'package:flutter/foundation.dart';

/// Stops ongoing sound (loops, sequencers, the metronome, drones, lesson demos) when the app
/// leaves the foreground, so nothing keeps playing behind a phone call or a locked screen.
///
/// Anything that plays on its own registers a stop callback while it exists.
class PlaybackGuard {
  PlaybackGuard._();

  static final Map<Object, VoidCallback> _stoppers = {};

  static void register(Object owner, VoidCallback stop) => _stoppers[owner] = stop;

  static void unregister(Object owner) => _stoppers.remove(owner);

  static void stopAll() {
    for (final stop in List.of(_stoppers.values)) {
      stop();
    }
  }
}
