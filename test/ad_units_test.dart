import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/core/ads/admob_service.dart';

void main() {
  const realBanner = 'ca-app-pub-3608911664324057/7525052556';
  const googleTestPublisher = 'ca-app-pub-3940256099942544';

  tearDown(() {
    AdMobService.useTestAds = !kReleaseMode || const bool.fromEnvironment('TEST_ADS');
    debugDefaultTargetPlatformOverride = null;
  });

  test('Release builds on Android show SurJam\'s real banner', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AdMobService.useTestAds = false;
    expect(AdMobService.bannerAdUnitId, equals(realBanner));
  });

  test('Debug builds only ever request Google\'s test ads', () {
    AdMobService.useTestAds = true;
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      debugDefaultTargetPlatformOverride = platform;
      for (final id in [AdMobService.bannerAdUnitId, AdMobService.interstitialAdUnitId, AdMobService.rewardedAdUnitId]) {
        expect(id, startsWith(googleTestPublisher), reason: '$platform');
      }
    }
  });

  test('Release builds never ship test ads or ads without a real unit', () {
    AdMobService.useTestAds = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(AdMobService.bannerAdUnitId, isEmpty); // no iOS app in AdMob yet
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      debugDefaultTargetPlatformOverride = platform;
      expect(AdMobService.interstitialAdUnitId, isEmpty);
      expect(AdMobService.rewardedAdUnitId, isEmpty);
    }
  });

  test('Android uses SurJam\'s App ID; iOS has an App ID so the SDK cannot crash at launch', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:value="ca-app-pub-3608911664324057~7241147370"'));
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('<key>GADApplicationIdentifier</key>'));
  });
}
