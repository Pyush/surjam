import '../../tabla/models/taal_model.dart';

/// A lesson for an instrument other than the piano: play each target in order.
/// Targets are guitar chord names or tabla bols.
class PracticeLesson {
  static const String guitar = 'Guitar';
  static const String tabla = 'Tabla';

  final String id;
  final String title;
  final String subtitle;
  final String instrument;
  final String difficulty;
  final List<String> targets;

  const PracticeLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.instrument,
    required this.difficulty,
    required this.targets,
  });

  static List<PracticeLesson> forInstrument(String instrument) =>
      all.where((l) => l.instrument == instrument).toList();

  static List<PracticeLesson> get all => [...guitarLessons, ...tablaLessons];

  static const List<PracticeLesson> guitarLessons = [
    PracticeLesson(
      id: 'gtr_em_am',
      title: 'First Chords: Em and Am',
      subtitle: 'Two easy shapes that use the same two fingers. Switch back and forth.',
      instrument: guitar,
      difficulty: 'Beginner',
      targets: ['E Minor', 'A Minor', 'E Minor', 'A Minor', 'E Minor', 'A Minor', 'E Minor', 'A Minor'],
    ),
    PracticeLesson(
      id: 'gtr_g_c_d',
      title: 'Three-Chord Songs: G, C, D',
      subtitle: 'The chords behind countless folk and pop songs.',
      instrument: guitar,
      difficulty: 'Beginner',
      targets: ['G Major', 'C Major', 'D Major', 'G Major', 'G Major', 'C Major', 'D Major', 'G Major'],
    ),
    PracticeLesson(
      id: 'gtr_pop',
      title: 'Pop Progression: C, Am, F, G',
      subtitle: 'F is a barre chord: take your time with it.',
      instrument: guitar,
      difficulty: 'Intermediate',
      targets: ['C Major', 'A Minor', 'F Major', 'G Major', 'C Major', 'A Minor', 'F Major', 'G Major'],
    ),
    PracticeLesson(
      id: 'gtr_a_d_e',
      title: 'Rock Changes: A, D, E',
      subtitle: 'Fast switches between open major chords.',
      instrument: guitar,
      difficulty: 'Intermediate',
      targets: ['A Major', 'D Major', 'E Major', 'A Major', 'D Major', 'A Major', 'E Major', 'A Major'],
    ),
    PracticeLesson(
      id: 'gtr_blues_a',
      title: '12-Bar Blues in A',
      subtitle: 'One chord per bar with seventh chords: A7, D7 and E7.',
      instrument: guitar,
      difficulty: 'Advanced',
      targets: ['A7', 'A7', 'A7', 'A7', 'D7', 'D7', 'A7', 'A7', 'E7', 'D7', 'A7', 'E7'],
    ),
  ];

  /// A bol warm-up, then each taal's theka from easiest to longest.
  static List<PracticeLesson> get tablaLessons {
    const order = ['dadra', 'keharwa', 'roopak', 'jhaptal', 'teentaal'];
    const difficulty = {
      'dadra': 'Beginner',
      'keharwa': 'Beginner',
      'roopak': 'Intermediate',
      'jhaptal': 'Intermediate',
      'teentaal': 'Advanced',
    };
    final taals = [
      for (final id in order) TaalModel.preloadedTaals.firstWhere((t) => t.id == id),
    ];
    return [
      const PracticeLesson(
        id: 'tbl_basic_bols',
        title: 'Basic Bols',
        subtitle: 'Meet the strokes: Dha and Dhin on both drums, Na and Tin on the dayan.',
        instrument: tabla,
        difficulty: 'Beginner',
        targets: ['Dha', 'Dha', 'Dhin', 'Dhin', 'Na', 'Na', 'Tin', 'Tin', 'Dha', 'Dhin', 'Na', 'Tin'],
      ),
      for (final taal in taals)
        PracticeLesson(
          id: 'tbl_${taal.id}',
          title: '${taal.name} Theka',
          subtitle: 'Play the bols of ${taal.name.split(' ').first} in order, starting on sam.',
          instrument: tabla,
          difficulty: difficulty[taal.id]!,
          targets: [for (final beat in taal.beats) beat.bol],
        ),
    ];
  }
}
