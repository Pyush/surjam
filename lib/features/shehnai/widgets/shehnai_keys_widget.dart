import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shehnai_provider.dart';
import '../../../core/music/thaat.dart';
import '../../../core/theme/app_colors.dart';

/// One continuous playing surface: touch a key to start the note, slide to glide to another
/// (meend), lift to stop. Keys run upwards in portrait (low Sa at the bottom) and left to right
/// in landscape.
class ShehnaiKeysWidget extends StatelessWidget {
  const ShehnaiKeysWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShehnaiProvider>();
    final notes = provider.notes;
    final horizontal = MediaQuery.orientationOf(context) == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Which note is under the finger.
        int noteAt(Offset position) {
          final fraction = horizontal
              ? position.dx / constraints.maxWidth
              : 1 - position.dy / constraints.maxHeight;
          final index = (fraction * notes.length).floor().clamp(0, notes.length - 1);
          return notes[index];
        }

        final keys = [
          for (final midi in notes)
            Expanded(child: _ShehnaiKey(midi: midi, held: provider.heldMidi == midi, showSargam: provider.showSargam)),
        ];

        return Semantics(
          label: 'Shehnai keys. Touch and hold to play, slide to change note.',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) => provider.press(noteAt(details.localPosition)),
            onPanUpdate: (details) => provider.press(noteAt(details.localPosition)),
            onPanEnd: (_) => provider.release(),
            onPanCancel: provider.release,
            child: horizontal
                ? Row(children: keys)
                : Column(children: keys.reversed.toList()),
          ),
        );
      },
    );
  }
}

class _ShehnaiKey extends StatelessWidget {
  final int midi;
  final bool held;
  final bool showSargam;

  const _ShehnaiKey({required this.midi, required this.held, required this.showSargam});

  @override
  Widget build(BuildContext context) {
    final isSa = midi % 12 == 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: held
              ? [AppColors.pianoGold, const Color(0xFFE0A100)]
              : [const Color(0xFF3A2414), const Color(0xFF2A190D)],
        ),
        border: Border.all(color: isSa ? AppColors.pianoGold : const Color(0xFF6B4A2E), width: isSa ? 1.5 : 1),
        boxShadow: held ? [const BoxShadow(color: AppColors.pianoGold, blurRadius: 12)] : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          showSargam ? ThaatTuning.sargamLabel(midi) : ThaatTuning.englishLabel(midi),
          style: TextStyle(
            color: held ? Colors.black : (isSa ? AppColors.pianoGold : const Color(0xFFF1DFC4)),
            fontWeight: isSa || held ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
