import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/core/ads/admob_service.dart';
import 'package:surjam/core/ads/interstitial_pacer.dart';
import 'package:surjam/core/recording/jam_recorder.dart';
import 'package:surjam/shared/navigation/instrument_route.dart';

void main() {
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 10, 9, 12);
    InterstitialPacer.clock = () => now;
  });
  tearDown(() {
    InterstitialPacer.clock = DateTime.now;
    debugDefaultTargetPlatformOverride = null;
    AdMobService.useTestAds = !kReleaseMode || const bool.fromEnvironment('TEST_ADS');
  });

  group('Pacing', () {
    test('Never in the first minute after opening the app', () {
      final pacer = InterstitialPacer();
      now = now.add(const Duration(seconds: 59));
      expect(pacer.mayShowNow, isFalse);
      now = now.add(const Duration(seconds: 1));
      expect(pacer.mayShowNow, isTrue);
    });

    test('At most one every three and a half minutes', () {
      final pacer = InterstitialPacer();
      now = now.add(const Duration(minutes: 2));
      pacer.recordShown();
      now = now.add(const Duration(minutes: 3, seconds: 29));
      expect(pacer.mayShowNow, isFalse);
      now = now.add(const Duration(seconds: 1));
      expect(pacer.mayShowNow, isTrue);
    });
  });

  group('When an ad may appear', () {
    final ads = AdMobService();
    setUp(() {
      ads.resetForTest();
      ads.pacer.reset();
      now = now.add(const Duration(minutes: 5));
    });

    test('Only once consent allows ads', () {
      expect(ads.mayShowInterstitialNow, isFalse);
      ads.adsReady.value = true;
      expect(ads.mayShowInterstitialNow, isTrue);
    });

    test('Never while recording', () {
      ads.adsReady.value = true;
      JamRecorder.instance.start('Piano');
      expect(ads.mayShowInterstitialNow, isFalse);
      JamRecorder.instance.discard();
      expect(ads.mayShowInterstitialNow, isTrue);
    });
  });

  test('Release builds on Android use SurJam\'s interstitial unit; iOS has none yet', () {
    AdMobService.useTestAds = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(AdMobService.interstitialAdUnitId, equals('ca-app-pub-3608911664324057/9604420982'));
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(AdMobService.interstitialAdUnitId, isEmpty);
  });

  testWidgets('Leaving an instrument screen is a break; other screens are not', (tester) async {
    var breaks = 0;
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [InstrumentBreakObserver(onBreak: () => breaks++)],
      home: const Text('home'),
    ));

    navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const Text('settings')));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(breaks, equals(0));

    navigatorKey.currentState!.push(instrumentRoute(const Text('guitar')));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(breaks, equals(1));
  });
}
