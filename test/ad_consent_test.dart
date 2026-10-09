import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/ads/ad_consent.dart';
import 'package:surjam/core/ads/admob_service.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';
import 'package:surjam/features/settings/screens/settings_screen.dart';

/// Stands in for Google's consent service.
class FakeConsent extends AdConsent {
  bool previousSession;
  bool afterForm;
  bool optionsRequired;
  bool failUpdate;
  final Completer<void> formDismissed = Completer<void>();
  int formsShown = 0;
  int privacyFormsShown = 0;
  bool afterPrivacyForm = true;

  FakeConsent({this.previousSession = false, this.afterForm = true, this.optionsRequired = false, this.failUpdate = false});

  bool _current = false;

  @override
  Future<bool> gather() async {
    if (failUpdate) throw StateError('offline');
    formsShown++;
    await formDismissed.future;
    _current = afterForm;
    return afterForm;
  }

  @override
  Future<bool> canRequestAds() async => _current || previousSession;

  @override
  Future<bool> privacyOptionsRequired() async => optionsRequired;

  @override
  Future<void> showPrivacyOptions() async {
    privacyFormsShown++;
    _current = afterPrivacyForm;
    previousSession = afterPrivacyForm;
  }
}

void main() {
  late int sdkStarts;
  final ads = AdMobService();

  setUp(() {
    sdkStarts = 0;
    ads.resetForTest();
    AdMobService.startAdsSdk = () async => sdkStarts++;
  });

  test('No ad is requested until the user answers the consent form', () async {
    final consent = FakeConsent(afterForm: true, optionsRequired: true);
    AdMobService.consent = consent;
    final init = ads.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(consent.formsShown, equals(1));
    expect(ads.adsReady.value, isFalse);
    expect(sdkStarts, equals(0));

    consent.formDismissed.complete();
    await init;
    expect(ads.adsReady.value, isTrue);
    expect(sdkStarts, equals(1));
    expect(ads.privacyOptionsRequired.value, isTrue); // Settings offers Privacy choices
  });

  test('Declining consent keeps ads off', () async {
    final consent = FakeConsent(afterForm: false, optionsRequired: true)..formDismissed.complete();
    AdMobService.consent = consent;
    await ads.initialize();
    expect(ads.adsReady.value, isFalse);
    expect(sdkStarts, equals(0));
  });

  test('Consent from an earlier session starts ads without waiting for the form', () async {
    final consent = FakeConsent(previousSession: true);
    AdMobService.consent = consent;
    final init = ads.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(ads.adsReady.value, isTrue);
    consent.formDismissed.complete();
    await init;
    expect(sdkStarts, equals(1)); // started once only
  });

  test('Outside consent regions ads start and no Privacy choices entry is shown', () async {
    AdMobService.consent = FakeConsent(afterForm: true, optionsRequired: false)..formDismissed.complete();
    await ads.initialize();
    expect(ads.adsReady.value, isTrue);
    expect(ads.privacyOptionsRequired.value, isFalse);
  });

  test('If the consent service cannot be reached, the previous choice stands', () async {
    AdMobService.consent = FakeConsent(failUpdate: true, previousSession: false);
    await ads.initialize();
    expect(ads.adsReady.value, isFalse);

    ads.resetForTest();
    AdMobService.consent = FakeConsent(failUpdate: true, previousSession: true);
    await ads.initialize();
    expect(ads.adsReady.value, isTrue);
  });

  test('Withdrawing consent in Privacy choices removes ads', () async {
    final consent = FakeConsent(afterForm: true, optionsRequired: true)..formDismissed.complete();
    AdMobService.consent = consent;
    await ads.initialize();
    expect(ads.adsReady.value, isTrue);

    consent.afterPrivacyForm = false;
    await ads.showPrivacyOptions();
    expect(consent.privacyFormsShown, equals(1));
    expect(ads.adsReady.value, isFalse);
  });

  testWidgets('Settings shows Privacy choices only where consent applies', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
    final consent = FakeConsent(afterForm: true, optionsRequired: true)..formDismissed.complete();
    AdMobService.consent = consent;

    Future<void> pumpSettings() => tester.pumpWidget(ChangeNotifierProvider(
          create: (_) => PianoProvider(),
          child: const MaterialApp(home: SettingsScreen()),
        ));

    await pumpSettings();
    expect(find.text('Privacy choices'), findsNothing);

    // What initialize() sets for a user in a consent region (covered by the tests above).
    ads.privacyOptionsRequired.value = true;
    await tester.pump();
    expect(find.text('Privacy choices'), findsOneWidget);
    await tester.tap(find.text('Privacy choices'));
    await tester.pump();
    expect(consent.privacyFormsShown, equals(1));
  });
}
