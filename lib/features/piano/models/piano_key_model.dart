class PianoKeyModel {
  final int midiNote;
  final String noteName;
  final String sargamLabel;
  final bool isBlack;
  final int octave;

  const PianoKeyModel({
    required this.midiNote,
    required this.noteName,
    required this.sargamLabel,
    required this.isBlack,
    required this.octave,
  });

  /// Factory helper to build PianoKeyModel from MIDI note number (0 to 127)
  factory PianoKeyModel.fromMidi(int midi) {
    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final sargamNames = ['Sa', 're', 'Re', 'ga', 'Ga', 'Ma', 'MA', 'Pa', 'dha', 'Dha', 'ni', 'Ni'];
    
    int index = midi % 12;
    int octave = (midi ~/ 12) - 1;
    bool isBlack = [1, 3, 6, 8, 10].contains(index);

    return PianoKeyModel(
      midiNote: midi,
      noteName: '${noteNames[index]}$octave',
      sargamLabel: sargamNames[index],
      isBlack: isBlack,
      octave: octave,
    );
  }
}
