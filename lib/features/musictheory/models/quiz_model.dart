import 'dart:math';

enum QuizSoundMode {
  /// Notes are played one after another (melodic).
  sequence,

  /// Notes are played together (harmonic).
  together,
}

class QuizQuestion {
  final String category;
  final String questionText;
  final List<int> notes;
  final QuizSoundMode soundMode;
  final String? soundBol;
  final List<String> options;
  final int correctOptionIndex;

  const QuizQuestion({
    required this.category,
    required this.questionText,
    this.notes = const [],
    this.soundMode = QuizSoundMode.sequence,
    this.soundBol,
    required this.options,
    required this.correctOptionIndex,
  });

  String get correctAnswer => options[correctOptionIndex];

  static const Map<String, int> intervals = {
    'Minor 2nd': 1,
    'Major 2nd': 2,
    'Minor 3rd': 3,
    'Major 3rd': 4,
    'Perfect 4th': 5,
    'Tritone': 6,
    'Perfect 5th': 7,
    'Minor 6th': 8,
    'Major 6th': 9,
    'Minor 7th': 10,
    'Major 7th': 11,
    'Octave': 12,
  };

  // Shuddh swaras of Bilawal thaat, relative to Sa.
  static const Map<String, int> swaras = {
    'Sa': 0, 'Re': 2, 'Ga': 4, 'Ma': 5, 'Pa': 7, 'Dha': 9, 'Ni': 11, "Sa'": 12,
  };

  static const Map<String, List<int>> chordQualities = {
    'Major': [0, 4, 7],
    'Minor': [0, 3, 7],
    'Diminished': [0, 3, 6],
    'Augmented': [0, 4, 8],
  };

  // Bols with distinct synthesized sounds.
  static const List<String> tablaBols = ['Dha', 'Dhin', 'Ge', 'Na', 'Tin', 'Ke'];

  static const int optionsPerQuestion = 4;

  /// A fresh round of [count] questions, cycling through the four question types
  /// in random order so every round is different.
  static List<QuizQuestion> generateRound(Random rng, {int count = 10}) {
    final generators = <QuizQuestion Function(Random)>[
      _intervalQuestion,
      _sargamQuestion,
      _chordQuestion,
      _tablaQuestion,
    ];
    final questions = <QuizQuestion>[];
    while (questions.length < count) {
      final batch = List.of(generators)..shuffle(rng);
      for (final generate in batch) {
        if (questions.length < count) questions.add(generate(rng));
      }
    }
    return questions;
  }

  static QuizQuestion _intervalQuestion(Random rng) {
    final answer = _pick(rng, intervals.keys.toList());
    final root = 55 + rng.nextInt(10); // G3 to E4
    return _withOptions(
      rng,
      category: 'Interval',
      questionText: 'Two notes are played. What is the interval between them?',
      notes: [root, root + intervals[answer]!],
      answer: answer,
      pool: intervals.keys.toList(),
    );
  }

  static QuizQuestion _sargamQuestion(Random rng) {
    final candidates = swaras.keys.where((s) => s != 'Sa').toList();
    final answer = _pick(rng, candidates);
    const sa = 60; // C4
    return _withOptions(
      rng,
      category: 'Sargam',
      questionText: 'Sa is played first, then another swara. Which swara is it?',
      notes: [sa, sa + swaras[answer]!],
      answer: answer,
      pool: candidates,
    );
  }

  static QuizQuestion _chordQuestion(Random rng) {
    final answer = _pick(rng, chordQualities.keys.toList());
    final root = 55 + rng.nextInt(8); // G3 to D4
    return QuizQuestion(
      category: 'Chord',
      questionText: 'A chord is played. Is it major, minor, diminished or augmented?',
      notes: [for (final i in chordQualities[answer]!) root + i],
      soundMode: QuizSoundMode.together,
      options: chordQualities.keys.toList(),
      correctOptionIndex: chordQualities.keys.toList().indexOf(answer),
    );
  }

  static QuizQuestion _tablaQuestion(Random rng) {
    final answer = _pick(rng, tablaBols);
    return _withOptions(
      rng,
      category: 'Tabla',
      questionText: 'Listen to this tabla stroke. Which bol is it?',
      soundBol: answer.toLowerCase(),
      answer: answer,
      pool: tablaBols,
    );
  }

  /// Builds a question whose options are [answer] plus random distractors from [pool].
  static QuizQuestion _withOptions(
    Random rng, {
    required String category,
    required String questionText,
    List<int> notes = const [],
    String? soundBol,
    required String answer,
    required List<String> pool,
  }) {
    final distractors = pool.where((o) => o != answer).toList()..shuffle(rng);
    final options = [answer, ...distractors.take(optionsPerQuestion - 1)]..shuffle(rng);
    return QuizQuestion(
      category: category,
      questionText: questionText,
      notes: notes,
      soundBol: soundBol,
      options: options,
      correctOptionIndex: options.indexOf(answer),
    );
  }

  static T _pick<T>(Random rng, List<T> items) => items[rng.nextInt(items.length)];
}
