import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/core/audio/audio_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];

  setUpAll(() {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (call) async {
          calls.add(call);
          return 1;
        },
      );
    }
  });

  List<MethodCall> sourceCalls() => calls.where((c) => c.method.startsWith('setSource')).toList();

  // The mocked platform never reports a source as prepared, so playback futures don't
  // complete in tests; start them and wait until the sources have been handed over.
  Future<List<MethodCall>> play(List<Future<void> Function()> sounds) async {
    final before = sourceCalls().length;
    for (final sound in sounds) {
      unawaited(sound());
      // Sequential so each sound has been generated before the next starts.
      for (int i = 0; i < 200 && sourceCalls().length == before + sounds.indexOf(sound); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }
    return sourceCalls().sublist(before);
  }

  test('Notes play from a WAV file in low-latency players, never from raw bytes', () async {
    // Android low-latency mode rejects byte sources, which once left every instrument silent.
    final sources = await play([() => AudioEngine().playPianoNote(60), () => AudioEngine().playDrumPad('kick', kit: 'edm')]);

    expect(sources.length, equals(2));
    for (final call in sources) {
      expect(call.method, equals('setSourceUrl'));
      final args = call.arguments as Map;
      expect(args['isLocal'], isTrue);
      final path = args['url'] as String;
      expect(path, endsWith('.wav'));
      expect(String.fromCharCodes(File(path).readAsBytesSync().sublist(0, 4)), equals('RIFF'));
    }
    final modes = calls.where((c) => c.method == 'setPlayerMode').map((c) => (c.arguments as Map)['playerMode']);
    expect(modes, isNotEmpty);
    expect(modes, everyElement(contains('lowLatency')));
  });

  test('Each sound is generated once and reused', () async {
    final sources = await play([() => AudioEngine().playGuitarNote(52), () => AudioEngine().playGuitarNote(52)]);
    expect(sources.length, equals(2));
    expect(sources.map((c) => (c.arguments as Map)['url']).toSet().length, equals(1));
  });

  test('Flute vibrato changes the sound that plays', () async {
    final sources = await play([
      () => AudioEngine().playFluteNote(62, vibratoAmount: 0.0),
      () => AudioEngine().playFluteNote(62, vibratoAmount: 0.8),
    ]);
    final paths = sources.map((c) => (c.arguments as Map)['url'] as String).toList();
    expect(paths.toSet().length, equals(2));
    expect(File(paths[0]).readAsBytesSync(), isNot(equals(File(paths[1]).readAsBytesSync())));
  });
}
