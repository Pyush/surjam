import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/sitar/models/sitar_raga_model.dart';
import 'package:surjam/features/sitar/providers/sitar_provider.dart';

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

  group('Sitar Studio Unit Tests', () {
    test('SitarRagaModel contains preloaded Ragas', () {
      final ragas = SitarRagaModel.preloadedRagas;
      expect(ragas.length, greaterThanOrEqualTo(4));
      expect(ragas.any((r) => r.id == 'yaman'), isTrue);
      expect(ragas.any((r) => r.id == 'bhairavi'), isTrue);
    });

    test('SitarProvider default Raga is Raag Yaman', () {
      final provider = SitarProvider();
      expect(provider.selectedRaga.id, equals('yaman'));
      expect(provider.rootMidi, equals(60));
    });

    test('SitarProvider correctly validates notes in Raag Yaman', () {
      final provider = SitarProvider(); // Raag Yaman intervals: [0, 2, 4, 6, 7, 9, 11]
      expect(provider.isFretInRaga(0), isTrue); // Sa
      expect(provider.isFretInRaga(1), isFalse); // komal re is absent in Yaman
      expect(provider.isFretInRaga(4), isTrue); // Shuddh Ga
      expect(provider.isFretInRaga(6), isTrue); // Teevra Ma
    });

    test('SitarProvider Meend pitch bend calculation', () {
      final provider = SitarProvider();
      provider.pluckFret(0, bend: 2); // Sa + 2 semitones bend = Re
      expect(provider.bendSemitones, equals(2));
      expect(provider.activeNoteName, equals('Re'));
    });

    test('SitarProvider has a mandra Ni fret below Sa matching the Raga', () {
      final provider = SitarProvider(); // Yaman uses Shuddh Ni
      expect(provider.fretSemitones.first, equals(-1));
      expect(provider.fretSemitones.length, equals(14));
      expect(provider.isFretInRaga(-1), isTrue);

      provider.setRaga(SitarRagaModel.preloadedRagas.firstWhere((r) => r.id == 'bhairavi'));
      expect(provider.fretSemitones.first, equals(-2)); // komal ni
      expect(provider.isFretInRaga(-2), isTrue);
    });

    test('SitarProvider labels swaras with octave marks', () {
      expect(SitarProvider.swaraLabel(-1), equals('Ni.'));
      expect(SitarProvider.swaraLabel(-2), equals('ni.'));
      expect(SitarProvider.swaraLabel(7), equals('Pa'));
      expect(SitarProvider.swaraLabel(12), equals('Sa\''));
      expect(SitarProvider.swaraLabel(14), equals('Re\''));

      final provider = SitarProvider();
      provider.pluckFret(-1);
      expect(provider.activeNoteName, equals('Ni.'));
      provider.pluckFret(11, bend: 3); // Ni + 3 semitones = high Re
      expect(provider.activeNoteName, equals('Re\''));
    });
  });
}
