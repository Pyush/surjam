import 'dart:typed_data';
import 'package:record/record.dart';

/// Raw microphone audio as mono 16-bit little-endian PCM.
/// Abstracted so the tuner can be tested without a real microphone.
abstract class MicrophoneInput {
  Future<bool> requestPermission();
  Future<Stream<Uint8List>> start(int sampleRate);
  Future<void> stop();
  Future<void> dispose();
}

class RecordMicrophoneInput implements MicrophoneInput {
  // Created on first use so merely constructing the tuner never touches the platform.
  AudioRecorder? _recorder;
  AudioRecorder get _activeRecorder => _recorder ??= AudioRecorder();

  @override
  Future<bool> requestPermission() => _activeRecorder.hasPermission();

  @override
  Future<Stream<Uint8List>> start(int sampleRate) {
    return _activeRecorder.startStream(RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: sampleRate,
      numChannels: 1,
    ));
  }

  @override
  Future<void> stop() async {
    await _recorder?.stop();
  }

  @override
  Future<void> dispose() async {
    await _recorder?.dispose();
    _recorder = null;
  }
}
