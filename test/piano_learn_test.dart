import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/learn/models/exercise_model.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  group('Piano Learn Mode', () {
    const exercise = ExerciseModel(
      id: 'ex_test',
      title: 'Test',
      subtitle: 'Test',
      category: 'Test',
      difficulty: 'Beginner',
      midiSequence: [60, 62, 64],
    );

    test('Completing an exercise saves the high score and keeps the result visible', () {
      final provider = PianoProvider();
      provider.startLearnExercise(exercise.id, exercise.midiSequence);

      for (final note in exercise.midiSequence) {
        provider.onNoteDown(note);
      }

      expect(provider.isLearnMode, isTrue);
      expect(provider.isLearnComplete, isTrue);
      expect(provider.learnScore, equals(300));
      expect(StorageService().getExerciseScore('ex_test'), equals(300));
      expect(provider.learnBestScore, equals(300));
    });

    test('Wrong notes count as mistakes and cost points, never going below zero', () {
      final provider = PianoProvider();
      provider.startLearnExercise('ex_wrong', exercise.midiSequence);

      provider.onNoteDown(61); // wrong before any points
      expect(provider.learnScore, equals(0));

      provider.onNoteDown(60); // correct
      provider.onNoteDown(65); // wrong
      expect(provider.learnMistakes, equals(2));
      expect(provider.learnScore, equals(100 - PianoProvider.pointsPerWrongNote));
    });

    test('Stopping a const exercise sequence does not throw', () {
      final provider = PianoProvider();
      provider.startLearnExercise(exercise.id, exercise.midiSequence);

      expect(() => provider.stopLearnExercise(), returnsNormally);
      expect(provider.isLearnMode, isFalse);
      expect(exercise.midiSequence, equals([60, 62, 64]));
    });

    test('A lesson moves the keyboard to the octave that contains it', () {
      final provider = PianoProvider();
      provider.setOctave(6);
      provider.startLearnExercise('ex_low', [60, 62]);
      expect(provider.octave, equals(4)); // keyboard shows C4 to B5
    });

    test('Fingering is offered for the next note and advances with it', () {
      final provider = PianoProvider();
      provider.startLearnExercise('ex_fingers', [60, 62, 64], fingers: [1, 2, 3]);
      expect(provider.targetLearnFinger, equals(1));
      provider.onNoteDown(60);
      expect(provider.targetLearnFinger, equals(2));
      provider.startLearnExercise('ex_no_fingers', [60, 62]);
      expect(provider.targetLearnFinger, isNull);
    });

    test('Restart keeps the lesson fingering and rhythm', () {
      final provider = PianoProvider();
      provider.startLearnExercise('ex_keep', [60, 62], fingers: [1, 2], beats: [1, 2], bpm: 120);
      provider.onNoteDown(60);
      provider.restartLearnExercise();
      expect(provider.targetLearnFinger, equals(1));
    });

    test('Restart resets progress for the same exercise', () {
      final provider = PianoProvider();
      provider.startLearnExercise(exercise.id, exercise.midiSequence);
      provider.onNoteDown(60);

      provider.restartLearnExercise();
      expect(provider.currentLearnStep, equals(0));
      expect(provider.learnScore, equals(0));
      expect(provider.targetLearnMidiNote, equals(60));
    });
  });

  group('Listen demo', () {
    testWidgets('Plays the rest of the lesson at its tempo, lighting each key', (tester) async {
      final provider = PianoProvider();
      // Twinkle's opening at 100 BPM: one beat = 600 ms.
      provider.startLearnExercise('song', [60, 60, 67], beats: [1, 1, 2], bpm: 100);

      provider.toggleLearnDemo();
      expect(provider.isDemoPlaying, isTrue);
      expect(provider.demoNote, equals(60));

      await tester.pump(const Duration(milliseconds: 650));
      expect(provider.demoNote, equals(60)); // second note, same key
      await tester.pump(const Duration(milliseconds: 600));
      expect(provider.demoNote, equals(67));
      await tester.pump(const Duration(milliseconds: 1250)); // two-beat note ends
      expect(provider.isDemoPlaying, isFalse);
      expect(provider.demoNote, isNull);
      // The demo never counts as the player's progress.
      expect(provider.currentLearnStep, equals(0));
      expect(provider.learnScore, equals(0));
    });

    testWidgets('Starts from the note the player has reached', (tester) async {
      final provider = PianoProvider();
      provider.startLearnExercise('song', [60, 62, 64]);
      provider.onNoteDown(60);
      provider.toggleLearnDemo();
      expect(provider.demoNote, equals(62));
      provider.toggleLearnDemo(); // tapping again stops it
      expect(provider.isDemoPlaying, isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(provider.demoNote, isNull);
    });

    testWidgets('Pressing a key stops the demo so the player can take over', (tester) async {
      final provider = PianoProvider();
      provider.startLearnExercise('song', [60, 62, 64]);
      provider.toggleLearnDemo();
      provider.onNoteDown(60);
      expect(provider.isDemoPlaying, isFalse);
      expect(provider.currentLearnStep, equals(1));
      await tester.pump(const Duration(seconds: 2));
      expect(provider.demoNote, isNull);
    });
  });
}
