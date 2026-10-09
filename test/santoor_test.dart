import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/audio/audio_engine.dart';
import 'package:surjam/core/audio/sound_event.dart';
import 'package:surjam/core/audio/sound_synthesizer.dart';
import 'package:surjam/core/lifecycle/playback_guard.dart';
import 'package:surjam/core/recording/jam_recorder.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/santoor/models/santoor_model.dart';
import 'package:surjam/features/santoor/providers/santoor_provider.dart';
import 'package:surjam/features/santoor/screens/santoor_screen.dart';

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

  group('Thaats and tuning', () {
    test('Ten thaats, each with one form of every swara and fixed Sa and Pa', () {
      expect(Thaat.all.length, equals(10));
      expect(Thaat.all.map((t) => t.id).toSet().length, equals(10));
      const forms = [
        {0}, {1, 2}, {3, 4}, {5, 6}, {7}, {8, 9}, {10, 11}, // Sa Re Ga Ma Pa Dha Ni
      ];
      for (final thaat in Thaat.all) {
        expect(thaat.intervals.length, equals(7), reason: thaat.id);
        for (int i = 0; i < 7; i++) {
          expect(forms[i], contains(thaat.intervals[i]), reason: '${thaat.id} swara $i');
        }
      }
      expect(Thaat.all.firstWhere((t) => t.id == 'bilawal').intervals, equals([0, 2, 4, 5, 7, 9, 11]));
      expect(Thaat.all.firstWhere((t) => t.id == 'kalyan').intervals, equals([0, 2, 4, 6, 7, 9, 11]));
      expect(Thaat.all.firstWhere((t) => t.id == 'bhairavi').intervals, equals([0, 1, 3, 5, 7, 8, 10]));
    });

    test('Strings run two octaves from Sa to Sa\'\' in the thaat', () {
      for (final thaat in Thaat.all) {
        final strings = SantoorTuning.strings(thaat);
        expect(strings.length, equals(15), reason: thaat.id);
        expect(strings.first, equals(60));
        expect(strings.last, equals(84));
        for (int i = 1; i < strings.length; i++) {
          expect(strings[i], greaterThan(strings[i - 1]), reason: thaat.id);
        }
        expect(strings.map((m) => m % 12).toSet(), equals(thaat.intervals.toSet()), reason: thaat.id);
      }
    });

    test('Labels show octave marks and komal/tivra forms', () {
      expect(SantoorTuning.sargamLabel(60), equals('Sa'));
      expect(SantoorTuning.sargamLabel(72), equals("Sa'"));
      expect(SantoorTuning.sargamLabel(84), equals("Sa''"));
      expect(SantoorTuning.sargamLabel(66), equals('MA')); // tivra Ma
      expect(SantoorTuning.sargamLabel(61), equals('re')); // komal Re
      expect(SantoorTuning.englishLabel(60), equals('C4'));
      expect(SantoorTuning.englishLabel(78), equals('F#5'));
    });
  });

  group('Sound', () {
    double peak(Uint8List wav, double from, double to) {
      final data = ByteData.sublistView(wav, 44);
      var p = 0;
      for (int i = (from * 44100).round(); i < (to * 44100).round(); i++) {
        final v = data.getInt16(i * 2, Endian.little).abs();
        if (v > p) p = v;
      }
      return p / 32767;
    }

    test('A struck santoor string rings out and decays', () {
      final wav = SoundSynthesizer.generateSantoorWav(261.63);
      expect(peak(wav, 0.0, 0.1), greaterThan(0.3));
      expect(peak(wav, 1.8, 2.1), lessThan(peak(wav, 0.0, 0.1) / 3));
      expect(peak(wav, 1.0, 1.2), greaterThan(0.02)); // still ringing a second later
    });

    test('Santoor notes are their own sound type', () {
      final note = SoundEvent.note(SoundType.santoor, 60);
      expect(note.cacheKey, equals('santoor_60'));
      expect(SoundEvent.fromJson(note.toJson()), equals(note));
    });

    test('Preloading writes the sounds in the background', () async {
      final tuning = SantoorTuning.strings(Thaat.all.first);
      await AudioEngine().preload(tuning.map((m) => SoundEvent.note(SoundType.santoor, m)));
      final dir = Directory('${(await AudioEngine.baseDirectoryProvider()).path}/surjam_sounds');
      for (final midi in tuning) {
        expect(File('${dir.path}/santoor_$midi.wav').existsSync(), isTrue, reason: '$midi');
      }
    });
  });

  group('Playing', () {
    testWidgets('Holding a string rolls a tremolo until released', (tester) async {
      final santoor = SantoorProvider();
      final recorder = JamRecorder.instance..start('Santoor');

      santoor.startTremolo(67);
      await tester.pump(const Duration(seconds: 1));
      final strokes = recorder.eventCount;
      expect(strokes, inInclusiveRange(10, 13)); // about 11 a second

      santoor.stopTremolo();
      await tester.pump(const Duration(seconds: 1));
      expect(recorder.eventCount, equals(strokes));
      recorder.discard();
      santoor.dispose();
      // Let the audio player's timers from the strokes run out.
      await tester.pump(const Duration(seconds: 31));
    });

    testWidgets('A tremolo stops when the app is hidden', (tester) async {
      final santoor = SantoorProvider();
      santoor.startTremolo(60);
      PlaybackGuard.stopAll();
      expect(santoor.tremoloMidi, isNull);
      await tester.pump(const Duration(seconds: 1));
      santoor.dispose();
    });

    testWidgets('Changing thaat retunes the strings', (tester) async {
      final santoor = SantoorProvider();
      santoor.setThaat(Thaat.all.firstWhere((t) => t.id == 'kalyan'));
      expect(santoor.strings, contains(66)); // tivra Ma
      expect(santoor.strings, isNot(contains(65)));
      santoor.dispose();
    });
  });

  for (final (name, size) in [('small phone', const Size(360, 640)), ('landscape', const Size(852, 393))]) {
    testWidgets('Santoor screen fits a $name and strikes on tap', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: SantoorScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Sa'), findsOneWidget);
      expect(find.text("Sa''"), findsOneWidget);

      await tester.tap(find.text('Kalyan'));
      await tester.pump();
      expect(find.text('MA'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(RegExp(r'^Pa string')));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });
  }
}
