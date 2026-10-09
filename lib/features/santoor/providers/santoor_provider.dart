import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/lifecycle/playback_guard.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';
import '../../../core/music/thaat.dart';

class SantoorProvider extends ChangeNotifier with SafeChangeNotifier {
  /// Time between strikes in a tremolo roll (about 11 strikes a second).
  static const Duration tremoloInterval = Duration(milliseconds: 90);

  SantoorProvider() {
    PlaybackGuard.register(this, stopTremolo);
    _preloadStrings();
  }

  Thaat _thaat = Thaat.all.first;
  bool _showSargam = true;
  final Set<int> _ringing = {};
  int? _tremoloMidi;
  Timer? _tremoloTimer;

  Thaat get thaat => _thaat;
  List<int> get strings => ThaatTuning.notes(_thaat);
  bool get showSargam => _showSargam;
  int? get tremoloMidi => _tremoloMidi;
  bool isRinging(int midi) => _ringing.contains(midi) || _tremoloMidi == midi;

  void setThaat(Thaat thaat) {
    stopTremolo();
    _thaat = thaat;
    _preloadStrings();
    notifyListeners();
  }

  void toggleLabels() {
    _showSargam = !_showSargam;
    notifyListeners();
  }

  /// One hammer stroke.
  void strike(int midi) {
    AudioEngine().playSantoorNote(midi);
    _ringing.add(midi);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 180), () {
      _ringing.remove(midi);
      notifyListeners();
    });
  }

  /// Rapid alternating strokes on one string while it is held: the santoor's tremolo.
  void startTremolo(int midi) {
    _tremoloTimer?.cancel();
    _tremoloMidi = midi;
    AudioEngine().playSantoorNote(midi);
    _tremoloTimer = Timer.periodic(tremoloInterval, (_) => AudioEngine().playSantoorNote(midi));
    notifyListeners();
  }

  void stopTremolo() {
    if (_tremoloMidi == null && _tremoloTimer == null) return;
    _tremoloTimer?.cancel();
    _tremoloTimer = null;
    _tremoloMidi = null;
    notifyListeners();
  }

  // Santoor strokes are heavier to synthesize, so the whole tuning is prepared in the
  // background as soon as it is chosen.
  void _preloadStrings() {
    AudioEngine().preload(strings.map((m) => SoundEvent.note(SoundType.santoor, m)));
  }

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _tremoloTimer?.cancel();
    super.dispose();
  }
}
