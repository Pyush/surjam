import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/bansuri/models/bansuri_model.dart';
import 'package:surjam/features/bansuri/providers/bansuri_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async {
        return 1;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async {
        return 1;
      },
    );
  });

  group('Bansuri & Flute Studio Unit Tests', () {
    test('BansuriPreset preloaded presets exist', () {
      final presets = BansuriPreset.preloadedPresets;
      expect(presets.length, equals(3));
      expect(presets.any((p) => p.id == 'c_natural'), isTrue);
    });

    test('BansuriProvider default state is C Natural Sa', () {
      final provider = BansuriProvider();
      expect(provider.selectedPreset.id, equals('c_natural'));
      expect(provider.activeSwaraName, equals('Sa'));
      expect(provider.activeMidiNote, equals(60));
    });

    test('BansuriProvider toggling holes changes Swara pitch', () {
      final provider = BansuriProvider();
      // Initially all 6 holes closed (1.0) -> Sa (MIDI 60)
      expect(provider.activeSwaraName, equals('Sa'));

      // Toggle hole 6 to 0.0 (open)
      provider.setHoleCoverage(5, 0.0); // 5 holes closed -> Re (MIDI 62)
      expect(provider.activeSwaraName, equals('Re'));
      expect(provider.activeMidiNote, equals(62));
    });

    test('BansuriProvider octave register offset', () {
      final provider = BansuriProvider();
      provider.setRegister(2); // Taar Saptak (+12 semitones)
      expect(provider.activeMidiNote, equals(72)); // C5 High Sa
    });
  });
}
