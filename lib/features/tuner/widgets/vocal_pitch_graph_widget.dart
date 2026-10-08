import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tuner_provider.dart';
import '../utils/pitch_converter.dart';
import '../../../core/theme/app_colors.dart';

class VocalPitchGraphWidget extends StatelessWidget {
  const VocalPitchGraphWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TunerProvider>();
    final history = provider.pitchHistory;
    final targetMidi = provider.selectedTargetNote.midiNote;
    final targetFreq = PitchConverter.midiToFrequency(targetMidi);

    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF191726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.mic, color: AppColors.pianoGold, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Real-Time Vocal Pitch Monitor',
                    style: TextStyle(color: AppColors.pianoGold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'Target Line: ${targetFreq.toStringAsFixed(1)} Hz',
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                size: Size.infinite,
                painter: _VocalGraphPainter(
                  history: history,
                  targetFreq: targetFreq,
                  isInTune: provider.isInTune,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocalGraphPainter extends CustomPainter {
  final List<double> history;
  final double targetFreq;
  final bool isInTune;

  _VocalGraphPainter({
    required this.history,
    required this.targetFreq,
    required this.isInTune,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0F0E17);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Target Pitch Center Line (y = size.height / 2)
    final linePaint = Paint()
      ..color = AppColors.pianoGold.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );

    if (history.isEmpty) return;

    // Pitch History Line
    final path = Path();
    double stepX = size.width / (history.length > 1 ? history.length - 1 : 1);

    for (int i = 0; i < history.length; i++) {
      double freq = history[i];
      // Deviation in Hz relative to targetFreq (+- 20 Hz range)
      double devHz = (freq - targetFreq).clamp(-20.0, 20.0);
      double y = (size.height / 2) - (devHz / 20.0) * (size.height * 0.4);
      double x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final pitchPaint = Paint()
      ..color = isInTune ? const Color(0xFF2CB67D) : const Color(0xFFFFB703)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, pitchPaint);
  }

  @override
  bool shouldRepaint(covariant _VocalGraphPainter oldDelegate) => true;
}
