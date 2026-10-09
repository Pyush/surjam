/// One of the ten thaats (parent scales) of Hindustani music, after Bhatkhande.
/// The santoor is tuned to a thaat, so its strings give exactly that scale.
class Thaat {
  final String id;
  final String name;
  final String character;

  /// Semitones above Sa for the seven swaras.
  final List<int> intervals;

  const Thaat({required this.id, required this.name, required this.character, required this.intervals});

  static const List<Thaat> all = [
    Thaat(id: 'bilawal', name: 'Bilawal', character: 'All shuddh swaras, like the major scale', intervals: [0, 2, 4, 5, 7, 9, 11]),
    Thaat(id: 'kalyan', name: 'Kalyan', character: 'Tivra Ma (Yaman)', intervals: [0, 2, 4, 6, 7, 9, 11]),
    Thaat(id: 'khamaj', name: 'Khamaj', character: 'Komal Ni', intervals: [0, 2, 4, 5, 7, 9, 10]),
    Thaat(id: 'kafi', name: 'Kafi', character: 'Komal Ga and Ni', intervals: [0, 2, 3, 5, 7, 9, 10]),
    Thaat(id: 'asavari', name: 'Asavari', character: 'Komal Ga, Dha and Ni', intervals: [0, 2, 3, 5, 7, 8, 10]),
    Thaat(id: 'bhairavi', name: 'Bhairavi', character: 'Komal Re, Ga, Dha and Ni', intervals: [0, 1, 3, 5, 7, 8, 10]),
    Thaat(id: 'bhairav', name: 'Bhairav', character: 'Komal Re and Dha, a morning scale', intervals: [0, 1, 4, 5, 7, 8, 11]),
    Thaat(id: 'marwa', name: 'Marwa', character: 'Komal Re, tivra Ma', intervals: [0, 1, 4, 6, 7, 9, 11]),
    Thaat(id: 'purvi', name: 'Purvi', character: 'Komal Re and Dha, tivra Ma', intervals: [0, 1, 4, 6, 7, 8, 11]),
    Thaat(id: 'todi', name: 'Todi', character: 'Komal Re, Ga and Dha, tivra Ma', intervals: [0, 1, 3, 6, 7, 8, 11]),
  ];
}

/// The santoor's strings for a thaat: two octaves from Sa (C4) up to Sa'' (C6), lowest first.
class SantoorTuning {
  static const int sa = 60;

  static const List<String> _sargam = ['Sa', 're', 'Re', 'ga', 'Ga', 'Ma', 'MA', 'Pa', 'dha', 'Dha', 'ni', 'Ni'];
  static const List<String> _english = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  static List<int> strings(Thaat thaat) => [
        for (final octave in [0, 12]) for (final interval in thaat.intervals) sa + octave + interval,
        sa + 24,
      ];

  /// "Sa", "Sa'" (one octave up), "Sa''" (two up).
  static String sargamLabel(int midi) {
    final octave = (midi - sa) ~/ 12;
    return _sargam[midi % 12] + "'" * octave;
  }

  static String englishLabel(int midi) => '${_english[midi % 12]}${midi ~/ 12 - 1}';
}
