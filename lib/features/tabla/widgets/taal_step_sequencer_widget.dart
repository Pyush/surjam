import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tabla_provider.dart';
import '../../../core/theme/app_colors.dart';

class TaalStepSequencerWidget extends StatelessWidget {
  const TaalStepSequencerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TablaProvider>();
    final taal = provider.selectedTaal;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Header: Taal Name & Speed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.blur_on_rounded, color: AppColors.tablaAmber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    taal.name,
                    style: const TextStyle(color: AppColors.tablaAmber, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${provider.bpm} BPM',
                  style: const TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 16-Step LED Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(taal.totalBeats, (index) {
                final beat = taal.beats[index];
                final isCurrent = provider.currentBeatIndex == index;

                String accentTag = beat.isSam ? 'X' : (beat.isKhali ? 'O' : '${beat.division}');
                Color accentColor = beat.isSam
                    ? AppColors.pianoGold
                    : (beat.isKhali ? AppColors.accentMagenta : AppColors.primaryCyan);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? accentColor
                        : (beat.isSam
                            ? AppColors.pianoGold.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isCurrent
                        ? [BoxShadow(color: accentColor.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2)]
                        : null,
                    border: Border.all(
                      color: isCurrent ? Colors.white : (beat.isSam ? AppColors.pianoGold : Colors.transparent),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Bol Text
                      Text(
                        beat.bol,
                        style: TextStyle(
                          color: isCurrent ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // LED Accent Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.black26 : accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          accentTag,
                          style: TextStyle(
                            color: isCurrent ? Colors.black : accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
