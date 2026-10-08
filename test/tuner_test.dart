import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/tuner/models/tuner_model.dart';
import 'package:surjam/features/tuner/providers/tuner_provider.dart';
import 'package:surjam/features/tuner/utils/pitch_converter.dart';

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

  group('PitchConverter Utility Tests', () {
    test('A4 440 Hz converts to MIDI 69 and note A4', () {
      expect(PitchConverter.frequencyToMidi(440.0), equals(69));
      expect(PitchConverter.midiToNoteName(69), equals('A4'));
      expect(PitchConverter.midiToSargam(69), equals('Dha'));
    });

    test('Middle C 261.63 Hz converts to MIDI 60 and note C4 / Sa', () {
      expect(PitchConverter.frequencyToMidi(261.63), equals(60));
      expect(PitchConverter.midiToNoteName(60), equals('C4'));
      expect(PitchConverter.midiToSargam(60), equals('Sa'));
    });

    test('Cents deviation calculation', () {
      // Exact 440 Hz for MIDI 69 = 0 cents
      expect(PitchConverter.calculateCents(440.0, 69).abs(), lessThan(0.1));

      // Slightly lower frequency = negative cents (Flat)
      expect(PitchConverter.calculateCents(430.0, 69), lessThan(0.0));

      // Slightly higher frequency = positive cents (Sharp)
      expect(PitchConverter.calculateCents(450.0, 69), greaterThan(0.0));
    });
  });

  group('Chromatic Tuner Provider Tests', () {
    test('TunerPreset preloaded presets list', () {
      final presets = TunerPreset.preloadedPresets;
      expect(presets.length, equals(5));
      expect(presets.any((p) => p.id == 'guitar'), isTrue);
      expect(presets.any((p) => p.id == 'ukulele'), isTrue);
      expect(presets.any((p) => p.id == 'sitar'), isTrue);
    });

    test('TunerProvider in-tune vs out-of-tune state updates', () {
      final provider = TunerProvider();
      provider.setPerfectInTune();
      expect(provider.isInTune, isTrue);
      expect(provider.centsOffset.abs(), lessThan(0.1));

      provider.nukeCentsFlat();
      expect(provider.isInTune, isFalse);
      expect(provider.centsOffset, lessThan(0.0));

      provider.nukeCentsSharp();
      expect(provider.isInTune, isFalse);
      expect(provider.centsOffset, greaterThan(0.0));
    });
  });
}
