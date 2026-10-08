class ExerciseModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String difficulty;
  final List<int> midiSequence;

  const ExerciseModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.difficulty,
    required this.midiSequence,
  });

  static const List<ExerciseModel> preloadedExercises = [
    ExerciseModel(
      id: 'ex_c_major',
      title: 'C Major Scale (Ascending)',
      subtitle: 'Practice fundamental finger movement across C4 to C5',
      category: 'Piano Scales',
      difficulty: 'Beginner',
      midiSequence: [60, 62, 64, 65, 67, 69, 71, 72],
    ),
    ExerciseModel(
      id: 'ex_sargam',
      title: 'Indian Sargam (Sa Re Ga Ma)',
      subtitle: 'Basic Indian classical vocal & instrumental note ladder',
      category: 'Indian Sargam',
      difficulty: 'Beginner',
      midiSequence: [60, 62, 64, 65, 67, 69, 71, 72],
    ),
    ExerciseModel(
      id: 'ex_chords',
      title: 'Primary Chords Progression',
      subtitle: 'Master C Major, F Major, and G Major chord triads',
      category: 'Chords',
      difficulty: 'Intermediate',
      midiSequence: [60, 64, 67, 65, 69, 72, 67, 71, 74],
    ),
    ExerciseModel(
      id: 'ex_arpeggio',
      title: 'C Major Arpeggio Wave',
      subtitle: 'Smooth broken chord movement up and down',
      category: 'Arpeggios',
      difficulty: 'Intermediate',
      midiSequence: [60, 64, 67, 72, 67, 64, 60],
    ),
  ];
}
