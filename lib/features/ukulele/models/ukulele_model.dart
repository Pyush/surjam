class UkuleleString {
  final int index;
  final String noteName;
  final int baseMidi;

  const UkuleleString({
    required this.index,
    required this.noteName,
    required this.baseMidi,
  });

  static const List<UkuleleString> standardStrings = [
    UkuleleString(index: 0, noteName: 'G4', baseMidi: 67),
    UkuleleString(index: 1, noteName: 'C4', baseMidi: 60),
    UkuleleString(index: 2, noteName: 'E4', baseMidi: 64),
    UkuleleString(index: 3, noteName: 'A4', baseMidi: 69),
  ];
}

class UkuleleChord {
  final String id;
  final String name;
  final List<int> frets; // 4 frets [G, C, E, A] e.g. [0, 0, 0, 3] for C Major

  const UkuleleChord({
    required this.id,
    required this.name,
    required this.frets,
  });

  static const List<UkuleleChord> popularChords = [
    UkuleleChord(id: 'c_maj', name: 'C Major', frets: [0, 0, 0, 3]),
    UkuleleChord(id: 'g_maj', name: 'G Major', frets: [0, 2, 3, 2]),
    UkuleleChord(id: 'a_min', name: 'A Minor', frets: [2, 0, 0, 0]),
    UkuleleChord(id: 'f_maj', name: 'F Major', frets: [2, 0, 1, 0]),
    UkuleleChord(id: 'd_min', name: 'D Minor', frets: [2, 2, 1, 0]),
    UkuleleChord(id: 'e_min', name: 'E Minor', frets: [0, 4, 3, 2]),
    UkuleleChord(id: 'd_maj', name: 'D Major', frets: [2, 2, 2, 0]),
    UkuleleChord(id: 'a_maj', name: 'A Major', frets: [2, 1, 0, 0]),
  ];
}
