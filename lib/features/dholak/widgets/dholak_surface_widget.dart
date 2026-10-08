import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dholak_model.dart';
import '../providers/dholak_provider.dart';
import '../../../core/theme/app_colors.dart';

class DholakSurfaceWidget extends StatelessWidget {
  const DholakSurfaceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DholakProvider>();
    final activeHead = provider.activeHitHead;

    return Column(
      children: [
        // 1. COMBINED STROKES PALETTE BAR (Dha, Dhin, Dhabba...)
        _buildStrokePalette(provider),

        const SizedBox(height: 10),

        // 2. MAIN DUAL-HEAD DHOLAK BARREL DRUM
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF19110B),
              border: Border.all(color: const Color(0xFF5A3921), width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                // LEFT HEAD: TREBLE HEAD (TAASH)
                Expanded(
                  flex: 4,
                  child: _buildDrumHead(
                    provider: provider,
                    title: 'Treble Head (Taash)',
                    subtitle: 'Ta (Rim) • Ti (Center)',
                    isTreble: true,
                    isHit: activeHead == 'treble' || activeHead == 'both',
                    primaryColor: const Color(0xFFF4E4C1),
                    borderColor: Colors.amber.shade700,
                    strokes: [
                      DholakStroke.allStrokes.firstWhere((s) => s.id == 'taash'),
                      DholakStroke.allStrokes.firstWhere((s) => s.id == 'ti'),
                    ],
                  ),
                ),

                // CENTER: WOODEN BARREL & ROPE LACES
                Expanded(
                  flex: 3,
                  child: _buildWoodenBarrel(),
                ),

                // RIGHT HEAD: BASS HEAD (DAGGA)
                Expanded(
                  flex: 5,
                  child: _buildDrumHead(
                    provider: provider,
                    title: 'Bass Head (Dagga)',
                    subtitle: 'Ge (Open) • Ghe (Sliding) • Ka',
                    isTreble: false,
                    isHit: activeHead == 'bass' || activeHead == 'both',
                    primaryColor: const Color(0xFFD8C39D),
                    borderColor: const Color(0xFF8B5A2B),
                    strokes: [
                      DholakStroke.allStrokes.firstWhere((s) => s.id == 'dagga'),
                      DholakStroke.allStrokes.firstWhere((s) => s.id == 'ghe'),
                      DholakStroke.allStrokes.firstWhere((s) => s.id == 'dhabba'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrumHead({
    required DholakProvider provider,
    required String title,
    required String subtitle,
    required bool isTreble,
    required bool isHit,
    required Color primaryColor,
    required Color borderColor,
    required List<DholakStroke> strokes,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.pianoGold, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 9),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer drum skin circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7), borderColor],
                  ),
                  border: Border.all(
                    color: isHit ? AppColors.pianoGold : borderColor,
                    width: isHit ? 4 : 2.5,
                  ),
                  boxShadow: isHit
                      ? [BoxShadow(color: AppColors.pianoGold.withValues(alpha: 0.8), blurRadius: 16)]
                      : [const BoxShadow(color: Colors.black45, blurRadius: 8)],
                ),
              ),

              // Black Syahi / Dhabba Center Paste for Bass head
              if (!isTreble)
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF23160C), Color(0xFF422815)],
                    ),
                  ),
                ),

              // Interactive Stroke Hit Zones (scaled down when the drum is short, e.g. landscape)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: strokes.map((stroke) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        foregroundColor: AppColors.pianoGold,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.pianoGold.withValues(alpha: 0.4)),
                        ),
                      ),
                      onPressed: () => provider.playStroke(stroke),
                      child: Text(
                        stroke.bol,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWoodenBarrel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2511), Color(0xFF6E381A), Color(0xFF33180A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
        border: Border.all(color: const Color(0xFF8B4513), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rope Laces lines visual
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (_) => Container(height: 1, color: Colors.amber.withValues(alpha: 0.4))),
          ),
          // Center Brass Ring
          Container(
            height: 12,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFDF73), Color(0xFFB8860B), Color(0xFFFFDF73)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokePalette(DholakProvider provider) {
    final comboStrokes = [
      DholakStroke.allStrokes.firstWhere((s) => s.id == 'dha'),
      DholakStroke.allStrokes.firstWhere((s) => s.id == 'dhin'),
      DholakStroke.allStrokes.firstWhere((s) => s.id == 'ka'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text(
            'Compound Strokes:',
            style: TextStyle(color: AppColors.pianoGold, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
            children: comboStrokes.map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  backgroundColor: AppColors.tablaAmber.withValues(alpha: 0.2),
                  side: const BorderSide(color: AppColors.tablaAmber),
                  label: Text(
                    s.bol,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => provider.playStroke(s),
                ),
              );
            }).toList(),
            ),
            ),
          ),
        ],
      ),
    );
  }
}
