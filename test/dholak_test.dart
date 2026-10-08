import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/dholak/models/dholak_model.dart';
import 'package:surjam/features/dholak/providers/dholak_provider.dart';

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

  group('Dholak & Dhol Studio Unit Tests', () {
    test('DholakStroke stroke palette contains Taash and Dagga', () {
      final strokes = DholakStroke.allStrokes;
      expect(strokes.length, greaterThanOrEqualTo(8));
      expect(strokes.any((s) => s.id == 'taash'), isTrue);
      expect(strokes.any((s) => s.id == 'dagga'), isTrue);
    });

    test('DholakFolkPattern contains Garba and Bhangra presets', () {
      final patterns = DholakFolkPattern.preloadedPatterns;
      expect(patterns.length, equals(4));
      expect(patterns.any((p) => p.id == 'garba'), isTrue);
      expect(patterns.any((p) => p.id == 'bhangra'), isTrue);
    });

    test('DholakProvider stroke trigger updates active hit head', () {
      final provider = DholakProvider();
      final taashStroke = DholakStroke.allStrokes.firstWhere((s) => s.id == 'taash');
      provider.playStroke(taashStroke);

      expect(provider.activeStrokeId, equals('taash'));
      expect(provider.activeHitHead, equals('treble'));
    });

    test('DholakProvider loop toggle starts beat sequence', () {
      final provider = DholakProvider();
      expect(provider.isLoopPlaying, isFalse);

      provider.toggleLoop();
      expect(provider.isLoopPlaying, isTrue);

      provider.stopLoop();
      expect(provider.isLoopPlaying, isFalse);
    });
  });
}
