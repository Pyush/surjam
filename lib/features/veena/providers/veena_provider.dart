import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';
import '../../../core/music/thaat.dart';

/// The veena's main string, fretted at the notes of a thaat. Dragging across a fret pulls the
/// string (gamaka), raising the pitch up to two semitones.
class VeenaProvider extends ChangeNotifier with SafeChangeNotifier {
  static const int maxGamaka = 2;

  /// The side (tala) strings, tuned Sa, Pa, Sa' and strummed for rhythm.
  static const List<int> talaStrings = [60, 67, 72];

  VeenaProvider() {
    _preloadNotes();
  }

  Thaat _thaat = Thaat.all.first;
  bool _showSargam = true;
  int? _activeFret;
  int _gamaka = 0;
  bool _talaRinging = false;

  Thaat get thaat => _thaat;
  List<int> get frets => ThaatTuning.notes(_thaat);
  bool get showSargam => _showSargam;
  int? get activeFret => _activeFret;
  int get gamaka => _gamaka;
  bool get talaRinging => _talaRinging;

  void setThaat(Thaat thaat) {
    _thaat = thaat;
    _activeFret = null;
    _preloadNotes();
    notifyListeners();
  }

  void toggleLabels() {
    _showSargam = !_showSargam;
    notifyListeners();
  }

  /// Plucks the string at [fretMidi].
  void pluck(int fretMidi) {
    _activeFret = fretMidi;
    _gamaka = 0;
    AudioEngine().playVeenaNote(fretMidi);
    notifyListeners();
  }

  /// Pulls the string sideways on the current fret. Each new semitone of pull sounds the
  /// raised note, as the pitch slides up.
  void pull(int semitones) {
    final fret = _activeFret;
    final clamped = semitones.clamp(0, maxGamaka);
    if (fret == null || clamped == _gamaka) return;
    _gamaka = clamped;
    if (clamped > 0) AudioEngine().playVeenaNote(fret + clamped);
    notifyListeners();
  }

  void lift() {
    _activeFret = null;
    _gamaka = 0;
    notifyListeners();
  }

  /// Strums the tala strings from low to high.
  void strumTala() {
    for (int i = 0; i < talaStrings.length; i++) {
      Future.delayed(Duration(milliseconds: i * 45), () => AudioEngine().playVeenaNote(talaStrings[i]));
    }
    _talaRinging = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 300), () {
      _talaRinging = false;
      notifyListeners();
    });
  }

  // Plucked strings are heavier to synthesize: prepare the frets, their gamaka pulls and the
  // tala strings in the background.
  void _preloadNotes() {
    final notes = {
      for (final fret in frets) for (int pull = 0; pull <= maxGamaka; pull++) fret + pull,
      ...talaStrings,
    };
    AudioEngine().preload(notes.map((m) => SoundEvent.note(SoundType.veena, m)));
  }
}
