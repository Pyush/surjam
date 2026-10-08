import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/harmonium_provider.dart';
import '../../../core/theme/app_colors.dart';

class HarmoniumKeyboardWidget extends StatelessWidget {
  const HarmoniumKeyboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HarmoniumProvider>();
    final startMidi = provider.octave * 12 + 12; // Octave 4 = C4 (60)

    final sargamLabels = ['Sa', 're', 'Re', 'ga', 'Ga', 'Ma', 'MA', 'Pa', 'dha', 'Dha', 'ni', 'Ni'];
    final isBlackList = [false, true, false, true, false, false, true, false, true, false, true, false];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B1E0D), // Polished wooden cabinet
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF633419), width: 3),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Wooden Bellows & Stop Knobs Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF271307),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🪕 REED CABINET & DRONES',
                  style: TextStyle(color: AppColors.pianoGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Row(
                  children: [
                    _buildDroneKnob(provider, 'Sa Drone', 'sa'),
                    const SizedBox(width: 8),
                    _buildDroneKnob(provider, 'Pa Drone', 'pa'),
                  ],
                ),
              ],
            ),
          ),

          // Harmonium Keyboard Keys
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: List.generate(14, (index) {
                  int midi = startMidi + index;
                  int noteIdx = index % 12;
                  bool isBlack = isBlackList[noteIdx];
                  bool isPressed = provider.activeKeys.contains(midi);

                  return Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => provider.onKeyTap(midi),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isPressed
                              ? AppColors.pianoGold
                              : (isBlack ? const Color(0xFF1E1510) : const Color(0xFFFAF4ED)),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3)],
                          border: Border.all(
                            color: isBlack ? Colors.black : const Color(0xFFC7B299),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          sargamLabels[noteIdx],
                          style: TextStyle(
                            color: isPressed
                                ? Colors.black
                                : (isBlack ? Colors.amber.shade200 : Colors.brown.shade900),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDroneKnob(HarmoniumProvider provider, String title, String sur) {
    bool isActive = provider.activeDrone == sur;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.pianoGold : const Color(0xFF4A2612),
        foregroundColor: isActive ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => provider.toggleDrone(sur),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
