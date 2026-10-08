import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/xylophone/models/xylophone_model.dart';
import 'package:surjam/features/xylophone/providers/xylophone_provider.dart';

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

  group('Rainbow Xylophone Studio Unit Tests', () {
    test('XylophoneKeyModel contains 15 keys across 2 octaves', () {
      final keys = XylophoneKeyModel.defaultKeys;
      expect(keys.length, equals(15));
      expect(keys.first.noteName, equals('C4'));
      expect(keys.last.noteName, equals('C6'));
    });

    test('XylophoneProvider label mode toggle', () {
      final provider = XylophoneProvider();
      expect(provider.useSargam, isFalse);

      provider.toggleLabelMode();
      expect(provider.useSargam, isTrue);
    });

    test('XylophoneProvider key strike updates active note', () {
      final provider = XylophoneProvider();
      provider.playKey(60); // C4

      expect(provider.activeKeyMidi, equals(60));
    });
  });
}
