class QuizQuestion {
  final String questionText;
  final int soundMidi;
  final String? soundBol;
  final List<String> options;
  final int correctOptionIndex;

  const QuizQuestion({
    required this.questionText,
    required this.soundMidi,
    this.soundBol,
    required this.options,
    required this.correctOptionIndex,
  });

  static const List<QuizQuestion> questions = [
    QuizQuestion(
      questionText: 'Listen carefully. What note is played?',
      soundMidi: 60, // C4
      options: ['C4 (Sa)', 'D4 (Re)', 'E4 (Ga)', 'G4 (Pa)'],
      correctOptionIndex: 0,
    ),
    QuizQuestion(
      questionText: 'Identify the played interval note:',
      soundMidi: 67, // G4
      options: ['C4', 'E4', 'G4 (Fifth)', 'B4'],
      correctOptionIndex: 2,
    ),
    QuizQuestion(
      questionText: 'Which Indian Sargam note is this?',
      soundMidi: 64, // E4 (Ga)
      options: ['Sa', 'Re', 'Ga', 'Ma'],
      correctOptionIndex: 2,
    ),
    QuizQuestion(
      questionText: 'Listen to this Tabla stroke. Which Bol is it?',
      soundMidi: 0,
      soundBol: 'dha',
      options: ['Tin', 'Dha', 'Ge', 'Ke'],
      correctOptionIndex: 1,
    ),
  ];
}
