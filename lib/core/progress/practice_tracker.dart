import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One day of practice: minutes in which you played something, and lessons finished.
class PracticeDay {
  final DateTime date;
  final int minutes;
  final int lessons;

  const PracticeDay(this.date, this.minutes, this.lessons);

  bool get practiced => minutes > 0 || lessons > 0;
}

/// Tracks daily practice for streaks and the progress screen.
///
/// A minute counts when you played at least one sound in it (any instrument, loops and
/// lessons included). A day counts towards the streak once you have practised at all; the
/// daily goal is a separate target shown as progress.
class PracticeTracker extends ChangeNotifier {
  PracticeTracker._();
  static final PracticeTracker instance = PracticeTracker._();

  static const String _logKey = 'practice_log';
  static const String _goalKey = 'daily_goal_minutes';
  static const List<int> goalChoices = [5, 10, 15, 30];
  static const int _daysKept = 400;

  /// Replaced in tests to control "today".
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  SharedPreferences? _prefs;
  Map<String, Map<String, int>> _log = {};
  String? _lastCountedMinute;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _log = _readLog();
    _lastCountedMinute = null;
  }

  @visibleForTesting
  Future<void> reloadForTest() async {
    _prefs = await SharedPreferences.getInstance();
    _log = _readLog();
    _lastCountedMinute = null;
  }

  int get dailyGoalMinutes => _prefs?.getInt(_goalKey) ?? goalChoices.first;

  Future<void> setDailyGoalMinutes(int minutes) async {
    await _prefs?.setInt(_goalKey, minutes);
    notifyListeners();
  }

  /// Called for every sound the player makes.
  void onSoundPlayed() {
    final now = clock();
    final minute = '${_dayKey(now)} ${now.hour}:${now.minute}';
    if (minute == _lastCountedMinute) return;
    _lastCountedMinute = minute;
    _bump(now, 'm');
  }

  /// Called when any lesson (piano, guitar or tabla) is finished.
  void onLessonCompleted() => _bump(clock(), 'l');

  PracticeDay day(DateTime date) {
    final entry = _log[_dayKey(date)];
    return PracticeDay(_dateOnly(date), entry?['m'] ?? 0, entry?['l'] ?? 0);
  }

  PracticeDay get today => day(clock());

  /// The last [count] days, oldest first, ending today.
  List<PracticeDay> recentDays([int count = 7]) {
    final today = _dateOnly(clock());
    return [for (int i = count - 1; i >= 0; i--) day(_addDays(today, -i))];
  }

  /// Consecutive practised days ending today, or ending yesterday if today has no practice
  /// yet (the streak is still alive until the day is over).
  int get currentStreak {
    var date = _dateOnly(clock());
    if (!day(date).practiced) date = _addDays(date, -1);
    var streak = 0;
    while (day(date).practiced) {
      streak++;
      date = _addDays(date, -1);
    }
    return streak;
  }

  int get bestStreak {
    final dates = _log.keys.map(DateTime.parse).toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final date in dates) {
      if (!day(date).practiced) continue;
      run = (previous != null && _addDays(previous, 1) == date) ? run + 1 : 1;
      if (run > best) best = run;
      previous = date;
    }
    return best;
  }

  int get totalMinutes => _log.values.fold(0, (sum, e) => sum + (e['m'] ?? 0));
  int get totalLessons => _log.values.fold(0, (sum, e) => sum + (e['l'] ?? 0));

  void _bump(DateTime when, String field) {
    final key = _dayKey(when);
    final entry = _log.putIfAbsent(key, () => {});
    entry[field] = (entry[field] ?? 0) + 1;
    _trim();
    _prefs?.setString(_logKey, jsonEncode(_log));
    notifyListeners();
  }

  void _trim() {
    if (_log.length <= _daysKept) return;
    final keys = _log.keys.toList()..sort();
    for (final key in keys.take(_log.length - _daysKept)) {
      _log.remove(key);
    }
  }

  Map<String, Map<String, int>> _readLog() {
    final raw = _prefs?.getString(_logKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as Map<String, dynamic>).map((f, n) => MapEntry(f, n as int))));
    } catch (_) {
      return {};
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // Calendar arithmetic, not 24-hour steps: days are 23 or 25 hours long when clocks change.
  static DateTime _addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
