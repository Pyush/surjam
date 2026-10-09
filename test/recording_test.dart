import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/audio/audio_engine.dart';
import 'package:surjam/core/audio/sound_event.dart';
import 'package:surjam/core/recording/jam_recorder.dart';
import 'package:surjam/core/recording/recording.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/shared/widgets/record_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async => 1);
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
    JamRecorder.instance.discard();
    for (final r in StorageService().getSavedRecordings()) {
      await StorageService().deleteRecording(r['id'] as String);
    }
  });

  group('SoundEvent', () {
    final samples = [
      SoundEvent.note(SoundType.piano, 60),
      SoundEvent.note(SoundType.guitar, 52),
      SoundEvent.flute(62, vibrato: 0.83),
      SoundEvent.drum('Kick', kit: 'edm'),
      SoundEvent.tabla('Na'),
      SoundEvent.dholak('dha'),
      SoundEvent.djLoop('Drums', filterCutoff: 0.47, bpm: 128, pack: 'indian_fusion'),
      SoundEvent.droneStart(48),
      SoundEvent.droneStopEvent,
    ];

    test('Keeps the generated-sound names the engine already used', () {
      expect(samples.map((e) => e.cacheKey), [
        'piano_60',
        'guitar_52',
        'flute_62_v8',
        'drum_edm_kick',
        'tabla_na',
        'dholak_dha',
        'dj_indian_fusion_128_drums_5',
        'drone_48',
        'drone_stop',
      ]);
    });

    test('Survives a JSON round trip', () {
      for (final e in samples) {
        expect(SoundEvent.fromJson(e.toJson()), equals(e), reason: e.cacheKey);
      }
    });

    test('Every playable sound generates WAV audio', () {
      for (final e in samples.where((e) => !e.isDroneStop)) {
        expect(String.fromCharCodes(e.generate().sublist(0, 4)), equals('RIFF'), reason: e.cacheKey);
      }
    });
  });

  group('Recording format', () {
    test('Recordings saved by older versions still load', () {
      final piano = Recording.fromJson({
        'id': '1',
        'title': 'Old piano',
        'instrument': 'Piano',
        'createdAt': '2026-10-01T10:00:00.000',
        'durationMs': 900,
        'events': [
          {'midiNote': 60, 'timestampMs': 0},
          {'midiNote': 64, 'timestampMs': 450},
        ],
      });
      expect(piano.events.map((e) => (e.timeMs, e.sound.cacheKey)), [(0, 'piano_60'), (450, 'piano_64')]);

      final tabla = Recording.fromJson({
        'id': '2',
        'title': 'Old tabla',
        'instrument': 'Tabla',
        'events': [
          {'bol': 'Dha', 'timestampMs': 0},
          {'bol': 'Na', 'timestampMs': 300},
        ],
      });
      expect(tabla.events.map((e) => e.sound.cacheKey), ['tabla_dha', 'tabla_na']);
      expect(tabla.durationMs, equals(300));
    });

    test('New recordings round-trip through storage', () async {
      final recorder = JamRecorder.instance;
      recorder.start('DJ Looper');
      // Not awaited: the mocked platform never reports the sound as prepared.
      AudioEngine().playDJLoopTrack('bass', bpm: 120, packId: 'synthwave_retro');
      final saved = await recorder.stopAndSave('Night drive');

      final loaded = Recording.fromJson(StorageService().getSavedRecordings().single);
      expect(loaded.title, equals('Night drive'));
      expect(loaded.instrument, equals('DJ Looper'));
      expect(loaded.events.single.sound, equals(saved!.events.single.sound));
    });
  });

  group('JamRecorder', () {
    test('Captures sounds the engine plays, but not metronome clicks or replays', () {
      final recorder = JamRecorder.instance;
      recorder.start('Guitar');
      AudioEngine().playGuitarNote(52);
      AudioEngine().playClick(isAccent: true);
      AudioEngine().playWithoutRecording(SoundEvent.note(SoundType.piano, 60));
      AudioEngine().startDrone(48);
      AudioEngine().stopDrone();

      final take = recorder.stop()!;
      expect(take.instrument, equals('Guitar'));
      expect(take.events.map((e) => e.sound.cacheKey), ['guitar_52', 'drone_48', 'drone_stop']);
      expect(recorder.isRecording, isFalse);
    });

    test('Nothing played means nothing to save', () {
      JamRecorder.instance.start('Violin');
      expect(JamRecorder.instance.stop(), isNull);
    });

    test('Sounds outside a recording are not captured', () {
      AudioEngine().playPianoNote(60);
      JamRecorder.instance.start('Piano');
      final take = JamRecorder.instance.stop();
      expect(take, isNull);
    });
  });

  group('Record button', () {
    Future<void> pumpButton(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Center(child: RecordButton(instrument: 'Sitar'))),
      ));
    }

    testWidgets('REC, play, STOP and Save adds the jam to the library', (tester) async {
      await pumpButton(tester);
      await tester.tap(find.text('REC'));
      await tester.pump();
      expect(find.textContaining('STOP'), findsOneWidget);

      AudioEngine().playSitarNote(60);
      await tester.tap(find.textContaining('STOP'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Raga sketch');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = StorageService().getSavedRecordings();
      expect(saved.single['title'], equals('Raga sketch'));
      expect(saved.single['instrument'], equals('Sitar'));
      expect(find.text('Saved "Raga sketch" to Jam Recordings.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 31));
    });

    testWidgets('Discard keeps nothing', (tester) async {
      await pumpButton(tester);
      await tester.tap(find.text('REC'));
      await tester.pump();
      AudioEngine().playSitarNote(62);
      await tester.tap(find.textContaining('STOP'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(StorageService().getSavedRecordings(), isEmpty);
      expect(find.text('Recording discarded.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 31));
    });

    testWidgets('Stopping before playing anything explains why nothing was saved', (tester) async {
      await pumpButton(tester);
      await tester.tap(find.text('REC'));
      await tester.pump();
      await tester.tap(find.textContaining('STOP'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Nothing was played, so nothing was saved.'), findsOneWidget);
      expect(StorageService().getSavedRecordings(), isEmpty);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
