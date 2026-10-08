import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tabla_provider.dart';
import '../../../core/theme/app_colors.dart';

class BeatCounterWidget extends StatelessWidget {
  const BeatCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TablaProvider>();
    final taal = provider.selectedTaal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🪘 ${taal.name}',
                style: const TextStyle(color: AppColors.tablaAmber, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Beat ${provider.currentBeatIndex + 1} / ${taal.totalBeats}',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(taal.totalBeats, (index) {
                final beat = taal.beats[index];
                final isCurrent = provider.currentBeatIndex == index;

                String accentSymbol = '';
                if (beat.isSam) {
                  accentSymbol = 'X';
                } else if (beat.isKhali) {
                  accentSymbol = 'O';
                } else {
                  accentSymbol = '${beat.division}';
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.tablaAmber
                        : (beat.isSam ? AppColors.accentMagenta.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent ? AppColors.tablaAmber : (beat.isSam ? AppColors.accentMagenta : Colors.transparent),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        beat.bol,
                        style: TextStyle(
                          color: isCurrent ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        accentSymbol,
                        style: TextStyle(
                          color: isCurrent ? Colors.black87 : AppColors.primaryCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
