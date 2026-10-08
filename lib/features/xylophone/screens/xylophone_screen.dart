import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/xylophone_provider.dart';
import '../widgets/xylophone_bars_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class XylophoneScreen extends StatelessWidget {
  const XylophoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => XylophoneProvider(),
      child: Consumer<XylophoneProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🎼 Rainbow Xylophone Studio'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    provider.useSargam ? Icons.translate_rounded : Icons.sort_by_alpha_rounded,
                    color: AppColors.pianoGold,
                  ),
                  tooltip: 'Toggle Note Labels (C-D-E / Sa-Re-Ga)',
                  onPressed: () => provider.toggleLabelMode(),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Header Info Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2-Octave Mallet Instrument (C4 to C6)',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            provider.useSargam ? 'Labels: Sargam (Sa-Re-Ga)' : 'Labels: English (C-D-E)',
                            style: const TextStyle(color: AppColors.pianoGold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Xylophone Surface
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: XylophoneBarsWidget(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Bottom Banner Ad
                  const BannerAdWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
