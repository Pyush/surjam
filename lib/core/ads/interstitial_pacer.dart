import 'package:flutter/foundation.dart';

/// Decides when a full-screen ad may appear, so ads stay occasional and never interrupt playing.
///
/// Rules: not in the first minute after the app opens, and at most one every few minutes.
/// The caller only asks at natural breaks (leaving an instrument screen).
class InterstitialPacer {
  static const Duration quietAfterLaunch = Duration(minutes: 1);
  static const Duration minimumGap = Duration(minutes: 3, seconds: 30);

  /// Replaced in tests to control time.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  DateTime _launchedAt = clock();
  DateTime? _lastShownAt;

  bool get mayShowNow {
    final now = clock();
    if (now.difference(_launchedAt) < quietAfterLaunch) return false;
    final last = _lastShownAt;
    return last == null || now.difference(last) >= minimumGap;
  }

  void recordShown() => _lastShownAt = clock();

  @visibleForTesting
  void reset() {
    _launchedAt = clock();
    _lastShownAt = null;
  }
}
