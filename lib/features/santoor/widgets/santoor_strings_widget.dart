import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/music/thaat.dart';
import '../providers/santoor_provider.dart';
import '../../../core/theme/app_colors.dart';

/// The santoor's strings on a trapezoid board, lowest Sa at the wide bottom. Tap a string to
/// strike it; hold it for a tremolo roll. In landscape the two octaves sit side by side so
/// every string stays finger-sized.
class SantoorStringsWidget extends StatelessWidget {
  const SantoorStringsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SantoorProvider>();
    final strings = provider.strings;
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2A14), Color(0xFF6B3D1E), Color(0xFF3B2010)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF8B5A2B), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: isLandscape
          ? Row(
              children: [
                Expanded(child: _Course(strings: strings.sublist(0, 8), provider: provider)),
                const SizedBox(width: 12),
                Expanded(child: _Course(strings: strings.sublist(7), provider: provider)),
              ],
            )
          : _Course(strings: strings, provider: provider),
    );
  }
}

/// A column of strings drawn highest at the top, narrowing like a santoor's trapezoid.
class _Course extends StatelessWidget {
  final List<int> strings;
  final SantoorProvider provider;

  const _Course({required this.strings, required this.provider});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxInset = constraints.maxWidth * 0.18;
        final highToLow = strings.reversed.toList();
        return Column(
          children: [
            for (int i = 0; i < highToLow.length; i++)
              Expanded(
                child: Padding(
                  // Higher strings are shorter: the board narrows towards the top.
                  padding: EdgeInsets.symmetric(
                    horizontal: highToLow.length == 1 ? 0 : maxInset * (1 - i / (highToLow.length - 1)),
                  ),
                  child: _SantoorString(midi: highToLow[i], provider: provider),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SantoorString extends StatelessWidget {
  final int midi;
  final SantoorProvider provider;

  const _SantoorString({required this.midi, required this.provider});

  @override
  Widget build(BuildContext context) {
    final ringing = provider.isRinging(midi);
    final isSa = midi % 12 == 0;
    final label = provider.showSargam ? ThaatTuning.sargamLabel(midi) : ThaatTuning.englishLabel(midi);

    return Semantics(
      button: true,
      label: '${ThaatTuning.sargamLabel(midi)} string, ${ThaatTuning.englishLabel(midi)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => provider.strike(midi),
        onLongPressStart: (_) => provider.startTremolo(midi),
        onLongPressEnd: (_) => provider.stopTremolo(),
        onLongPressCancel: provider.stopTremolo,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ringing ? AppColors.pianoGold.withValues(alpha: 0.18) : Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSa ? AppColors.pianoGold : const Color(0xFFF1DFC4),
                    fontWeight: isSa ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The metal string (a course of three on a real santoor).
                    Container(
                      height: ringing ? 3 : 2,
                      decoration: BoxDecoration(
                        color: ringing ? AppColors.pianoGold : const Color(0xFFD9D4CC),
                        boxShadow: ringing ? [const BoxShadow(color: AppColors.pianoGold, blurRadius: 6)] : null,
                      ),
                    ),
                    // Bridge where the string rests.
                    Align(
                      alignment: const Alignment(0.55, 0),
                      child: Container(
                        width: 6,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D2A6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
