import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sitar_provider.dart';
import '../../../core/theme/app_colors.dart';

class SitarFretboardWidget extends StatefulWidget {
  const SitarFretboardWidget({super.key});

  @override
  State<SitarFretboardWidget> createState() => _SitarFretboardWidgetState();
}

class _SitarFretboardWidgetState extends State<SitarFretboardWidget> {
  int? _draggingFret;
  double _dragStartY = 0.0;
  int _currentBend = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SitarProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2C160B), Color(0xFF422110), Color(0xFF1E0D05)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 12, offset: Offset(0, 4)),
            ],
            border: Border.all(color: const Color(0xFF7A4A28), width: 2),
          ),
          child: Column(
            children: [
              // 1. CHIKARI DRONE STRINGS BAR (TOP)
              _buildChikariBar(provider),

              const Divider(color: Color(0xFF5A361D), height: 1, thickness: 1.5),

              // 2. MAIN FRETBOARD WITH CURVED BRASS FRETS & MEEND GESTURE
              Expanded(
                flex: 5,
                child: _buildMainFretboard(provider),
              ),

              const Divider(color: Color(0xFF5A361D), height: 1, thickness: 1.5),

              // 3. TARAB SYMPATHETIC STRINGS BAR (BOTTOM)
              _buildTarabBar(provider),
            ],
          ),
        );
      },
    );
  }

  // --- 1. CHIKARI DRONES ---
  Widget _buildChikariBar(SitarProvider provider) {
    // Pancham, chhoti chikari and badi chikari; the section label names them.
    final chikariNames = ['Pa', 'Sa\'', 'Sa\'\''];
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.pianoGold.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.graphic_eq, color: AppColors.pianoGold, size: 14),
                SizedBox(width: 4),
                Text(
                  'Chikari',
                  style: TextStyle(color: AppColors.pianoGold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (idx) {
                bool isPlucked = provider.activeStringIndex == (4 + idx);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.strumChikari(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPlucked ? Colors.amber.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPlucked ? AppColors.pianoGold : Colors.white24,
                          width: isPlucked ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Metallic wire line
                          Container(
                            height: isPlucked ? 3.0 : 1.5,
                            color: isPlucked ? AppColors.pianoGold : Colors.grey.shade400,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            // Backing keeps the string line from striking through the label.
                            child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            color: const Color(0xFF1C130C),
                            child: Text(
                            chikariNames[idx],
                            maxLines: 1,
                            style: TextStyle(
                              color: isPlucked ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isPlucked ? FontWeight.bold : FontWeight.normal,
                            ),
                            ),
                            ),
                          ),
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
    );
  }

  // --- 2. MAIN FRETBOARD WITH CURVED BRASS FRETS ---
  Widget _buildMainFretboard(SitarProvider provider) {
    return Stack(
      children: [
        // Wood grain neck background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF321A0C), Color(0xFF4A2713), Color(0xFF2C160B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Frets Row: low Ni, then Sa to high Sa
        Row(
          children: provider.fretSemitones.map((fretIdx) {
            bool inRaga = provider.isFretInRaga(fretIdx);
            bool isActive = provider.activeFret == fretIdx;
            String swaraName = SitarProvider.swaraLabel(fretIdx);

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  _draggingFret = fretIdx;
                  _dragStartY = details.localPosition.dy;
                  _currentBend = 0;
                  provider.pluckFret(fretIdx, bend: 0);
                },
                onPanUpdate: (details) {
                  if (_draggingFret == fretIdx) {
                    double dy = (_dragStartY - details.localPosition.dy).abs();
                    // Every 25 pixels of drag upward/downward bends by +1 semitone (up to 4 semitones)
                    int bend = (dy / 25).floor().clamp(0, 4);
                    if (bend != _currentBend) {
                      _currentBend = bend;
                      provider.pluckFret(fretIdx, bend: bend);
                    }
                  }
                },
                onPanEnd: (_) {
                  _draggingFret = null;
                  _currentBend = 0;
                },
                onTap: () {
                  provider.pluckFret(fretIdx, bend: 0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: inRaga ? const Color(0xFFD4AF37) : Colors.black45,
                        width: isActive ? 4 : 2.5,
                      ),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Brass Parda Fret Curve Visual
                      Positioned(
                        top: 8,
                        bottom: 8,
                        right: 0,
                        width: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFDF73), Color(0xFFB8860B), Color(0xFF8B6508)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isActive
                                ? [const BoxShadow(color: AppColors.pianoGold, blurRadius: 8, spreadRadius: 1)]
                                : [],
                          ),
                        ),
                      ),

                      // Swara Badge (scaled to fit narrow portrait columns)
                      Positioned(
                        top: 12,
                        left: 1,
                        right: 9,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                            color: inRaga
                                ? (isActive ? AppColors.pianoGold : Colors.amber.withValues(alpha: 0.25))
                                : Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: inRaga ? AppColors.pianoGold : Colors.white12,
                            ),
                          ),
                          child: Text(
                            swaraName,
                            style: TextStyle(
                              color: inRaga ? (isActive ? Colors.black : AppColors.pianoGold) : Colors.white38,
                              fontSize: 11,
                              fontWeight: inRaga ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          ),
                        ),
                      ),

                      // Baj Tar (Main String) horizontal line
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Container(
                          height: isActive ? 3.5 : 2.0,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primaryCyan : const Color(0xFFE0C068),
                            boxShadow: isActive
                                ? [BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.8), blurRadius: 6)]
                                : [],
                          ),
                        ),
                      ),

                      // Meend Bend Indicator
                      if (isActive && provider.bendSemitones > 0)
                        Positioned(
                          bottom: 12,
                          left: 1,
                          right: 9,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryCyan,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${provider.bendSemitones}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- 3. TARAB SYMPATHETIC STRINGS BAR ---
  Widget _buildTarabBar(SitarProvider provider) {
    final intervals = provider.selectedRaga.intervals;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.waves, color: Colors.tealAccent, size: 14),
                SizedBox(width: 4),
                Text(
                  'Tarab',
                  style: TextStyle(color: Colors.tealAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(11, (tarabIdx) {
                bool isPlucked = provider.activeTarabIndex == tarabIdx;
                int semitone = intervals[tarabIdx % intervals.length];
                String noteLabel = SitarProvider.swaraNames[semitone % 12];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.pluckTarab(tarabIdx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPlucked ? Colors.tealAccent.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPlucked ? Colors.tealAccent : Colors.white12,
                          width: isPlucked ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 1.0,
                            color: isPlucked ? Colors.tealAccent : Colors.grey.shade600,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            // Backing keeps the string line from striking through the label.
                            child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            color: const Color(0xFF1C130C),
                            child: Text(
                            noteLabel,
                            maxLines: 1,
                            style: TextStyle(
                              color: isPlucked ? Colors.white : Colors.white60,
                              fontSize: 9,
                              fontWeight: isPlucked ? FontWeight.bold : FontWeight.normal,
                            ),
                            ),
                            ),
                          ),
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
    );
  }
}
