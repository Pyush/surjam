class GuitarChordModel {
  // Standard tuning, string 6 to string 1: E2 A2 D3 G3 B3 E4
  static const List<int> openStringMidi = [40, 45, 50, 55, 59, 64];
  // Frets visible on the fretboard at once (beyond the nut / open position)
  static const int visibleFrets = 4;

  static const List<String> categories = ['Major', 'Minor', '7th', 'Sus & Power'];

  final String name;
  final String category;
  // Fret position for 6 strings [E2, A2, D3, G3, B3, E4] (-1 = muted/X, 0 = open, 1-12 = fret)
  final List<int> frets;

  const GuitarChordModel({
    required this.name,
    required this.category,
    required this.frets,
  });

  /// MIDI note numbers played when strummed from string 6 to string 1 (muted strings skipped).
  List<int> get midiNotes => [
        for (int i = 0; i < frets.length; i++)
          if (frets[i] >= 0) openStringMidi[i] + frets[i],
      ];

  /// Lowest fret shown on the fretboard: 1 for open-position shapes, otherwise the
  /// lowest fretted note so shapes higher up the neck still fit on screen.
  int get baseFret {
    final fretted = frets.where((f) => f > 0);
    if (fretted.isEmpty || fretted.reduce((a, b) => a > b ? a : b) <= visibleFrets) return 1;
    return fretted.reduce((a, b) => a < b ? a : b);
  }

  static const List<GuitarChordModel> preloadedChords = [
    // Major
    GuitarChordModel(name: 'C Major', category: 'Major', frets: [-1, 3, 2, 0, 1, 0]),
    GuitarChordModel(name: 'C# Major', category: 'Major', frets: [-1, 4, 6, 6, 6, 4]),
    GuitarChordModel(name: 'D Major', category: 'Major', frets: [-1, -1, 0, 2, 3, 2]),
    GuitarChordModel(name: 'Eb Major', category: 'Major', frets: [-1, 6, 8, 8, 8, 6]),
    GuitarChordModel(name: 'E Major', category: 'Major', frets: [0, 2, 2, 1, 0, 0]),
    GuitarChordModel(name: 'F Major', category: 'Major', frets: [1, 3, 3, 2, 1, 1]),
    GuitarChordModel(name: 'F# Major', category: 'Major', frets: [2, 4, 4, 3, 2, 2]),
    GuitarChordModel(name: 'G Major', category: 'Major', frets: [3, 2, 0, 0, 0, 3]),
    GuitarChordModel(name: 'Ab Major', category: 'Major', frets: [4, 6, 6, 5, 4, 4]),
    GuitarChordModel(name: 'A Major', category: 'Major', frets: [-1, 0, 2, 2, 2, 0]),
    GuitarChordModel(name: 'Bb Major', category: 'Major', frets: [-1, 1, 3, 3, 3, 1]),
    GuitarChordModel(name: 'B Major', category: 'Major', frets: [-1, 2, 4, 4, 4, 2]),

    // Minor
    GuitarChordModel(name: 'C Minor', category: 'Minor', frets: [-1, 3, 5, 5, 4, 3]),
    GuitarChordModel(name: 'C# Minor', category: 'Minor', frets: [-1, 4, 6, 6, 5, 4]),
    GuitarChordModel(name: 'D Minor', category: 'Minor', frets: [-1, -1, 0, 2, 3, 1]),
    GuitarChordModel(name: 'Eb Minor', category: 'Minor', frets: [-1, 6, 8, 8, 7, 6]),
    GuitarChordModel(name: 'E Minor', category: 'Minor', frets: [0, 2, 2, 0, 0, 0]),
    GuitarChordModel(name: 'F Minor', category: 'Minor', frets: [1, 3, 3, 1, 1, 1]),
    GuitarChordModel(name: 'F# Minor', category: 'Minor', frets: [2, 4, 4, 2, 2, 2]),
    GuitarChordModel(name: 'G Minor', category: 'Minor', frets: [3, 5, 5, 3, 3, 3]),
    GuitarChordModel(name: 'G# Minor', category: 'Minor', frets: [4, 6, 6, 4, 4, 4]),
    GuitarChordModel(name: 'A Minor', category: 'Minor', frets: [-1, 0, 2, 2, 1, 0]),
    GuitarChordModel(name: 'Bb Minor', category: 'Minor', frets: [-1, 1, 3, 3, 2, 1]),
    GuitarChordModel(name: 'B Minor', category: 'Minor', frets: [-1, 2, 4, 4, 3, 2]),

    // Dominant 7th, major 7th and minor 7th
    GuitarChordModel(name: 'C7', category: '7th', frets: [-1, 3, 2, 3, 1, 0]),
    GuitarChordModel(name: 'D7', category: '7th', frets: [-1, -1, 0, 2, 1, 2]),
    GuitarChordModel(name: 'E7', category: '7th', frets: [0, 2, 0, 1, 0, 0]),
    GuitarChordModel(name: 'F7', category: '7th', frets: [1, 3, 1, 2, 1, 1]),
    GuitarChordModel(name: 'G7', category: '7th', frets: [3, 2, 0, 0, 0, 1]),
    GuitarChordModel(name: 'A7', category: '7th', frets: [-1, 0, 2, 0, 2, 0]),
    GuitarChordModel(name: 'B7', category: '7th', frets: [-1, 2, 1, 2, 0, 2]),
    GuitarChordModel(name: 'Cmaj7', category: '7th', frets: [-1, 3, 2, 0, 0, 0]),
    GuitarChordModel(name: 'Dmaj7', category: '7th', frets: [-1, -1, 0, 2, 2, 2]),
    GuitarChordModel(name: 'Emaj7', category: '7th', frets: [0, 2, 1, 1, 0, 0]),
    GuitarChordModel(name: 'Fmaj7', category: '7th', frets: [-1, -1, 3, 2, 1, 0]),
    GuitarChordModel(name: 'Gmaj7', category: '7th', frets: [3, 2, 0, 0, 0, 2]),
    GuitarChordModel(name: 'Amaj7', category: '7th', frets: [-1, 0, 2, 1, 2, 0]),
    GuitarChordModel(name: 'Am7', category: '7th', frets: [-1, 0, 2, 0, 1, 0]),
    GuitarChordModel(name: 'Bm7', category: '7th', frets: [-1, 2, 0, 2, 0, 2]),
    GuitarChordModel(name: 'Dm7', category: '7th', frets: [-1, -1, 0, 2, 1, 1]),
    GuitarChordModel(name: 'Em7', category: '7th', frets: [0, 2, 0, 0, 0, 0]),

    // Suspended and power chords
    GuitarChordModel(name: 'Asus2', category: 'Sus & Power', frets: [-1, 0, 2, 2, 0, 0]),
    GuitarChordModel(name: 'Asus4', category: 'Sus & Power', frets: [-1, 0, 2, 2, 3, 0]),
    GuitarChordModel(name: 'Dsus2', category: 'Sus & Power', frets: [-1, -1, 0, 2, 3, 0]),
    GuitarChordModel(name: 'Dsus4', category: 'Sus & Power', frets: [-1, -1, 0, 2, 3, 3]),
    GuitarChordModel(name: 'Esus4', category: 'Sus & Power', frets: [0, 2, 2, 2, 0, 0]),
    GuitarChordModel(name: 'E5', category: 'Sus & Power', frets: [0, 2, 2, -1, -1, -1]),
    GuitarChordModel(name: 'A5', category: 'Sus & Power', frets: [-1, 0, 2, 2, -1, -1]),
    GuitarChordModel(name: 'G5', category: 'Sus & Power', frets: [3, 5, 5, -1, -1, -1]),
  ];
}
