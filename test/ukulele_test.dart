import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/ukulele/models/ukulele_model.dart';
import 'package:surjam/features/ukulele/providers/ukulele_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('Ukulele Studio Unit Tests', () {
    test('UkuleleString standard tuning is G4, C4, E4, A4', () {
      final strings = UkuleleString.standardStrings;
      expect(strings.length, equals(4));
      expect(strings[0].noteName, equals('G4'));
      expect(strings[1].noteName, equals('C4'));
      expect(strings[2].noteName, equals('E4'));
      expect(strings[3].noteName, equals('A4'));
    });

    test('UkuleleChord popular chords list', () {
      final chords = UkuleleChord.popularChords;
      expect(chords.length, greaterThanOrEqualTo(8));
      expect(chords.any((c) => c.name == 'C Major'), isTrue);
      expect(chords.any((c) => c.name == 'G Major'), isTrue);
    });

    test('UkuleleProvider chord selection and string plucking', () {
      final provider = UkuleleProvider();
      expect(provider.selectedChord.name, equals('C Major'));

      final gMajor = UkuleleChord.popularChords.firstWhere((c) => c.id == 'g_maj');
      provider.selectChord(gMajor);
      expect(provider.selectedChord.name, equals('G Major'));

      provider.pluckString(3); // String 4 (A4)
      expect(provider.activePluckedString, equals(3));
    });
  });
}
