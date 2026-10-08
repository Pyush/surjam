import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/tuner/models/tuner_model.dart';
import 'package:surjam/features/tuner/providers/tuner_provider.dart';
import 'package:surjam/features/tuner/utils/microphone_input.dart';
import 'package:surjam/features/tuner/utils/pitch_converter.dart';
import 'package:surjam/features/tuner/utils/pitch_detector.dart';

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

    test('Silent tuner shows no pitch and is not "in tune"', () {
      final provider = TunerProvider(microphone: FakeMicrophone());
      expect(provider.hasSignal, isFalse);
      expect(provider.isInTune, isFalse);
      provider.dispose();
    });

    test('Microphone audio of an in-tune A string is detected as in tune', () async {
      final mic = FakeMicrophone();
      final provider = TunerProvider(microphone: mic);
      await provider.startListening();
      expect(provider.status, equals(TunerStatus.listening));

      mic.emit(pcm16Sine(110.0, seconds: 0.5));
      await Future<void>.delayed(Duration.zero);

      expect(provider.hasSignal, isTrue);
      expect(provider.selectedTargetNote.label, equals('5-A2'));
      expect(provider.isInTune, isTrue);
      expect(provider.currentFrequency, closeTo(110.0, 0.5));
      provider.dispose();
    });

    test('Flat and sharp strings move the needle the right way', () {
      final provider = TunerProvider(microphone: FakeMicrophone());
      provider.addPcm16Audio(pcm16Sine(196.0 * 0.985, seconds: 0.5)); // G3 about 26 cents flat
      expect(provider.selectedTargetNote.label, equals('3-G3'));
      expect(provider.isInTune, isFalse);
      expect(provider.centsOffset, closeTo(-26.2, 2.0));

      provider.addPcm16Audio(pcm16Sine(196.0 * 1.015, seconds: 0.5)); // about 26 cents sharp
      expect(provider.centsOffset, closeTo(25.8, 2.0));
      provider.dispose();
    });

    test('Audio split mid-sample across chunks is decoded correctly', () {
      final provider = TunerProvider(microphone: FakeMicrophone());
      final bytes = pcm16Sine(329.63, seconds: 0.5);
      for (int i = 0; i < bytes.length; i += 333) {
        provider.addPcm16Audio(Uint8List.sublistView(bytes, i, (i + 333).clamp(0, bytes.length)));
      }
      expect(provider.selectedTargetNote.label, equals('1-E4'));
      expect(provider.isInTune, isTrue);
      provider.dispose();
    });

    test('A manually chosen string stays selected', () {
      final provider = TunerProvider(microphone: FakeMicrophone());
      final lowE = provider.selectedPreset.targetNotes.first;
      provider.setTargetNote(lowE);
      provider.addPcm16Audio(pcm16Sine(110.0, seconds: 0.5)); // A2, far above E2

      expect(provider.selectedTargetNote.label, equals('6-E2'));
      expect(provider.centsOffset, equals(50.0)); // pinned fully sharp
      provider.dispose();
    });

    test('Denied microphone permission is reported, not crashed on', () async {
      final provider = TunerProvider(microphone: FakeMicrophone(granted: false));
      await provider.startListening();
      expect(provider.status, equals(TunerStatus.permissionDenied));
      expect(provider.isTuningActive, isFalse);
      provider.dispose();
    });
  });

  group('PitchDetector (YIN)', () {
    const detector = PitchDetector(sampleRate: 22050);

    Float64List tone(double frequency, {List<double> harmonics = const [1.0]}) {
      return Float64List.fromList(List.generate(detector.frameSize, (i) {
        double v = 0;
        for (int h = 0; h < harmonics.length; h++) {
          v += harmonics[h] * sin(2 * pi * frequency * (h + 1) * i / 22050);
        }
        return 0.5 * v;
      }));
    }

    test('Detects instrument range within 2 cents', () {
      for (final f in [82.41, 110.0, 196.0, 261.63, 440.0, 659.26, 1046.5]) {
        final detected = detector.detect(tone(f));
        expect(detected, isNotNull, reason: '$f Hz');
        expect(PitchConverter.calculateCents(detected!, PitchConverter.frequencyToMidi(f)).abs(),
            lessThan(2.0), reason: '$f Hz detected as $detected');
      }
    });

    test('Finds the fundamental of a harmonic-rich tone, not an overtone', () {
      final detected = detector.detect(tone(110.0, harmonics: [0.4, 1.0, 0.6, 0.3]));
      expect(detected, closeTo(110.0, 1.0));
    });

    test('Ignores silence and noise', () {
      expect(detector.detect(Float64List(detector.frameSize)), isNull);
      final rng = Random(1);
      final noise = Float64List.fromList(List.generate(detector.frameSize, (_) => rng.nextDouble() - 0.5));
      expect(detector.detect(noise), isNull);
    });
  });
}

class FakeMicrophone implements MicrophoneInput {
  final bool granted;
  final StreamController<Uint8List> _controller = StreamController<Uint8List>();

  FakeMicrophone({this.granted = true});

  void emit(Uint8List bytes) => _controller.add(bytes);

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<Stream<Uint8List>> start(int sampleRate) async => _controller.stream;

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async => _controller.close();
}

/// Mono 16-bit little-endian PCM at the tuner's capture rate.
Uint8List pcm16Sine(double frequency, {required double seconds}) {
  const rate = TunerProvider.captureSampleRate;
  final count = (rate * seconds).toInt();
  final data = ByteData(count * 2);
  for (int i = 0; i < count; i++) {
    data.setInt16(i * 2, (0.5 * 32767 * sin(2 * pi * frequency * i / rate)).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}
