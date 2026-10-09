import 'dart:async';
import 'package:flutter/foundation.dart';
import '../audio/sound_event.dart';
import '../storage/storage_service.dart';
import 'recording.dart';

/// Captures every sound the audio engine plays while recording is on, on any instrument,
/// including loops and sequencers the player starts.
class JamRecorder extends ChangeNotifier {
  JamRecorder._();
  static final JamRecorder instance = JamRecorder._();

  /// Recordings stop and save themselves after this long, keeping saved jams and exported
  /// audio files a sensible size.
  static const Duration maxDuration = Duration(minutes: 10);

  String? _instrument;
  final Stopwatch _clock = Stopwatch();
  final List<TimedSoundEvent> _events = [];
  Timer? _limitTimer;

  bool get isRecording => _instrument != null;
  String? get instrument => _instrument;
  Duration get elapsed => _clock.elapsed;
  int get eventCount => _events.length;

  void start(String instrument) {
    _instrument = instrument;
    _events.clear();
    _clock
      ..reset()
      ..start();
    _limitTimer?.cancel();
    _limitTimer = Timer(maxDuration, () => stopAndSave(StorageService.autoSavedRecordingTitle('$instrument jam')));
    notifyListeners();
  }

  /// Called by the audio engine for every sound it plays.
  void capture(SoundEvent sound) {
    if (!isRecording) return;
    _events.add(TimedSoundEvent(_clock.elapsedMilliseconds, sound));
  }

  /// Ends the recording now. Returns the take to name and save, or null if nothing was played.
  Take? stop() {
    if (!isRecording) return null;
    final take = Take(_instrument!, List.of(_events), _clock.elapsedMilliseconds);
    _reset();
    return take.events.isEmpty ? null : take;
  }

  /// Saves [take] under [title] (an automatic title if blank).
  Future<Recording> save(Take take, String title) async {
    final recording = Recording(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? StorageService.autoSavedRecordingTitle('${take.instrument} jam') : title.trim(),
      instrument: take.instrument,
      createdAt: DateTime.now(),
      durationMs: take.durationMs,
      events: take.events,
    );
    await StorageService().saveRecording(recording.toJson());
    return recording;
  }

  /// Stops and saves in one step: used when a screen closes or the time limit is reached.
  Future<Recording?> stopAndSave(String title) async {
    final take = stop();
    return take == null ? null : save(take, title);
  }

  void discard() {
    if (!isRecording) return;
    _reset();
  }

  void _reset() {
    _instrument = null;
    _events.clear();
    _clock
      ..stop()
      ..reset();
    _limitTimer?.cancel();
    _limitTimer = null;
    notifyListeners();
  }
}

/// A finished recording that has not been saved yet.
class Take {
  final String instrument;
  final List<TimedSoundEvent> events;
  final int durationMs;

  const Take(this.instrument, this.events, this.durationMs);
}
