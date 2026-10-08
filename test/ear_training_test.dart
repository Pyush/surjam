import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/musictheory/models/quiz_model.dart';

void main() {
  group('Ear Training Question Generator', () {
    final rounds = [for (int seed = 0; seed < 50; seed++) QuizQuestion.generateRound(Random(seed))];
    final allQuestions = rounds.expand((r) => r).toList();

    test('A round has 10 questions covering all four question types', () {
      for (final round in rounds) {
        expect(round.length, equals(10));
        expect(round.map((q) => q.category).toSet(), equals({'Interval', 'Sargam', 'Chord', 'Tabla'}));
      }
    });

    test('Every question has 4 unique options including the correct answer', () {
      for (final q in allQuestions) {
        expect(q.options.length, equals(4));
        expect(q.options.toSet().length, equals(4));
        expect(q.correctOptionIndex, inInclusiveRange(0, 3));
      }
    });

    test('The sound played always matches the correct answer', () {
      for (final q in allQuestions) {
        switch (q.category) {
          case 'Interval':
            expect(q.notes.length, equals(2));
            expect(q.notes[1] - q.notes[0], equals(QuizQuestion.intervals[q.correctAnswer]));
            break;
          case 'Sargam':
            expect(q.notes, equals([60, 60 + QuizQuestion.swaras[q.correctAnswer]!]));
            break;
          case 'Chord':
            expect(q.soundMode, equals(QuizSoundMode.together));
            final shape = q.notes.map((n) => n - q.notes.first).toList();
            expect(shape, equals(QuizQuestion.chordQualities[q.correctAnswer]));
            break;
          case 'Tabla':
            expect(q.soundBol, equals(q.correctAnswer.toLowerCase()));
            break;
          default:
            fail('Unknown category ${q.category}');
        }
      }
    });

    test('Rounds vary: different questions and answer positions', () {
      final signatures = rounds.map((r) => r.map((q) => '${q.category}:${q.correctAnswer}').join('|')).toSet();
      expect(signatures.length, greaterThan(45));
      expect(allQuestions.map((q) => q.correctOptionIndex).toSet(), equals({0, 1, 2, 3}));
    });
  });
}
