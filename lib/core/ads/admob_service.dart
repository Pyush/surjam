import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _isInitialized = false;
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

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitial();
    } catch (e) {
      debugPrint('AdMob initialization handled: $e');
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
