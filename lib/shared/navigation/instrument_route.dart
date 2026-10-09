import 'package:flutter/material.dart';
import '../../core/ads/admob_service.dart';

/// Route name for instrument screens: leaving one is a natural break for an occasional ad.
const String instrumentRouteName = 'instrument';

/// Opens an instrument screen, marked so [InstrumentBreakObserver] notices when it is left.
Route<void> instrumentRoute(Widget screen) =>
    MaterialPageRoute(settings: const RouteSettings(name: instrumentRouteName), builder: (_) => screen);

/// Offers a full-screen ad when the player leaves an instrument screen (the pacer decides
/// whether one actually appears).
class InstrumentBreakObserver extends NavigatorObserver {
  final VoidCallback onBreak;

  InstrumentBreakObserver({VoidCallback? onBreak}) : onBreak = onBreak ?? AdMobService().maybeShowInterstitialAtBreak;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == instrumentRouteName) onBreak();
  }
}
