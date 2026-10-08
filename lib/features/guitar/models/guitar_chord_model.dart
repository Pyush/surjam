class GuitarChordModel {
  final String name;
  final String category;
  // Fret position for 6 strings [E2, A2, D3, G3, B3, E4] (-1 = muted/X, 0 = open, 1-12 = fret)
  final List<int> frets;
  // MIDI note numbers played when strummed from string 6 to string 1
  final List<int> midiNotes;

  const GuitarChordModel({
    required this.name,
    required this.category,
    required this.frets,
    required this.midiNotes,
  });

  static const List<GuitarChordModel> preloadedChords = [
    GuitarChordModel(
      name: 'C Major',
      category: 'Major',
      frets: [-1, 3, 2, 0, 1, 0], // X 3 2 0 1 0
      midiNotes: [48, 52, 55, 60, 64], // C3 E3 G3 C4 E4
    ),
    GuitarChordModel(
      name: 'G Major',
      category: 'Major',
      frets: [3, 2, 0, 0, 0, 3], // 3 2 0 0 0 3
      midiNotes: [43, 47, 50, 55, 59, 67], // G2 B2 D3 G3 B3 G4
    ),
    GuitarChordModel(
      name: 'D Major',
      category: 'Major',
      frets: [-1, -1, 0, 2, 3, 2], // X X 0 2 3 2
      midiNotes: [50, 57, 62, 66], // D3 A3 D4 F#4
    ),
    GuitarChordModel(
      name: 'E Minor',
      category: 'Minor',
      frets: [0, 2, 2, 0, 0, 0], // 0 2 2 0 0 0
      midiNotes: [40, 47, 52, 55, 59, 64], // E2 B2 E3 G3 B3 E4
    ),
    GuitarChordModel(
      name: 'A Minor',
      category: 'Minor',
      frets: [-1, 0, 2, 2, 1, 0], // X 0 2 2 1 0
      midiNotes: [45, 52, 57, 60, 64], // A2 E3 A3 C4 E4
    ),
    GuitarChordModel(
      name: 'F Major',
      category: 'Major',
      frets: [1, 3, 3, 2, 1, 1], // Barre 1
      midiNotes: [41, 48, 53, 57, 60, 65], // F2 C3 F3 A3 C4 F4
    ),
  ];
}
