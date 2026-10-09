import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'recording.dart';
import 'recording_renderer.dart';

/// Turns a recording into a WAV file and opens the system share sheet.
class RecordingSharer {
  RecordingSharer._();

  /// Where exported files are written. Tests point this at a scratch directory.
  @visibleForTesting
  static Future<Directory> Function() baseDirectoryProvider = getTemporaryDirectory;

  /// Renders [recording] to a WAV file named after its title. Earlier exports are removed
  /// so shared files do not pile up in the app's cache.
  static Future<File> exportWav(Recording recording) async {
    final base = await baseDirectoryProvider();
    final directory = Directory('${base.path}/exports');
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create(recursive: true);

    final file = File('${directory.path}/${fileNameFor(recording.title)}');
    await RecordingRenderer.renderToFile(recording, file.path);
    return file;
  }

  static Future<void> share(Recording recording) async {
    final file = await exportWav(recording);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'audio/wav')],
      subject: recording.title,
      text: '${recording.title}, made with SurJam',
    ));
  }

  /// A safe file name from a recording title, e.g. "Raga sketch!" -> "Raga_sketch.wav".
  static String fileNameFor(String title) {
    final cleaned = title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final base = cleaned.isEmpty ? 'SurJam_jam' : cleaned;
    return '${base.length > 40 ? base.substring(0, 40) : base}.wav';
  }
}
