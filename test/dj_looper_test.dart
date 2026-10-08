import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/core/audio/sound_synthesizer.dart';
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

    test('DJ loops are exactly one bar long at any BPM', () {
      for (final bpm in [90, 124, 160]) {
        final bytes = SoundSynthesizer.generateDJLoopWav('drums', bpm: bpm);
        final expectedSamples = (SoundSynthesizer.sampleRate * 4 * 60.0 / bpm).toInt();
        expect(bytes.length, equals(44 + expectedSamples * 2), reason: 'bpm $bpm');
      }
    });

    test('Each sound pack produces different audio', () {
      for (final track in ['chords', 'lead', 'piano_stab']) {
        final packs = DJSoundPack.soundPacks
            .map((p) => SoundSynthesizer.generateDJLoopWav(track, bpm: 120, packId: p.id))
            .toList();
        expect(listEquals(packs[0], packs[1]), isFalse, reason: track);
        expect(listEquals(packs[0], packs[2]), isFalse, reason: track);
        expect(listEquals(packs[1], packs[2]), isFalse, reason: track);
      }
    });

    test('Low-pass filter removes high-frequency content', () {
      // Sum of absolute sample-to-sample differences rises with high-frequency energy.
      double roughness(Uint8List wav) {
        final data = ByteData.sublistView(wav);
        double total = 0;
        for (int i = 46; i + 1 < wav.length; i += 2) {
          total += (data.getInt16(i, Endian.little) - data.getInt16(i - 2, Endian.little)).abs();
        }
        return total;
      }

      final open = SoundSynthesizer.generateDJLoopWav('percussion', filterCutoff: 1.0);
      final closed = SoundSynthesizer.generateDJLoopWav('percussion', filterCutoff: 0.1);
      expect(roughness(closed), lessThan(roughness(open) * 0.5));
    });

    test('Pack and BPM changes are applied without stopping playback', () {
      final provider = DJLooperProvider();
      provider.toggleTrack('drums');
      provider.setMasterBpm(140);
      provider.setSoundPack(DJSoundPack.soundPacks[2]);

      expect(provider.isMasterPlaying, isTrue);
      expect(provider.masterBpm, equals(128));
      expect(provider.selectedPack.id, equals('indian_fusion'));
      provider.stopAll();
    });

    test('DJLooperProvider audio filter cutoff update', () {
      final provider = DJLooperProvider();
      expect(provider.filterCutoff, equals(1.0));

      provider.setFilterCutoff(0.5);
      expect(provider.filterCutoff, equals(0.5));
    });
  });
}
