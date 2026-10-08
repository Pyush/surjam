import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/djlooper/models/dj_looper_model.dart';
import 'package:surjam/features/djlooper/providers/dj_looper_provider.dart';

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

  group('DJ Loop Launcher Unit Tests', () {
    test('DJTrackModel default tracks list contains 8 loop categories', () {
      final tracks = DJTrackModel.defaultTracks;
      expect(tracks.length, equals(8));
      expect(tracks.any((t) => t.id == 'drums'), isTrue);
      expect(tracks.any((t) => t.id == 'bass'), isTrue);
      expect(tracks.any((t) => t.id == 'vocal'), isTrue);
    });

    test('DJSoundPack preloaded sound packs list', () {
      final packs = DJSoundPack.soundPacks;
      expect(packs.length, equals(3));
      expect(packs.any((p) => p.id == 'electro_house'), isTrue);
    });

    test('DJLooperProvider track toggle and master BPM timing', () {
      final provider = DJLooperProvider();
      expect(provider.activeTrackIds.isEmpty, isTrue);

      provider.toggleTrack('drums');
      expect(provider.activeTrackIds.contains('drums'), isTrue);
      expect(provider.isMasterPlaying, isTrue);

      provider.stopAll();
      expect(provider.activeTrackIds.isEmpty, isTrue);
      expect(provider.isMasterPlaying, isFalse);
    });

    test('DJLooperProvider audio filter cutoff update', () {
      final provider = DJLooperProvider();
      expect(provider.filterCutoff, equals(1.0));

      provider.setFilterCutoff(0.5);
      expect(provider.filterCutoff, equals(0.5));
    });
  });
}
