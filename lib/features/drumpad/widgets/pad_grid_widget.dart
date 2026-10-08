import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drumpad_provider.dart';
import '../models/drum_pad_model.dart';
import '../../../core/theme/app_colors.dart';

class PadGridWidget extends StatelessWidget {
  const PadGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrumPadProvider>();
    final pads = DrumPadModel.defaultPads;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF14131F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkCardBorder, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      // Size pads to the available space so all 4 rows fit without scrolling
      child: LayoutBuilder(
        builder: (context, constraints) {
          const columns = 4, spacing = 10.0;
          final rows = (pads.length / columns).ceil();
          final padWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
          final padHeight = (constraints.maxHeight - spacing * (rows - 1)) / rows;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: padWidth / padHeight,
            ),
            itemCount: pads.length,
            itemBuilder: (context, index) {
              final pad = pads[index];
              final isActive = provider.activePadId == pad.id;

              return GestureDetector(
                onTapDown: (_) => provider.triggerPad(pad),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  decoration: BoxDecoration(
                    color: isActive ? pad.color : pad.color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isActive
                        ? [BoxShadow(color: pad.color.withValues(alpha: 0.9), blurRadius: 16, spreadRadius: 3)]
                        : [const BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                    border: Border.all(
                      color: isActive ? Colors.white : pad.color.withValues(alpha: 0.6),
                      width: isActive ? 2.5 : 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : pad.color,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: pad.color, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pad.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
