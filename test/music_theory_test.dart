import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/piano/models/piano_key_model.dart';
import 'package:surjam/features/piano/models/chord_scale_data.dart';
import 'package:surjam/features/tabla/models/taal_model.dart';

void main() {
  group('Piano Key Model Tests', () {
    test('Middle C (MIDI 60) maps correctly to C4 and Sargam Sa', () {
      final key = PianoKeyModel.fromMidi(60);
      expect(key.noteName, 'C4');
      expect(key.sargamLabel, 'Sa');
      expect(key.isBlack, false);
      expect(key.octave, 4);
    });

    test('C#4 (MIDI 61) maps correctly to black key and re', () {
      final key = PianoKeyModel.fromMidi(61);
      expect(key.noteName, 'C#4');
      expect(key.sargamLabel, 're');
      expect(key.isBlack, true);
      expect(key.octave, 4);
    });
  });

  group('Music Theory Data Tests', () {
    test('C Major scale contains 7 intervals', () {
      final scale = MusicTheoryData.scales['C Major'];
      expect(scale, isNotNull);
      expect(scale!.length, 7);
      expect(scale, equals([0, 2, 4, 5, 7, 9, 11]));
    });

    test('Raag Bhairav scale contains correct notes', () {
      final bhairav = MusicTheoryData.scales['Raag Bhairav'];
      expect(bhairav, isNotNull);
      expect(bhairav, equals([0, 1, 4, 5, 7, 8, 11]));
    });

    test('C Major chord triad contains MIDI 60, 64, 67', () {
      final chord = MusicTheoryData.chords['C Major'];
      expect(chord, isNotNull);
      expect(chord, equals([60, 64, 67]));
    });
  });

  group('Tabla Taal Model Tests', () {
    test('Teentaal has 16 beats with Sam on first beat', () {
      final teentaal = TaalModel.preloadedTaals.firstWhere((t) => t.id == 'teentaal');
      expect(teentaal.totalBeats, 16);
      expect(teentaal.beats[0].bol, 'Dha');
      expect(teentaal.beats[0].isSam, true);
    });

    test('Dadra has 6 beats with Khali on 4th beat', () {
      final dadra = TaalModel.preloadedTaals.firstWhere((t) => t.id == 'dadra');
      expect(dadra.totalBeats, 6);
      expect(dadra.beats[3].bol, 'Dha');
      expect(dadra.beats[3].isKhali, true);
    });
  });
}
