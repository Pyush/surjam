import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/violin_provider.dart';
import '../../../core/theme/app_colors.dart';

class FingerboardWidget extends StatelessWidget {
  const FingerboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ViolinProvider>();
    final stringNames = ['G3', 'D4', 'A4', 'E5'];
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1412), // Dark ebony fingerboard
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A342B), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Header: String Names
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: const Color(0xFF140D0B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stringNames.map((s) => Text(
                s,
                style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold),
              )).toList(),
            ),
          ),

          // 4 Strings Grid
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (stringIdx) {
                bool isPlucked = provider.activeStringIndex == stringIdx;

                return Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.white10)),
                    ),
                    child: Column(
                      // One octave of semitone positions per string (open string to octave)
                      children: List.generate(13, (posIdx) {
                        // First-position finger tapes: 1st (+2), 2nd (+4), 3rd (+5), 4th (+7)
                        final fingerTape = const {2: 1, 4: 2, 5: 3, 7: 4}[posIdx];
                        final midi = provider.openStrings[stringIdx] + posIdx;
                        final noteName = '${noteNames[midi % 12]}${midi ~/ 12 - 1}';
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => provider.onFingerTap(stringIdx, posIdx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 60),
                              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                              decoration: BoxDecoration(
                                color: isPlucked ? AppColors.accentMagenta.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border(
                                  bottom: BorderSide(
                                    color: fingerTape != null
                                        ? Colors.amber.withValues(alpha: 0.5)
                                        : Colors.white10,
                                    width: fingerTape != null ? 2 : 1,
                                  ),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // String line
                                  Container(
                                    width: (4 - stringIdx * 0.6).clamp(1.5, 4.0),
                                    color: isPlucked ? AppColors.accentMagenta : Colors.grey.shade400,
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      fingerTape != null ? '$noteName · $fingerTape' : noteName,
                                      style: TextStyle(
                                        color: fingerTape != null ? Colors.amber : Colors.white54,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
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
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
