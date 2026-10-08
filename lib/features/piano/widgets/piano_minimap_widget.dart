import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/piano_provider.dart';
import '../../../core/theme/app_colors.dart';

class PianoMinimapWidget extends StatelessWidget {
  const PianoMinimapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PianoProvider>();
    final octaves = [2, 3, 4, 5, 6];

    return Container(
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF14131C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        children: octaves.map((oct) {
          bool isActive = provider.octave == oct;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setOctave(oct),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryCyan.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive ? AppColors.primaryCyan : Colors.transparent,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'C$oct',
                  style: TextStyle(
                    color: isActive ? AppColors.primaryCyan : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
