import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guitar_provider.dart';
import '../../../core/theme/app_colors.dart';

class FretboardWidget extends StatelessWidget {
  const FretboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuitarProvider>();
    final chord = provider.selectedChord;

    final stringNames = ['E', 'A', 'D', 'G', 'B', 'E'];
    final openMidi = [40, 45, 50, 55, 59, 64];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF321E12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5C3720), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Nut & Fret Markers Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: const Color(0xFF24150C),
            child: Row(
              children: [
                const SizedBox(width: 40), // String name column
                ...List.generate(5, (fretIdx) => Expanded(
                  child: Center(
                    child: Text(
                      fretIdx == 0 ? 'NUT' : 'FRET $fretIdx',
                      style: TextStyle(
                        color: fretIdx == 0 ? AppColors.pianoGold : Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),

          // 6 Strings
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (stringIdx) {
                int fretNum = chord.frets[stringIdx];
                int midiNote = (fretNum >= 0) ? openMidi[stringIdx] + fretNum : openMidi[stringIdx];
                bool isPlucked = provider.pluckedStringIndex == stringIdx;

                return GestureDetector(
                  onTap: () {
                    if (fretNum != -1) {
                      provider.pluckString(stringIdx, midiNote);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    height: 38,
                    color: isPlucked ? AppColors.primaryNeon.withValues(alpha: 0.15) : Colors.transparent,
                    child: Row(
                      children: [
                        // String Label
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              stringNames[stringIdx],
                              style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        // Frets 0 to 4
                        ...List.generate(5, (fretIdx) {
                          bool hasDot = (fretNum == fretIdx);
                          bool isMuted = (fretNum == -1 && fretIdx == 0);

                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: fretIdx == 0 ? Colors.amber.shade200 : const Color(0xFFC0A080),
                                    width: fretIdx == 0 ? 4 : 2,
                                  ),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // String Line
                                  Container(
                                    height: (6 - stringIdx * 0.7).clamp(1.5, 5.0),
                                    color: isPlucked ? AppColors.primaryNeon : const Color(0xFFD4C4B5),
                                  ),

                                  // Muted X Marker
                                  if (isMuted)
                                    const Text(
                                      '✕',
                                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),

                                  // Finger Position Dot
                                  if (hasDot)
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryNeon,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: AppColors.primaryNeon, blurRadius: 6)],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        fretIdx == 0 ? 'O' : '$fretIdx',
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
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
