import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/learn/models/exercise_model.dart';

const _whiteKeyPitchClasses = {0, 2, 4, 5, 7, 9, 11};

ExerciseModel _lesson(String id) => ExerciseModel.preloadedExercises.firstWhere((e) => e.id == id);

Set<int> _pitchClasses(ExerciseModel e) => e.midiSequence.map((m) => m % 12).toSet();

void main() {
  const lessons = ExerciseModel.preloadedExercises;

  group('Lesson library structure', () {
    test('Every lesson has a unique id and a known category, and every category has lessons', () {
      expect(lessons.map((e) => e.id).toSet().length, equals(lessons.length));
      for (final e in lessons) {
        expect(ExerciseModel.categories, contains(e.category), reason: e.id);
      }
      for (final category in ExerciseModel.categories) {
        expect(ExerciseModel.inCategory(category), isNotEmpty, reason: category);
      }
    });

    test('Original lesson ids are kept so saved high scores still apply', () {
      for (final id in ['ex_c_major', 'ex_sargam', 'ex_chords', 'ex_arpeggio']) {
        expect(lessons.any((e) => e.id == id), isTrue, reason: id);
      }
    });

    test('Every lesson fits on the two-octave keyboard it is shown on', () {
      for (final e in lessons) {
        final lowest = e.midiSequence.reduce((a, b) => a < b ? a : b);
        final firstKey = (lowest ~/ 12) * 12; // the C the keyboard starts from
        for (final note in e.midiSequence) {
          expect(note, inInclusiveRange(firstKey, firstKey + 23), reason: '${e.id}: $note');
        }
      }
    });

    test('Fingering and rhythm data line up with the notes', () {
      for (final e in lessons) {
        if (e.fingers != null) {
          expect(e.fingers!.length, equals(e.midiSequence.length), reason: '${e.id} fingers');
          expect(e.fingers, everyElement(inInclusiveRange(1, 5)), reason: e.id);
        }
        if (e.beats != null) {
          expect(e.beats!.length, equals(e.midiSequence.length), reason: '${e.id} beats');
          expect(e.beats, everyElement(greaterThan(0)), reason: e.id);
        }
        expect(e.bpm, inInclusiveRange(40, 200), reason: e.id);
      }
    });

    test('Every song has a rhythm for its Listen demo', () {
      for (final song in ExerciseModel.inCategory(ExerciseModel.songs)) {
        expect(song.beats, isNotNull, reason: song.id);
      }
    });
  });

  group('Musical content', () {
    test('Scales have exactly the right notes for their key', () {
      expect(_pitchClasses(_lesson('ex_c_major')), equals(_whiteKeyPitchClasses));
      expect(_pitchClasses(_lesson('ex_a_minor')), equals(_whiteKeyPitchClasses));
      expect(_pitchClasses(_lesson('ex_g_major')), equals({7, 9, 11, 0, 2, 4, 6})); // F#
      expect(_pitchClasses(_lesson('ex_d_major')), equals({2, 4, 6, 7, 9, 11, 1})); // F#, C#
      expect(_pitchClasses(_lesson('ex_f_major')), equals({5, 7, 9, 10, 0, 2, 4})); // Bb
      for (final id in ['ex_c_major', 'ex_g_major', 'ex_d_major', 'ex_f_major', 'ex_a_minor']) {
        final notes = _lesson(id).midiSequence;
        expect(notes.last - notes.first, equals(12), reason: '$id spans one octave');
        for (int i = 1; i < notes.length; i++) {
          expect(notes[i], greaterThan(notes[i - 1]), reason: '$id ascends');
        }
      }
    });

    test('Major scales follow the whole-whole-half-whole-whole-whole-half pattern', () {
      for (final id in ['ex_c_major', 'ex_g_major', 'ex_d_major', 'ex_f_major']) {
        final notes = _lesson(id).midiSequence;
        final steps = [for (int i = 1; i < notes.length; i++) notes[i] - notes[i - 1]];
        expect(steps, equals([2, 2, 1, 2, 2, 2, 1]), reason: id);
      }
    });

    test('Chromatic climb covers every key from C4 to C5 and back', () {
      final notes = _lesson('ex_chromatic').midiSequence;
      expect(notes, equals([...List.generate(13, (i) => 60 + i), ...List.generate(12, (i) => 71 - i)]));
    });

    test('Sargam alankars use only shuddh swaras from Sa to Sa\'', () {
      for (final e in ExerciseModel.inCategory(ExerciseModel.sargam)) {
        expect(_pitchClasses(e).difference(_whiteKeyPitchClasses), isEmpty, reason: e.id);
        expect(e.midiSequence, everyElement(inInclusiveRange(60, 72)), reason: e.id);
        expect(e.midiSequence.first, equals(60), reason: '${e.id} starts on Sa');
        expect(e.midiSequence.last, equals(60), reason: '${e.id} returns to Sa');
      }
    });

    test('Songs start with their well-known opening notes', () {
      // C4=60 D=62 E=64 F=65 G=67 A=69
      expect(_lesson('song_twinkle').midiSequence.take(7), equals([60, 60, 67, 67, 69, 69, 67]));
      expect(_lesson('song_mary').midiSequence.take(7), equals([64, 62, 60, 62, 64, 64, 64]));
      expect(_lesson('song_ode_to_joy').midiSequence.take(8), equals([64, 64, 65, 67, 67, 65, 64, 62]));
      expect(_lesson('song_london_bridge').midiSequence.take(7), equals([67, 69, 67, 65, 64, 65, 67]));
      expect(_lesson('song_frere_jacques').midiSequence.take(4), equals([72, 74, 76, 72]));
      expect(_lesson('song_jingle_bells').midiSequence.take(11), equals([64, 64, 64, 64, 64, 64, 64, 67, 60, 62, 64]));
      expect(_lesson('song_row_your_boat').midiSequence.take(5), equals([60, 60, 60, 62, 64]));
    });

    test('Songs end on their home note', () {
      for (final id in ['song_twinkle', 'song_mary', 'song_ode_to_joy', 'song_london_bridge', 'song_row_your_boat']) {
        expect(_lesson(id).midiSequence.last % 12, equals(0), reason: '$id ends on C');
      }
    });
  });
}
