import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/audio/sound_event.dart';
import 'package:surjam/core/audio/sound_synthesizer.dart';
import 'package:surjam/core/lifecycle/playback_guard.dart';
import 'package:surjam/core/recording/jam_recorder.dart';
import 'package:surjam/core/recording/recording.dart';
import 'package:surjam/core/recording/recording_renderer.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/shehnai/providers/shehnai_provider.dart';
import 'package:surjam/features/shehnai/screens/shehnai_screen.dart';
import 'package:surjam/features/shehnai/widgets/shehnai_keys_widget.dart';

List<int> _pcm(Uint8List wav) {
  final data = ByteData.sublistView(wav, 44);
  return [for (int i = 0; i + 1 < data.lengthInBytes; i += 2) data.getInt16(i, Endian.little)];
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

  group('Sound', () {
    test('A held note loops seamlessly', () {
      for (final vibrato in [true, false]) {
        final pcm = _pcm(SoundSynthesizer.generateShehnaiLoopWav(293.66, vibrato: vibrato));
        expect(pcm.length / 44100, closeTo(1.2, 0.02));
        var largestStep = 0;
        for (int i = 1; i < pcm.length; i++) {
          final step = (pcm[i] - pcm[i - 1]).abs();
          if (step > largestStep) largestStep = step;
        }
        expect((pcm.first - pcm.last).abs(), lessThanOrEqualTo(largestStep), reason: 'vibrato $vibrato');
      }
    });

    test('Gamak changes the sound; the level is strong without clipping', () {
      final withGamak = SoundSynthesizer.generateShehnaiLoopWav(261.63, vibrato: true);
      final plain = SoundSynthesizer.generateShehnaiLoopWav(261.63, vibrato: false);
      expect(withGamak, isNot(equals(plain)));
      final peak = _pcm(withGamak).map((s) => s.abs()).reduce((a, b) => a > b ? a : b) / 32767;
      expect(peak, closeTo(0.7, 0.01));
    });

    test('Shehnai notes are held sounds on their own channel', () {
      final note = SoundEvent.shehnaiStart(62, vibrato: false);
      expect(note.cacheKey, equals('shehnai_62_v0'));
      expect(note.holdChannel, equals('shehnai'));
      expect(note.isHoldStart, isTrue);
      expect(SoundEvent.shehnaiStopEvent.isHoldStop, isTrue);
      expect(SoundEvent.droneStart(48).holdChannel, equals('drone'));
      expect(SoundEvent.fromJson(note.toJson()), equals(note));
    });

    test('In an exported jam, a note holds until the next one and the drone runs separately', () async {
      final scratch = await Directory.systemTemp.createTemp('shehnai_export');
      addTearDown(() => scratch.delete(recursive: true));
      final path = '${scratch.path}/jam.wav';
      RecordingRenderer.renderToFileSync(
        Recording(
          id: 'x',
          title: 'x',
          instrument: 'Shehnai',
          createdAt: DateTime(2026, 10, 9),
          durationMs: 4000,
          events: [
            TimedSoundEvent(0, SoundEvent.droneStart(48)),
            TimedSoundEvent(0, SoundEvent.shehnaiStart(60)),
            TimedSoundEvent(1000, SoundEvent.shehnaiStart(62)), // glide: replaces 60
            TimedSoundEvent(2000, SoundEvent.shehnaiStopEvent),
            TimedSoundEvent(3000, SoundEvent.droneStopEvent),
          ],
        ),
        path,
      );
      final pcm = _pcm(File(path).readAsBytesSync());
      int peak(double from, double to) =>
          pcm.sublist((from * 44100).round(), (to * 44100).round()).map((s) => s.abs()).reduce((a, b) => a > b ? a : b);
      final both = peak(0.5, 0.9);
      final droneOnly = peak(2.2, 2.9);
      expect(droneOnly, greaterThan(1000)); // drone still sounding after the shehnai stops
      expect(both, greaterThan(droneOnly)); // shehnai on top of it before that
      expect(peak(3.1, 3.9), equals(0)); // all silent once both stop
    });
  });

  group('Playing', () {
    late JamRecorder recorder;
    setUp(() => recorder = JamRecorder.instance..start('Shehnai'));
    tearDown(() => recorder.discard());

    List<String> recorded() => recorder.stop()?.events.map((e) => e.sound.cacheKey).toList() ?? [];

    testWidgets('Press, slide and release play one note at a time', (tester) async {
      final shehnai = ShehnaiProvider();
      shehnai.press(60);
      shehnai.press(60); // finger still on the same key: no retrigger
      shehnai.press(62); // slide
      shehnai.release();
      expect(shehnai.heldMidi, isNull);
      expect(recorded(), equals(['shehnai_60_v1', 'shehnai_62_v1', 'shehnai_stop']));
      shehnai.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Switching gamak mid-note switches the held note over', (tester) async {
      final shehnai = ShehnaiProvider();
      shehnai.press(64);
      shehnai.setVibrato(false);
      expect(recorded(), equals(['shehnai_64_v1', 'shehnai_64_v0']));
      shehnai.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Hiding the app silences the note and the sur drone', (tester) async {
      final shehnai = ShehnaiProvider();
      shehnai.toggleSurDrone();
      shehnai.press(67);
      PlaybackGuard.stopAll();
      expect(shehnai.heldMidi, isNull);
      expect(shehnai.surDrone, isFalse);
      expect(recorded(), equals(['drone_48', 'shehnai_67_v1', 'shehnai_stop', 'drone_stop']));
      shehnai.dispose();
      await tester.pump(const Duration(seconds: 1));
    });
  });

  for (final (name, size) in [('small phone', const Size(360, 640)), ('landscape', const Size(852, 393))]) {
    testWidgets('Sliding a finger across the keys plays a meend ($name)', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: ShehnaiScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      final keys = find.byType(ShehnaiKeysWidget);
      final rect = tester.getRect(keys);
      final landscape = size.width > size.height;
      // Start on low Sa and slide towards the high end.
      final start = landscape ? Offset(rect.left + 8, rect.center.dy) : Offset(rect.center.dx, rect.bottom - 8);
      final shift = landscape ? Offset(rect.width * 0.5, 0) : Offset(0, -rect.height * 0.5);

      final provider = tester.element(find.byType(ShehnaiKeysWidget)).read<ShehnaiProvider>();
      final gesture = await tester.startGesture(start);
      await tester.pump();
      expect(provider.heldMidi, equals(60));
      await gesture.moveBy(shift / 2);
      await gesture.moveBy(shift / 2);
      await tester.pump();
      expect(provider.heldMidi, greaterThan(67)); // glided up past Pa
      await gesture.up();
      await tester.pump();
      expect(provider.heldMidi, isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });
  }
}
