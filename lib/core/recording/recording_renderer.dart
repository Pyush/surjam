import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import '../audio/sound_event.dart';
import '../audio/sound_synthesizer.dart';
import 'recording.dart';

/// Mixes a recording into a mono 16-bit WAV file, the same sounds at the same moments,
/// so a jam can be shared outside the app.
///
/// Mixing runs on a background isolate and in fixed-size blocks written straight to disk,
/// so even a ten-minute jam needs only a few megabytes of memory.
class RecordingRenderer {
  RecordingRenderer._();

  static const int sampleRate = SoundSynthesizer.sampleRate;
  static const int _blockSamples = sampleRate * 10;

  /// Overall level before the limiter; leaves headroom for chords and layered loops.
  static const double _masterGain = 0.8;

  /// Renders [recording] to [path] without blocking the UI.
  static Future<void> renderToFile(Recording recording, String path) {
    final json = recording.toJson();
    return Isolate.run(() => renderToFileSync(Recording.fromJson(json), path));
  }

  /// Synchronous rendering, used by [renderToFile] on its isolate and by tests.
  static void renderToFileSync(Recording recording, String path) {
    final voices = _voices(recording);
    final totalSamples = voices.fold<int>(
      _msToSamples(recording.durationMs),
      (end, v) => max(end, v.start + v.length),
    ) + sampleRate ~/ 4; // short tail so the last note is not cut abruptly

    final file = File(path).openSync(mode: FileMode.write);
    try {
      file.writeFromSync(_wavHeader(totalSamples));
      final block = Float64List(_blockSamples);
      final out = ByteData(_blockSamples * 2);
      for (int blockStart = 0; blockStart < totalSamples; blockStart += _blockSamples) {
        final blockLength = min(_blockSamples, totalSamples - blockStart);
        block.fillRange(0, blockLength, 0);
        for (final voice in voices) {
          voice.mixInto(block, blockStart, blockLength);
        }
        for (int i = 0; i < blockLength; i++) {
          out.setInt16(i * 2, (_limit(block[i] * _masterGain) * 32767).round(), Endian.little);
        }
        file.writeFromSync(out.buffer.asUint8List(0, blockLength * 2));
      }
    } finally {
      file.closeSync();
    }
  }

  /// Every sound in the recording, placed on the timeline. A held sound (drone, shehnai note)
  /// becomes one voice that loops until the next change on its channel or the end.
  static List<_Voice> _voices(Recording recording) {
    final samplesByKey = <String, Float32List>{};
    Float32List samplesOf(SoundEvent sound) => samplesByKey.putIfAbsent(sound.cacheKey, () => _decodeWav(sound.generate()));

    final voices = <_Voice>[];
    final events = recording.events;
    final recordingEnd = max(_msToSamples(recording.durationMs), events.isEmpty ? 0 : _msToSamples(events.last.timeMs));
    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      final start = _msToSamples(event.timeMs);
      final sound = event.sound;
      if (sound.isHoldStop) continue;
      if (sound.isHoldStart) {
        // Held until the next start or stop on the same channel, or the end of the recording.
        var end = recordingEnd;
        for (int j = i + 1; j < events.length; j++) {
          if (events[j].sound.holdChannel == sound.holdChannel) {
            end = _msToSamples(events[j].timeMs);
            break;
          }
        }
        if (end > start) voices.add(_Voice(samplesOf(sound), start, end - start, looping: true));
      } else {
        final samples = samplesOf(sound);
        voices.add(_Voice(samples, start, samples.length));
      }
    }
    return voices;
  }

  static int _msToSamples(int ms) => (ms * sampleRate) ~/ 1000;

  /// Soft knee: untouched below 0.9, then eases towards a 0.98 ceiling, so even very loud
  /// passages never sit flat against full scale.
  static double _limit(double x) {
    final magnitude = x.abs();
    if (magnitude <= 0.9) return x;
    final eased = 0.9 + 0.08 * _tanh((magnitude - 0.9) / 0.08);
    return x.isNegative ? -eased : eased;
  }

  static double _tanh(double x) {
    final e2x = exp(2 * x.clamp(-10.0, 10.0));
    return (e2x - 1) / (e2x + 1);
  }

  /// Samples (-1..1) of a mono 16-bit WAV produced by [SoundSynthesizer].
  static Float32List _decodeWav(Uint8List wav) {
    final data = ByteData.sublistView(wav, 44);
    final samples = Float32List(data.lengthInBytes ~/ 2);
    for (int i = 0; i < samples.length; i++) {
      samples[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return samples;
  }

  static Uint8List _wavHeader(int numSamples) {
    final header = ByteData(44);
    final dataBytes = numSamples * 2;
    void ascii(int offset, String text) {
      for (int i = 0; i < text.length; i++) {
        header.setUint8(offset + i, text.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    header.setUint32(4, 36 + dataBytes, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // PCM chunk size
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample
    ascii(36, 'data');
    header.setUint32(40, dataBytes, Endian.little);
    return header.buffer.asUint8List();
  }
}

/// One sound on the output timeline.
class _Voice {
  final Float32List samples;
  final int start;
  final int length;
  final bool looping;

  _Voice(this.samples, this.start, this.length, {this.looping = false});

  void mixInto(Float64List block, int blockStart, int blockLength) {
    final from = max(start, blockStart);
    final to = min(start + length, blockStart + blockLength);
    if (from >= to || samples.isEmpty) return;
    for (int t = from; t < to; t++) {
      final offset = t - start;
      block[t - blockStart] += samples[looping ? offset % samples.length : offset];
    }
  }
}
