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
}
