import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/audio/audio_engine.dart';
import '../models/sitar_raga_model.dart';
import '../../../core/lifecycle/safe_change_notifier.dart';

class SitarProvider extends ChangeNotifier with SafeChangeNotifier {
  SitarRagaModel _selectedRaga = SitarRagaModel.preloadedRagas[0]; // Yaman
  int _rootMidi = 60; // C4 Sa
  int? _activeFret;
  int _bendSemitones = 0;
  int? _activeStringIndex;
  int? _activeTarabIndex;
  String _activeNoteName = 'Sa';

  // Fretboard setup: 12 frets covering 1 octave +
  // Fret positions in chromatic semitones relative to Sa:
  // 0: Sa (0)
  // 1: komal re (1)
  // 2: Shuddh Re (2)
  // 3: komal ga (3)
  // 4: Shuddh Ga (4)
  // 5: Shuddh Ma (5)
  // 6: Teevra Ma (6)
  // 7: Pa (7)
  // 8: komal dha (8)
  // 9: Shuddh Dha (9)
  // 10: komal ni (10)
  // 11: Shuddh Ni (11)
  // 12: High Sa (12)
  
  static const List<String> swaraNames = [
    'Sa', 're', 'Re', 'ga', 'Ga', 'Ma', 'MA', 'Pa', 'dha', 'Dha', 'ni', 'Ni', 'Sa\''
  ];

  // Mandra (low octave) Ni fret below Sa, so phrases like "Ni. Re Ga" are playable.
  // Follows the raga: Shuddh Ni (-1) unless the raga only uses komal ni (-2).
  int get lowNiSemitone => _selectedRaga.intervals.contains(11) || !_selectedRaga.intervals.contains(10) ? -1 : -2;

  // Fret semitones from left to right: low Ni, then Sa (0) to high Sa (12)
  List<int> get fretSemitones => [lowNiSemitone, for (int s = 0; s <= 12; s++) s];

  // Swara name with octave marks: "Ni." for mandra, "Sa'" for taar
  static String swaraLabel(int semitone) {
    final name = swaraNames[semitone % 12];
    if (semitone < 0) return '$name.';
    return name + '\'' * (semitone ~/ 12);
  }

  SitarRagaModel get selectedRaga => _selectedRaga;
  int get rootMidi => _rootMidi;
  int? get activeFret => _activeFret;
  int get bendSemitones => _bendSemitones;
  int? get activeStringIndex => _activeStringIndex;
  int? get activeTarabIndex => _activeTarabIndex;
  String get activeNoteName => _activeNoteName;

  void setRaga(SitarRagaModel raga) {
    _selectedRaga = raga;
    notifyListeners();
  }

  void setRootMidi(int midi) {
    _rootMidi = midi;
    notifyListeners();
  }

  bool isFretInRaga(int fretSemitone) {
    int semitoneInOctave = fretSemitone % 12;
    return _selectedRaga.intervals.contains(semitoneInOctave);
  }

  void pluckFret(int fretSemitone, {int bend = 0, int stringIndex = 0}) {
    _activeFret = fretSemitone;
    _bendSemitones = bend;
    _activeStringIndex = stringIndex;

    int totalSemitones = fretSemitone + bend;
    int targetMidi = _rootMidi + totalSemitones;
    _activeNoteName = swaraLabel(totalSemitones);

    AudioEngine().playSitarNote(targetMidi, bendSemitones: bend);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (_activeFret == fretSemitone) {
        _activeFret = null;
        _activeStringIndex = null;
        notifyListeners();
      }
    });
  }

  void updateMeendBend(int bend) {
    if (_bendSemitones != bend) {
      _bendSemitones = bend.clamp(0, 4);
      notifyListeners();
    }
  }

  void strumChikari(int chikariIndex) {
    // Chikari Drone Strings: 0: Pa (MIDI 67), 1: Sa High (MIDI 72), 2: Super Sa (MIDI 84)
    List<int> chikariMidis = [_rootMidi + 7, _rootMidi + 12, _rootMidi + 24];
    int midi = chikariMidis[chikariIndex.clamp(0, chikariMidis.length - 1)];
    
    _activeStringIndex = 4 + chikariIndex;
    AudioEngine().playSitarNote(midi);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 250), () {
      _activeStringIndex = null;
      notifyListeners();
    });
  }

  void pluckTarab(int tarabIndex) {
    // 11 Tarab sympathetic strings tuned according to current Raga intervals
    List<int> intervals = _selectedRaga.intervals;
    int interval = intervals[tarabIndex % intervals.length];
    int octaveOffset = (tarabIndex ~/ intervals.length) * 12;
    int midi = _rootMidi + interval + octaveOffset;

    _activeTarabIndex = tarabIndex;
    AudioEngine().playSitarNote(midi);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_activeTarabIndex == tarabIndex) {
        _activeTarabIndex = null;
        notifyListeners();
      }
    });
  }
}
