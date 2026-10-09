import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_consent.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  /// Consent gate and ads SDK start-up; replaced in tests.
  @visibleForTesting
  static AdConsent consent = AdConsent();
  @visibleForTesting
  static Future<void> Function() startAdsSdk = () => MobileAds.instance.initialize();

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

  // Google Standard Test Unit IDs for safety during dev & testing
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android Banner Test ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } {
      return '';
    }
  }

  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android Interstitial Test ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS Interstitial Test ID
    } {
      return '';
    }
  }

  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android Rewarded Test ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS Rewarded Test ID
    } {
      return '';
    }
  }

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
      // Interstitials are not shown anywhere yet; preloading one would only waste requests
      // and lower the show rate AdMob reports. Call preloadInterstitial() when they are used.
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

  void preloadInterstitial() {
    if (!_isInitialized || interstitialAdUnitId.isEmpty) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialIfReady() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
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
