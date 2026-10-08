import 'dart:math';

class PitchConverter {
  static const double a4Frequency = 440.0;
  static const List<String> noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  static const List<String> sargamNames = [
    'Sa', 're', 'Re', 'ga', 'Ga', 'Ma', 'MA', 'Pa', 'dha', 'Dha', 'ni', 'Ni'
  ];

  /// Converts frequency in Hz to nearest MIDI note number
  static int frequencyToMidi(double frequency) {
    if (frequency <= 0) return 60;
    return (69 + 12 * (log(frequency / a4Frequency) / log(2))).round();
  }

  /// Converts MIDI note number to fundamental frequency in Hz
  static double midiToFrequency(int midiNote) {
    return a4Frequency * pow(2.0, (midiNote - 69) / 12.0);
  }

  /// Calculates cents deviation from exact target MIDI note (-50.0 to +50.0 cents)
  static double calculateCents(double frequency, int targetMidi) {
    double targetFreq = midiToFrequency(targetMidi);
    if (frequency <= 0 || targetFreq <= 0) return 0.0;
    return 1200 * (log(frequency / targetFreq) / log(2));
  }

  /// Returns note name with octave (e.g. C4, A4)
  static String midiToNoteName(int midiNote) {
    int octave = (midiNote ~/ 12) - 1;
    String name = noteNames[midiNote % 12];
    return '$name$octave';
  }

  /// Returns Sargam note label (e.g. Sa, Re, Ga)
  static String midiToSargam(int midiNote) {
    return sargamNames[midiNote % 12];
  }
}
