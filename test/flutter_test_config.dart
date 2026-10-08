import 'dart:async';
import 'dart:io';

import 'package:surjam/core/audio/audio_engine.dart';

/// Runs before every test file: generated sounds go to a throwaway directory,
/// never into the project (some tests mock path_provider to return '.').
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final scratch = await Directory.systemTemp.createTemp('surjam_test_sounds');
  AudioEngine.baseDirectoryProvider = () async => scratch;
  try {
    await testMain();
  } finally {
    if (await scratch.exists()) await scratch.delete(recursive: true);
  }
}
