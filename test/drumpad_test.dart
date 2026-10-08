import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/core/audio/sound_synthesizer.dart';
import 'package:surjam/features/drumpad/models/drum_pad_model.dart';

void main() {
  group('Drum Pad Kits', () {
    const pads = DrumPadModel.defaultPads;

    test('All 16 pads have their own sound', () {
      expect(pads.length, equals(16));
      expect(pads.map((p) => p.soundKey).toSet().length, equals(16));
    });

    test('No pad falls back to the generic beep, and every pad sounds different', () {
      final fallback = SoundSynthesizer.generateDrumPadWav('not_a_real_pad');
      for (final kit in DrumKit.kits) {
        final sounds = <String, Uint8List>{};
        for (final pad in pads) {
          final wav = SoundSynthesizer.generateDrumPadWav(pad.soundKey, kit: kit.id);
          expect(listEquals(wav, fallback), isFalse, reason: '${kit.id}/${pad.label} is the fallback beep');
          for (final entry in sounds.entries) {
            expect(listEquals(wav, entry.value), isFalse, reason: '${kit.id}: ${pad.label} sounds like ${entry.key}');
          }
          sounds[pad.label] = wav;
        }
      }
    });

    test('Kits give the core drums a different character', () {
      for (final voice in ['kick', 'snare', 'hihat_close', 'sub_kick']) {
        final byKit = DrumKit.kits.map((k) => SoundSynthesizer.generateDrumPadWav(voice, kit: k.id)).toList();
        expect(listEquals(byKit[0], byKit[1]), isFalse, reason: voice);
        expect(listEquals(byKit[0], byKit[2]), isFalse, reason: voice);
        expect(listEquals(byKit[1], byKit[2]), isFalse, reason: voice);
      }
    });

    test('Every pad produces audible sound', () {
      for (final kit in DrumKit.kits) {
        for (final pad in pads) {
          final data = ByteData.sublistView(SoundSynthesizer.generateDrumPadWav(pad.soundKey, kit: kit.id));
          int peak = 0;
          for (int i = 44; i + 1 < data.lengthInBytes; i += 2) {
            final v = data.getInt16(i, Endian.little).abs();
            if (v > peak) peak = v;
          }
          expect(peak, greaterThan(3000), reason: '${kit.id}/${pad.label} is too quiet');
        }
      }
    });
  });
}
