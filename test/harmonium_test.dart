import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/core/audio/sound_synthesizer.dart';

void main() {
  group('Harmonium Drone', () {
    List<int> samples(Uint8List wav) {
      final data = ByteData.sublistView(wav);
      return [for (int i = 44; i + 1 < wav.length; i += 2) data.getInt16(i, Endian.little)];
    }

    test('Drone loop is about two seconds and loops without a click', () {
      for (final midi in [48, 55, 57]) {
        final pcm = samples(SoundSynthesizer.generateHarmoniumDroneWav(SoundSynthesizer.midiToFrequency(midi)));
        expect(pcm.length / SoundSynthesizer.sampleRate, closeTo(2.0, 0.05), reason: 'midi $midi');

        int largestStep = 0;
        for (int i = 1; i < pcm.length; i++) {
          final step = (pcm[i] - pcm[i - 1]).abs();
          if (step > largestStep) largestStep = step;
        }
        // Jumping from the last sample back to the first must be no bigger than a normal step.
        expect((pcm.first - pcm.last).abs(), lessThanOrEqualTo(largestStep), reason: 'midi $midi');
      }
    });

    test('Drone keeps a steady level instead of decaying', () {
      final pcm = samples(SoundSynthesizer.generateHarmoniumDroneWav(130.81));
      double peak(Iterable<int> s) => s.map((v) => v.abs()).reduce((a, b) => a > b ? a : b).toDouble();
      final quarter = pcm.length ~/ 4;
      final firstQuarter = peak(pcm.take(quarter));
      final lastQuarter = peak(pcm.skip(pcm.length - quarter));
      expect(lastQuarter, greaterThan(firstQuarter * 0.75));
    });
  });
}
