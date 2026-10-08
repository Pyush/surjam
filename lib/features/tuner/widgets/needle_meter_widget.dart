import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tuner_provider.dart';
import '../utils/pitch_converter.dart';

class NeedleMeterWidget extends StatelessWidget {
  const NeedleMeterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TunerProvider>();
    final cents = provider.centsOffset;
    final isInTune = provider.isInTune;
    final targetNote = provider.selectedTargetNote;
    final noteName = PitchConverter.midiToNoteName(targetNote.midiNote);
    final sargamName = PitchConverter.midiToSargam(targetNote.midiNote);

    final hasSignal = provider.hasSignal;

    Color statusColor = !hasSignal
        ? Colors.white38
        : isInTune
            ? const Color(0xFF2CB67D)
            : (cents < 0 ? const Color(0xFFFFB703) : const Color(0xFFE63946));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14121E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInTune ? const Color(0xFF2CB67D) : Colors.white12,
          width: isInTune ? 2.5 : 1.5,
        ),
        boxShadow: isInTune
            ? [BoxShadow(color: const Color(0xFF2CB67D).withValues(alpha: 0.6), blurRadius: 20)]
            : [const BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. ARC NEEDLE GAUGE
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _NeedleMeterPainter(
                centsOffset: cents,
                meterColor: statusColor,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 2. BIG NOTE & FREQUENCY DISPLAY
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                noteName,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  sargamName,
                  style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 3. CENTS & IN-TUNE STATUS TEXT
          Text(
            _statusText(provider),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          if (hasSignal) ...[
            const SizedBox(height: 2),
            Text(
              'Hearing ${PitchConverter.midiToNoteName(provider.detectedMidi)} · ${provider.currentFrequency.toStringAsFixed(1)} Hz',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

String _statusText(TunerProvider provider) {
  switch (provider.status) {
    case TunerStatus.permissionDenied:
      return 'Microphone access is off. Allow it in Settings to tune.';
    case TunerStatus.unavailable:
      return 'No microphone available on this device.';
    case TunerStatus.idle:
      return 'Tap Start Listening to tune.';
    case TunerStatus.listening:
      if (!provider.hasSignal) return 'Listening… play or sing a note';
      final cents = provider.centsOffset;
      if (provider.isInTune) return '✔ IN TUNE';
      return '${cents < 0 ? "♭ FLAT" : "♯ SHARP"} (${cents > 0 ? "+" : ""}${cents.toStringAsFixed(1)} Cents)';
  }
}

class _NeedleMeterPainter extends CustomPainter {
  final double centsOffset; // -50 to +50
  final Color meterColor;

  _NeedleMeterPainter({required this.centsOffset, required this.meterColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    // Fit the half-circle inside the box on wide (landscape) layouts too.
    final radius = min(size.width * 0.4, size.height * 0.8);

    // Arc background
    final arcPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      arcPaint,
    );

    // In-tune center zone (-5c to +5c)
    final greenZonePaint = Paint()
      ..color = const Color(0xFF2CB67D).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + (pi * 0.45),
      pi * 0.1,
      false,
      greenZonePaint,
    );

    // Needle Angle (-50c = -pi/2, 0c = 0, +50c = pi/2)
    double normalizedCents = centsOffset.clamp(-50.0, 50.0);
    double angle = (normalizedCents / 50.0) * (pi / 2.3);

    final needlePaint = Paint()
      ..color = meterColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final needleEnd = Offset(
      center.dx + (radius - 10) * sin(angle),
      center.dy - (radius - 10) * cos(angle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center pivot dot
    final pivotPaint = Paint()..color = meterColor;
    canvas.drawCircle(center, 7, pivotPaint);
  }

  @override
  bool shouldRepaint(covariant _NeedleMeterPainter oldDelegate) {
    return oldDelegate.centsOffset != centsOffset || oldDelegate.meterColor != meterColor;
  }
}
