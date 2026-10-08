import 'dart:math';
import 'dart:typed_data';

/// Monophonic pitch detection using the YIN algorithm
/// (de Cheveigné & Kawahara, 2002).
class PitchDetector {
  final int sampleRate;
  final int windowSize;
  final double minFrequency;
  final double maxFrequency;

  /// Lower values demand a cleaner periodic signal before reporting a pitch.
  final double threshold;

  /// Frames quieter than this RMS level (on a -1.0..1.0 scale) are treated as silence.
  final double minRms;

  const PitchDetector({
    required this.sampleRate,
    this.windowSize = 1024,
    this.minFrequency = 50.0,
    this.maxFrequency = 1500.0,
    this.threshold = 0.15,
    this.minRms = 0.01,
  });

  int get _maxTau => (sampleRate / minFrequency).ceil();
  int get _minTau => max(2, (sampleRate / maxFrequency).floor());

  /// Number of samples [detect] needs to cover the lowest detectable frequency.
  int get frameSize => windowSize + _maxTau;

  /// Returns the fundamental frequency in Hz, or null for silence or noise.
  double? detect(Float64List frame) {
    if (frame.length < frameSize) return null;

    double energy = 0;
    for (int j = 0; j < windowSize; j++) {
      energy += frame[j] * frame[j];
    }
    if (sqrt(energy / windowSize) < minRms) return null;

    final int maxTau = _maxTau;
    final Float64List diff = Float64List(maxTau + 1);
    for (int tau = 1; tau <= maxTau; tau++) {
      double sum = 0;
      for (int j = 0; j < windowSize; j++) {
        final double delta = frame[j] - frame[j + tau];
        sum += delta * delta;
      }
      diff[tau] = sum;
    }

    // Cumulative mean normalised difference.
    final Float64List cmnd = Float64List(maxTau + 1);
    cmnd[0] = 1;
    double runningSum = 0;
    for (int tau = 1; tau <= maxTau; tau++) {
      runningSum += diff[tau];
      cmnd[tau] = runningSum == 0 ? 1 : diff[tau] * tau / runningSum;
    }

    // First dip below the threshold, followed down to its local minimum.
    int? bestTau;
    for (int tau = _minTau; tau <= maxTau; tau++) {
      if (cmnd[tau] < threshold) {
        while (tau + 1 <= maxTau && cmnd[tau + 1] < cmnd[tau]) {
          tau++;
        }
        bestTau = tau;
        break;
      }
    }
    if (bestTau == null) return null;

    // Parabolic interpolation for sub-sample accuracy.
    double refinedTau = bestTau.toDouble();
    if (bestTau > 1 && bestTau < maxTau) {
      final double s0 = cmnd[bestTau - 1];
      final double s1 = cmnd[bestTau];
      final double s2 = cmnd[bestTau + 1];
      final double denominator = 2 * (2 * s1 - s2 - s0);
      if (denominator != 0) {
        refinedTau += (s2 - s0) / denominator;
      }
    }

    return sampleRate / refinedTau;
  }
}
