import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/lifecycle/playback_guard.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';
import '../../../core/music/thaat.dart';

/// The shehnai plays one note at a time for as long as a key is held. Sliding to another key
/// glides into it (meend).
class ShehnaiProvider extends ChangeNotifier with SafeChangeNotifier {
  /// Sa one octave below the melody, as the accompanying sur (drone) shehnai plays it.
  static const int surDroneMidi = 48;

  ShehnaiProvider() {
    PlaybackGuard.register(this, _stopAllSound);
    _preloadNotes();
  }

  Thaat _thaat = Thaat.all.first;
  bool _showSargam = true;
  bool _vibrato = true;
  bool _surDrone = false;
  int? _heldMidi;

  Thaat get thaat => _thaat;
  List<int> get notes => ThaatTuning.notes(_thaat);
  bool get showSargam => _showSargam;
  bool get vibrato => _vibrato;
  bool get surDrone => _surDrone;
  int? get heldMidi => _heldMidi;

  /// Starts or changes the held note. Called continuously while the finger moves.
  void press(int midi) {
    if (_heldMidi == midi) return;
    _heldMidi = midi;
    AudioEngine().startShehnai(midi, vibrato: _vibrato);
    notifyListeners();
  }

  void release() {
    if (_heldMidi == null) return;
    _heldMidi = null;
    AudioEngine().stopShehnai();
    notifyListeners();
  }

  void setThaat(Thaat thaat) {
    release();
    _thaat = thaat;
    _preloadNotes();
    notifyListeners();
  }

  void toggleLabels() {
    _showSargam = !_showSargam;
    notifyListeners();
  }

  /// Gamak on or off. A note being held switches over straight away.
  void setVibrato(bool enabled) {
    _vibrato = enabled;
    _preloadNotes();
    final held = _heldMidi;
    if (held != null) AudioEngine().startShehnai(held, vibrato: enabled);
    notifyListeners();
  }

  void toggleSurDrone() {
    _surDrone = !_surDrone;
    _surDrone ? AudioEngine().startDrone(surDroneMidi) : AudioEngine().stopDrone();
    notifyListeners();
  }

  void _stopAllSound() {
    release();
    if (_surDrone) toggleSurDrone();
  }

  void _preloadNotes() {
    AudioEngine().preload(notes.map((m) => SoundEvent.shehnaiStart(m, vibrato: _vibrato)));
  }

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _stopAllSound();
    super.dispose();
  }
}
