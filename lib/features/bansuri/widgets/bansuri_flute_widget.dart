import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bansuri_model.dart';
import '../providers/bansuri_provider.dart';
import '../../../core/theme/app_colors.dart';

class BansuriFluteWidget extends StatelessWidget {
  const BansuriFluteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BansuriProvider>();
    final coverages = provider.holeCoverages;

    return Column(
      children: [
        // 1. QUICK SWARA FINGERING PRESET PALETTE
        _buildSwaraPresetPalette(provider),

        const SizedBox(height: 12),

        // 2. MAIN BAMBOO BANSURI FLUTE BODY
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF16110D),
                  border: Border.all(color: const Color(0xFF4A3428), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bamboo Flute Cylinder Body (shrinks when there is little height, e.g. landscape)
                    Container(
                      height: (constraints.maxHeight - 36).clamp(40.0, 100.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFEBC176),
                            Color(0xFFC79244),
                            Color(0xFFA67129),
                            Color(0xFF7D4E15),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: provider.isPlaying
                                ? AppColors.primaryNeon.withValues(alpha: 0.5)
                                : Colors.black45,
                            blurRadius: provider.isPlaying ? 16 : 8,
                            spreadRadius: provider.isPlaying ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Red Thread Bindings (Rassi) at head, mid, tail
                          Positioned(left: 30, top: 0, bottom: 0, width: 12, child: _buildThreadBinding()),
                          Positioned(left: 120, top: 0, bottom: 0, width: 8, child: _buildThreadBinding()),
                          Positioned(right: 30, top: 0, bottom: 0, width: 12, child: _buildThreadBinding()),

                          // Blow Hole (Embouchure)
                          Positioned(
                            left: 50,
                            child: Container(
                              width: 24,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF26180D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF7F4E24), width: 2),
                                boxShadow: provider.isPlaying
                                    ? [const BoxShadow(color: AppColors.primaryNeon, blurRadius: 10)]
                                    : [],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.air,
                                  color: provider.isPlaying ? AppColors.primaryNeon : Colors.white24,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),

                          // 6 Tone Holes Row
                          Positioned(
                            left: 140,
                            right: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(6, (holeIdx) {
                                double coverage = coverages[holeIdx];
                                return Expanded(
                                  child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: GestureDetector(
                                  onTap: () => provider.toggleHoleCoverage(holeIdx),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${holeIdx + 1}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _buildHoleWidget(coverage, provider.isPlaying),
                                    ],
                                  ),
                                  ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThreadBinding() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD00000), Color(0xFF9D0208), Color(0xFF6A040F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 0.5),
      ),
    );
  }

  Widget _buildHoleWidget(double coverage, bool isPlaying) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2B1B0E),
        border: Border.all(
          color: coverage > 0.0 ? AppColors.pianoGold : const Color(0xFF5C3C20),
          width: 2,
        ),
        boxShadow: (coverage > 0.0 && isPlaying)
            ? [const BoxShadow(color: AppColors.pianoGold, blurRadius: 6)]
            : [],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Fully open base (dark interior)
            Container(color: const Color(0xFF1E130A)),

            // Covered state fill
            if (coverage == 1.0)
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF8D5B2E), Color(0xFF4E3014)],
                  ),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.pianoGold,
                  ),
                ),
              )
            else if (coverage == 0.5)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8D5B2E), Color(0xFF4E3014)],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container(color: Colors.transparent)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwaraPresetPalette(BansuriProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                Icon(Icons.touch_app, color: AppColors.pianoGold, size: 14),
                SizedBox(width: 4),
                Text(
                  'Fingering Swara Shortcuts (Tap to Play)',
                  style: TextStyle(color: AppColors.pianoGold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FingeringPattern.standardFingerings.map((pattern) {
                bool isActive = provider.activeSwaraName == pattern.swaraName;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ActionChip(
                    backgroundColor: isActive ? AppColors.pianoGold : Colors.white10,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.black : Colors.white70,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    label: Text(pattern.swaraName),
                    onPressed: () => provider.applyFingering(pattern),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
