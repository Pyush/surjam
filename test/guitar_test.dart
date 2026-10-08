import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/guitar/models/guitar_chord_model.dart';

const _rootPitchClass = {
  'C': 0, 'C#': 1, 'D': 2, 'Eb': 3, 'E': 4, 'F': 5,
  'F#': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'Bb': 10, 'B': 11,
};

// Intervals above the root for each chord-name suffix.
const _qualityIntervals = {
  ' Major': {0, 4, 7},
  ' Minor': {0, 3, 7},
  '7': {0, 4, 7, 10},
  'maj7': {0, 4, 7, 11},
  'm7': {0, 3, 7, 10},
  'sus2': {0, 2, 7},
  'sus4': {0, 5, 7},
  '5': {0, 7},
};

({int root, Set<int> intervals}) _parse(String name) {
  // Longest root first so "C#" wins over "C" and "Bb" over "B".
  final roots = _rootPitchClass.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
  final root = roots.firstWhere((r) => name.startsWith(r));
  final quality = name.substring(root.length);
  return (root: _rootPitchClass[root]!, intervals: _qualityIntervals[quality]!);
}

void main() {
  group('Guitar Chord Library', () {
    const chords = GuitarChordModel.preloadedChords;

    test('Has more than 30 chords with unique names', () {
      expect(chords.length, greaterThan(30));
      expect(chords.map((c) => c.name).toSet().length, equals(chords.length));
    });

    test('Every shape plays exactly the notes of its chord, including the root', () {
      for (final chord in chords) {
        final expected = _parse(chord.name);
        final played = chord.midiNotes.map((m) => (m - expected.root) % 12).toSet();
        // Four-note chords are commonly voiced without the 5th (e.g. open C7 = x32310).
        final required = expected.intervals.length == 4 ? (expected.intervals.toSet()..remove(7)) : expected.intervals;
        expect(expected.intervals.containsAll(played), isTrue, reason: '${chord.name} ${chord.frets} has a wrong note');
        expect(played.containsAll(required), isTrue, reason: '${chord.name} ${chord.frets} is missing a chord tone');
        expect(chord.midiNotes.length, greaterThanOrEqualTo(2), reason: chord.name);
      }
    });

    test('Every chord belongs to a palette category', () {
      for (final chord in chords) {
        expect(GuitarChordModel.categories, contains(chord.category), reason: chord.name);
      }
    });

    test('Every shape fits in the fretboard window', () {
      for (final chord in chords) {
        expect(chord.frets.length, equals(6), reason: chord.name);
        for (final fret in chord.frets.where((f) => f > 0)) {
          final column = fret - chord.baseFret + 1;
          expect(column, inInclusiveRange(1, GuitarChordModel.visibleFrets), reason: '${chord.name} ${chord.frets}');
        }
      }
    });

    test('Open shapes start at fret 1, higher shapes move the window up', () {
      final byName = {for (final c in chords) c.name: c};
      expect(byName['C Major']!.baseFret, equals(1));
      expect(byName['B Minor']!.baseFret, equals(1));
      expect(byName['C Minor']!.baseFret, equals(3));
      expect(byName['Eb Major']!.baseFret, equals(6));
    });
  });
}
