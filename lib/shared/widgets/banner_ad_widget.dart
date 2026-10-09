import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/ads/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final ValueNotifier<bool> _adsReady = AdMobService().adsReady;

  @override
  void initState() {
    super.initState();
    // No ad is requested until consent allows it (and the SDK has started).
    _adsReady.addListener(_onAdsReadyChanged);
    if (_adsReady.value) _loadBannerAd();
  }

  void _onAdsReadyChanged() {
    if (_adsReady.value) {
      if (_bannerAd == null) _loadBannerAd();
    } else {
      // Consent withdrawn: remove the banner.
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) setState(() => _isAdLoaded = false);
    }
  }

  void _loadBannerAd() {
    final adUnitId = AdMobService.bannerAdUnitId;
    if (adUnitId.isEmpty || kIsWeb) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _adsReady.removeListener(_onAdsReadyChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); // Hide completely when offline or loading
    }

    return Container(
      color: Colors.black26,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
