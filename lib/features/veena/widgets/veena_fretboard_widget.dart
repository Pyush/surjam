import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/veena_provider.dart';
import '../../../core/music/thaat.dart';
import '../../../core/theme/app_colors.dart';

/// The veena's neck: one row per fret (lowest at the bottom in portrait, left in landscape).
/// Tap a fret to pluck; drag across it to pull the string for gamaka.
class VeenaFretboardWidget extends StatelessWidget {
  /// Distance of drag across the string for each semitone of pull.
  static const double pullPerSemitone = 36;

  const VeenaFretboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VeenaProvider>();
    final frets = provider.frets;
    final horizontal = MediaQuery.orientationOf(context) == Orientation.landscape;

    final rows = [
      for (final midi in frets)
        Expanded(
          child: _Fret(
            midi: midi,
            horizontal: horizontal,
            provider: provider,
          ),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1A0E), Color(0xFF4A2C16), Color(0xFF2B1A0E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFB8860B), width: 1.5),
      ),
      padding: const EdgeInsets.all(8),
      child: horizontal ? Row(children: rows) : Column(children: rows.reversed.toList()),
    );
  }
}

class _Fret extends StatefulWidget {
  final int midi;
  final bool horizontal;
  final VeenaProvider provider;

  const _Fret({required this.midi, required this.horizontal, required this.provider});

  @override
  State<_Fret> createState() => _FretState();
}

class _FretState extends State<_Fret> {
  double _pullDistance = 0;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final active = provider.activeFret == widget.midi;
    final isSa = widget.midi % 12 == 0;
    final label = provider.showSargam ? ThaatTuning.sargamLabel(widget.midi) : ThaatTuning.englishLabel(widget.midi);
    final pulled = active ? provider.gamaka : 0;

    void onDrag(double delta) {
      _pullDistance += delta.abs();
      provider.pull((_pullDistance / VeenaFretboardWidget.pullPerSemitone).floor());
    }

    return Semantics(
      button: true,
      label: '${ThaatTuning.sargamLabel(widget.midi)} fret, ${ThaatTuning.englishLabel(widget.midi)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          _pullDistance = 0;
          provider.pluck(widget.midi);
        },
        onTapUp: (_) => provider.lift(),
        // Pulling runs across the string: sideways in portrait, up/down in landscape.
        onHorizontalDragStart: widget.horizontal ? null : (_) => _startPull(),
        onHorizontalDragUpdate: widget.horizontal ? null : (d) => onDrag(d.delta.dx),
        onHorizontalDragEnd: widget.horizontal ? null : (_) => provider.lift(),
        onVerticalDragStart: widget.horizontal ? (_) => _startPull() : null,
        onVerticalDragUpdate: widget.horizontal ? (d) => onDrag(d.delta.dy) : null,
        onVerticalDragEnd: widget.horizontal ? (_) => provider.lift() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: active ? AppColors.pianoGold.withValues(alpha: 0.2) : Colors.transparent,
          ),
          child: Flex(
            direction: widget.horizontal ? Axis.vertical : Axis.horizontal,
            children: [
              SizedBox(
                width: widget.horizontal ? null : 44,
                height: widget.horizontal ? 28 : null,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      pulled > 0 ? '$label +$pulled' : label,
                      style: TextStyle(
                        color: isSa ? AppColors.pianoGold : const Color(0xFFF1DFC4),
                        fontWeight: isSa || active ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Brass fret across the neck.
                    Container(
                      width: widget.horizontal ? 3 : null,
                      height: widget.horizontal ? null : 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFDF73), Color(0xFFB8860B)]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // The main string crossing it; it shifts when pulled.
                    Align(
                      alignment: widget.horizontal
                          ? Alignment(0, -0.4 * pulled)
                          : Alignment(-0.3 + 0.3 * pulled, 0),
                      child: Container(
                        width: widget.horizontal ? double.infinity : 2,
                        height: widget.horizontal ? 2 : double.infinity,
                        color: active ? AppColors.pianoGold : const Color(0xFFD9D4CC),
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

  void _startPull() {
    _pullDistance = 0;
    widget.provider.pluck(widget.midi);
  }
}
