class MusicTheoryData {
  static const Map<String, List<int>> scales = {
    'C Major': [0, 2, 4, 5, 7, 9, 11],
    'G Major': [7, 9, 11, 0, 2, 4, 6],
    'F Major': [5, 7, 9, 10, 0, 2, 4],
    'A Minor (Natural)': [9, 11, 0, 2, 4, 5, 7],
    'E Minor': [4, 6, 7, 9, 11, 0, 2],
    'Major Pentatonic': [0, 2, 4, 7, 9],
    'Minor Pentatonic': [0, 3, 5, 7, 10],
    'Blues Scale': [0, 3, 5, 6, 7, 10],
    'Raag Bilaval (Major)': [0, 2, 4, 5, 7, 9, 11],
    'Raag Bhairav': [0, 1, 4, 5, 7, 8, 11],
    'Raag Kafi': [0, 2, 3, 5, 7, 9, 10],
    'Raag Yaman': [0, 2, 4, 6, 7, 9, 11],
  };

  static const Map<String, List<int>> chords = {
    'C Major': [60, 64, 67],      // C-E-G
    'C Minor': [60, 63, 67],      // C-Eb-G
    'D Major': [62, 66, 69],      // D-F#-A
    'D Minor': [62, 65, 69],      // D-F-A
    'E Minor': [64, 67, 71],      // E-G-B
    'F Major': [65, 69, 72],      // F-A-C
    'G Major': [67, 71, 74],      // G-B-D
    'A Minor': [57, 60, 64],      // A-C-E
    'C Maj7': [60, 64, 67, 71],   // C-E-G-B
    'G7': [67, 71, 74, 77],       // G-B-D-F
  };
}
