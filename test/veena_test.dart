import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/audio/sound_event.dart';
import 'package:surjam/core/audio/sound_synthesizer.dart';
import 'package:surjam/core/recording/jam_recorder.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/tuner/utils/pitch_converter.dart';
import 'package:surjam/features/tuner/utils/pitch_detector.dart';
import 'package:surjam/features/veena/providers/veena_provider.dart';
import 'package:surjam/features/veena/screens/veena_screen.dart';
import 'package:surjam/features/veena/widgets/veena_fretboard_widget.dart';

Float64List _samples(Uint8List wav) {
  final data = ByteData.sublistView(wav, 44);
  return Float64List.fromList([for (int i = 0; i + 1 < data.lengthInBytes; i += 2) data.getInt16(i, Endian.little) / 32768]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async => 1);
    }
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  group('Plucked string sound', () {
    test('Every fret plays in tune (measured with the app\'s own tuner)', () {
      const detector = PitchDetector(sampleRate: 44100, windowSize: 2048, minFrequency: 100, maxFrequency: 1200);
      for (final midi in [60, 62, 67, 69, 72, 77, 84]) {
        final samples = _samples(SoundSynthesizer.generateVeenaWav(PitchConverter.midiToFrequency(midi)));
        // Measure in the steady ring, after the pluck's attack.
        final frame = Float64List.sublistView(samples, 4410, 4410 + detector.frameSize);
        final detected = detector.detect(frame);
        expect(detected, isNotNull, reason: 'midi $midi');
        expect(PitchConverter.calculateCents(detected!, midi).abs(), lessThan(5), reason: 'midi $midi: $detected Hz');
      }
    });

    test('A pluck starts strong and rings down over a few seconds', () {
      final samples = _samples(SoundSynthesizer.generateVeenaWav(261.63));
      double peak(double from, double to) {
        var p = 0.0;
        for (int i = (from * 44100).round(); i < (to * 44100).round(); i++) {
          if (samples[i].abs() > p) p = samples[i].abs();
        }
        return p;
      }

      expect(peak(0, 0.1), greaterThan(0.5));
      expect(peak(1.0, 1.2), greaterThan(0.05)); // still ringing
      expect(peak(2.6, 2.9), lessThan(peak(0, 0.1) / 4));
    });

    test('Veena notes are their own sound type', () {
      expect(SoundEvent.note(SoundType.veena, 62).cacheKey, equals('veena_62'));
    });
  });

  group('Playing', () {
    late JamRecorder recorder;
    setUp(() => recorder = JamRecorder.instance..start('Veena'));
    tearDown(() => recorder.discard());
    List<String> recorded() => recorder.stop()?.events.map((e) => e.sound.cacheKey).toList() ?? [];

    testWidgets('Pluck, then gamaka pulls up to two semitones', (tester) async {
      final veena = VeenaProvider();
      veena.pluck(64);
      veena.pull(1);
      veena.pull(1); // no change, no new note
      veena.pull(2);
      veena.pull(5); // clamped at two
      expect(veena.gamaka, equals(2));
      veena.lift();
      expect(veena.activeFret, isNull);
      expect(recorded(), equals(['veena_64', 'veena_65', 'veena_66']));
      veena.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Tala strings strum Sa, Pa, Sa\' low to high', (tester) async {
      final veena = VeenaProvider();
      veena.strumTala();
      await tester.pump(const Duration(milliseconds: 200));
      expect(recorded(), equals(['veena_60', 'veena_67', 'veena_72']));
      await tester.pump(const Duration(seconds: 1));
      veena.dispose();
    });
  });

  for (final (name, size) in [('small phone', const Size(360, 640)), ('landscape', const Size(852, 393))]) {
    testWidgets('Veena screen fits a $name; tap plucks and dragging across pulls', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: VeenaScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      final provider = tester.element(find.byType(VeenaFretboardWidget)).read<VeenaProvider>();
      final pa = find.bySemanticsLabel(RegExp(r'^Pa fret'));
      await tester.tap(pa);
      await tester.pump();
      expect(tester.takeException(), isNull);

      final landscape = size.width > size.height;
      // Drags only begin after a small slop distance, so pull a little further than 2 x 36.
      final across = landscape ? const Offset(0, 120) : const Offset(120, 0);
      final gesture = await tester.startGesture(tester.getCenter(pa));
      await gesture.moveBy(across / 3);
      await gesture.moveBy(across / 3);
      await gesture.moveBy(across / 3);
      await tester.pump();
      expect(provider.activeFret, equals(67));
      expect(provider.gamaka, equals(2));
      await gesture.up();
      await tester.pump();
      expect(provider.activeFret, isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });
  }
}
