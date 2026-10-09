import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ad consent through Google's User Messaging Platform (UMP).
///
/// Users in regions that require it (EEA, UK, Switzerland) see Google's consent form before
/// any ad is requested, and can change their choice later from Settings. Elsewhere nothing
/// is shown and ads start straight away.
///
/// The form's wording and choices are configured in the AdMob console under
/// Privacy & messaging; without a published message there, no form appears.
class AdConsent {
  /// Build with `--dart-define=UMP_TEST_DEVICE_ID=<id from logcat>` to see the form as if in
  /// the EEA on that device.
  static const String _testDeviceId = String.fromEnvironment('UMP_TEST_DEVICE_ID');

  /// Updates consent requirements, shows the form if this user must answer it, and returns
  /// whether ads may now be requested.
  Future<bool> gather() async {
    final updated = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        tagForUnderAgeOfConsent: false,
        consentDebugSettings: _testDeviceId.isEmpty
            ? null
            : ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
                testIdentifiers: [_testDeviceId],
              ),
      ),
      () => updated.complete(),
      (error) => updated.completeError(StateError('Consent update failed: ${error.message}')),
    );
    await updated.future;

    final dismissed = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
      if (formError != null) debugPrint('AdConsent: form error: ${formError.message}');
      dismissed.complete();
    });
    await dismissed.future;
    return canRequestAds();
  }

  /// True when consent is not needed or has been given (possibly in an earlier session).
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  /// Whether the user must be offered a way to revisit their choice (shown in Settings).
  Future<bool> privacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  /// Shows Google's form again so the user can change their choice.
  Future<void> showPrivacyOptions() {
    final dismissed = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) debugPrint('AdConsent: privacy options error: ${formError.message}');
      dismissed.complete();
    });
    return dismissed.future;
  }
}
