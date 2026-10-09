import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_consent.dart';
import 'interstitial_pacer.dart';
import '../recording/jam_recorder.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  /// Consent gate and ads SDK start-up; replaced in tests.
  @visibleForTesting
  static AdConsent consent = AdConsent();
  @visibleForTesting
  static Future<void> Function() startAdsSdk = () => MobileAds.instance.initialize();

  /// Keeps full-screen ads occasional.
  final InterstitialPacer pacer = InterstitialPacer();

  /// True once consent allows ads and the SDK has started. Banners wait for this.
  final ValueNotifier<bool> adsReady = ValueNotifier(false);

  /// True when Settings must offer "Privacy choices" (consent regions only).
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(false);

  Future<void>? _initialization;
  bool _isInitialized = false;

  @visibleForTesting
  void resetForTest() {
    _initialization = null;
    _isInitialized = false;
    adsReady.value = false;
    privacyOptionsRequired.value = false;
  }
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // SurJam's own AdMob IDs (Android app). They are public: every installed copy contains them.
  // The App ID itself is in android/app/src/main/AndroidManifest.xml.
  static const String _androidBannerId = 'ca-app-pub-3608911664324057/7525052556';
  static const String _androidInterstitialId = 'ca-app-pub-3608911664324057/9604420982';

  // Google's sample ad units: always filled with test ads, never paid. Used in debug builds,
  // because viewing or clicking your own real ads gets AdMob accounts suspended.
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  /// Test ads everywhere except release builds. Build with `--dart-define=TEST_ADS=true` to keep
  /// test ads in a release APK installed on your own phone.
  @visibleForTesting
  static bool useTestAds = !kReleaseMode || const bool.fromEnvironment('TEST_ADS');

  /// The real Android banner in release builds. iOS has no AdMob app yet, so release builds
  /// there show no banner rather than test ads.
  static String get bannerAdUnitId => switch (defaultTargetPlatform) {
        TargetPlatform.android => useTestAds ? _testBannerAndroid : _androidBannerId,
        TargetPlatform.iOS => useTestAds ? _testBannerIos : '',
        _ => '',
      };

  /// Full-screen ad shown occasionally when leaving an instrument (see [InterstitialPacer]).
  static String get interstitialAdUnitId => switch (defaultTargetPlatform) {
        TargetPlatform.android => useTestAds ? _testInterstitialAndroid : _androidInterstitialId,
        TargetPlatform.iOS => useTestAds ? _testInterstitialIos : '',
        _ => '',
      };

  // No real rewarded unit exists yet (the format is not used), so release builds request none.

  static String get rewardedAdUnitId => !useTestAds
      ? ''
      : switch (defaultTargetPlatform) {
          TargetPlatform.android => _testRewardedAndroid,
          TargetPlatform.iOS => _testRewardedIos,
          _ => '',
        };

  /// Gathers consent where required, then starts ads. Called once the first frame is up,
  /// because the consent form is shown over the app.
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    // Consent given in an earlier session lets ads start without waiting for the update.
    if (await _safely(consent.canRequestAds)) await _startAds();

    final bool allowed;
    try {
      allowed = await consent.gather();
    } catch (e) {
      // Offline or the service is unavailable: keep whatever the last session decided.
      debugPrint('AdMob: consent update failed, using the previous choice: $e');
      privacyOptionsRequired.value = await _safely(consent.privacyOptionsRequired);
      return;
    }
    privacyOptionsRequired.value = await _safely(consent.privacyOptionsRequired);
    if (allowed) await _startAds();
  }

  /// Lets the user change their consent from Settings, then applies the new choice.
  Future<void> showPrivacyOptions() async {
    await consent.showPrivacyOptions();
    if (await _safely(consent.canRequestAds)) {
      await _startAds();
    } else {
      adsReady.value = false;
    }
  }

  Future<void> _startAds() async {
    if (_isInitialized) {
      adsReady.value = true;
      return;
    }
    try {
      await startAdsSdk();
      _isInitialized = true;
      adsReady.value = true;
      preloadInterstitial();
    } catch (e) {
      debugPrint('AdMob initialization handled: $e');
    }
  }

  static Future<bool> _safely(Future<bool> Function() check) async {
    try {
      return await check();
    } catch (_) {
      return false;
    }
  }

  bool _interstitialLoading = false;

  void preloadInterstitial() {
    // One request at a time: breaks can come faster than an ad loads.
    if (!_isInitialized || interstitialAdUnitId.isEmpty || _interstitialLoading || _interstitialAd != null) return;
    _interstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  bool get mayShowInterstitialNow => adsReady.value && !JamRecorder.instance.isRecording && pacer.mayShowNow;

  /// Called at natural breaks (leaving an instrument screen). Shows the preloaded full-screen
  /// ad only if consent allows ads, nothing is being recorded, and the pacer agrees.
  void maybeShowInterstitialAtBreak() {
    if (!mayShowInterstitialNow) return;
    if (_interstitialAd == null) {
      preloadInterstitial();
      return;
    }
    showInterstitialIfReady();
  }

  void showInterstitialIfReady() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) => pacer.recordShown(),
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitial();
        },
      );
      _interstitialAd!.show();
    }
  }

  void showRewardedAd({required VoidCallback onRewardEarned}) {
    if (!_isInitialized || rewardedAdUnitId.isEmpty) {
      // Offline fallback: grant reward directly
      onRewardEarned();
      return;
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.show(onUserEarnedReward: (ad, item) {
            onRewardEarned();
          });
        },
        onAdFailedToLoad: (error) {
          // Grant reward if ad failed to load (e.g. offline)
          onRewardEarned();
        },
      ),
    );
  }
}
