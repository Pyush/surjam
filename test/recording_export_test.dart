import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/core/audio/sound_event.dart';
import 'package:surjam/core/recording/recording.dart';
import 'package:surjam/core/recording/recording_renderer.dart';
import 'package:surjam/core/recording/recording_sharer.dart';

const int _rate = 44100;

Recording _recording(List<TimedSoundEvent> events, {int durationMs = 0}) => Recording(
      id: 'test',
      title: 'Test jam',
      instrument: 'Piano',
      createdAt: DateTime(2026, 10, 9),
      durationMs: durationMs,
      events: events,
    );

/// Peak level (0..1) of the rendered audio between two times.
double _peak(Int16List pcm, double fromSeconds, double toSeconds) {
  var peak = 0;
  for (int i = (fromSeconds * _rate).round(); i < (toSeconds * _rate).round() && i < pcm.length; i++) {
    if (pcm[i].abs() > peak) peak = pcm[i].abs();
  }
  return peak / 32767;
}

void main() {
  late Directory scratch;

  setUp(() async => scratch = await Directory.systemTemp.createTemp('surjam_export_test'));
  tearDown(() async => scratch.delete(recursive: true));

  ({ByteData header, Int16List pcm}) render(Recording recording) {
    final path = '${scratch.path}/out.wav';
    RecordingRenderer.renderToFileSync(recording, path);
    final bytes = File(path).readAsBytesSync();
    final data = ByteData.sublistView(bytes, 44);
    final pcm = Int16List(data.lengthInBytes ~/ 2);
    for (int i = 0; i < pcm.length; i++) {
      pcm[i] = data.getInt16(i * 2, Endian.little);
    }
    return (header: ByteData.sublistView(bytes, 0, 44), pcm: pcm);
  }

  test('Writes a standard 44.1 kHz mono 16-bit WAV', () {
    final out = render(_recording([TimedSoundEvent(0, SoundEvent.note(SoundType.piano, 60))]));
    String text(int offset) => String.fromCharCodes(out.header.buffer.asUint8List(out.header.offsetInBytes + offset, 4));
    expect(text(0), equals('RIFF'));
    expect(text(8), equals('WAVE'));
    expect(out.header.getUint16(22, Endian.little), equals(1)); // mono
    expect(out.header.getUint32(24, Endian.little), equals(_rate));
    expect(out.header.getUint16(34, Endian.little), equals(16));
    expect(out.header.getUint32(40, Endian.little), equals(out.pcm.length * 2));
  });

  test('Each sound starts at the moment it was played', () {
    final out = render(_recording([
      TimedSoundEvent(0, SoundEvent.tabla('na')),
      TimedSoundEvent(2000, SoundEvent.tabla('na')),
    ], durationMs: 2000));
    expect(_peak(out.pcm, 0.0, 0.1), greaterThan(0.2)); // first stroke
    expect(_peak(out.pcm, 1.0, 1.95), lessThan(0.01)); // silence between strokes
    expect(_peak(out.pcm, 2.0, 2.1), greaterThan(0.2)); // second stroke on time
  });

  test('A drone holds until it is stopped', () {
    final out = render(_recording([
      TimedSoundEvent(0, SoundEvent.droneStart(48)),
      TimedSoundEvent(3000, SoundEvent.droneStopEvent),
    ], durationMs: 5000));
    expect(_peak(out.pcm, 2.5, 2.9), greaterThan(0.2)); // still sounding after one loop cycle
    expect(_peak(out.pcm, 3.05, 4.9), equals(0)); // silent once stopped
    expect(out.pcm.length / _rate, closeTo(5.25, 0.01)); // runs to the recorded length plus a short tail
  });

  test('A drone left on plays to the end of the recording', () {
    final out = render(_recording([TimedSoundEvent(0, SoundEvent.droneStart(55))], durationMs: 4000));
    expect(_peak(out.pcm, 3.5, 3.95), greaterThan(0.2));
  });

  test('Loud chords are softened rather than hard-clipped', () {
    final out = render(_recording([
      for (final note in [48, 52, 55, 60, 64, 67, 72, 76, 79])
        TimedSoundEvent(0, SoundEvent.note(SoundType.harmonium, note)),
    ]));
    final clipped = out.pcm.where((s) => s.abs() >= 32767).length;
    expect(clipped, equals(0));
    expect(_peak(out.pcm, 0, 0.5), greaterThan(0.85)); // still loud
  });

  test('Export names the file after the recording and clears old exports', () async {
    RecordingSharer.baseDirectoryProvider = () async => scratch;
    final first = await RecordingSharer.exportWav(_recording([TimedSoundEvent(0, SoundEvent.tabla('dha'))]));
    expect(first.path, endsWith('/exports/Test_jam.wav'));
    expect(first.existsSync(), isTrue);

    final again = await RecordingSharer.exportWav(Recording(
      id: '2',
      title: 'Raga sketch!',
      instrument: 'Sitar',
      createdAt: DateTime(2026, 10, 9),
      durationMs: 0,
      events: [TimedSoundEvent(0, SoundEvent.note(SoundType.sitar, 60))],
    ));
    expect(again.path, endsWith('/exports/Raga_sketch.wav'));
    expect(first.existsSync(), isFalse);
  });

  test('File names are safe for every title', () {
    expect(RecordingSharer.fileNameFor('Piano jam 14:05'), equals('Piano_jam_1405.wav'));
    expect(RecordingSharer.fileNameFor('   '), equals('SurJam_jam.wav'));
    expect(RecordingSharer.fileNameFor('a' * 80), equals('${'a' * 40}.wav'));
  });
}
