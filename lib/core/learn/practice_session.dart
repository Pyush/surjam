import '../storage/storage_service.dart';

/// A "play the highlighted target" exercise on any instrument: chords on the guitar, bols on
/// the tabla. Scores like the piano lessons and keeps the best score per lesson.
class PracticeSession {
  static const int pointsPerCorrect = 100;
  static const int pointsPerMistake = 25;

  final String lessonId;
  final List<String> targets;

  int _step = 0;
  int _score = 0;
  int _mistakes = 0;

  PracticeSession(this.lessonId, List<String> targets) : targets = List.unmodifiable(targets);

  int get step => _step;
  int get score => _score;
  int get mistakes => _mistakes;
  bool get isComplete => _step >= targets.length;
  double get progress => targets.isEmpty ? 1 : _step / targets.length;
  int get bestScore => StorageService().getExerciseScore(lessonId);

  /// What to play next, or null when the lesson is finished.
  String? get target => isComplete ? null : targets[_step];

  /// Checks what the player just played. Returns true when it was the target.
  bool attempt(String played) {
    if (isComplete) return false;
    if (played.toLowerCase() == targets[_step].toLowerCase()) {
      _score += pointsPerCorrect;
      _step++;
      if (isComplete) StorageService().saveExerciseScore(lessonId, _score);
      return true;
    }
    _mistakes++;
    _score = (_score - pointsPerMistake).clamp(0, 1 << 30);
    return false;
  }

  void restart() {
    _step = 0;
    _score = 0;
    _mistakes = 0;
  }
}
