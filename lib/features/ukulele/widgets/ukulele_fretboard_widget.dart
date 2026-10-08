import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ukulele_model.dart';
import '../providers/ukulele_provider.dart';
import '../../../core/theme/app_colors.dart';

class UkuleleFretboardWidget extends StatelessWidget {
  const UkuleleFretboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UkuleleProvider>();
    final chord = provider.selectedChord;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) => provider.strumChord(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF3F2312), Color(0xFF633A21), Color(0xFF2C1609)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
          border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
        ),
        child: Column(
          children: [
            // Headstock Nut Bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFF4E4C1),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
              ),
              child: const Center(
                child: Text(
                  'G C E A  •  UKULELE NUT',
                  style: TextStyle(color: Colors.black87, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 4 Strings Fret Grid
            Expanded(
              child: Row(
                children: List.generate(4, (stringIdx) {
                  final uktString = UkuleleString.standardStrings[stringIdx];
                  int chordFret = chord.frets[stringIdx];
                  bool isPlucked = provider.activePluckedString == stringIdx;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => provider.pluckString(stringIdx),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.white12, width: 1.5)),
                        ),
                        child: Column(
                          children: [
                            // String Name Header
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                uktString.noteName,
                                style: const TextStyle(
                                  color: AppColors.pianoGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            // Frets 1 to 5
                            Expanded(
                              child: Column(
                                children: List.generate(5, (fretIdx) {
                                  int currentFretNum = fretIdx + 1;
                                  bool hasChordDot = chordFret == currentFretNum;

                                  return Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Nylon string line
                                          Container(
                                            width: isPlucked ? 3.5 : 2.0,
                                            color: isPlucked ? AppColors.primaryNeon : const Color(0xFFE8DCC4),
                                          ),

                                          // Chord position marker dot
                                          if (hasChordDot)
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.pianoGold,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.pianoGold.withValues(alpha: 0.8),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$currentFretNum',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
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
      ),
    );
  }
}
