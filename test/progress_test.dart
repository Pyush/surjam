import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/audio/audio_engine.dart';
import 'package:surjam/core/audio/sound_event.dart';
import 'package:surjam/core/learn/practice_session.dart';
import 'package:surjam/core/progress/practice_tracker.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';
import 'package:surjam/features/progress/screens/progress_screen.dart';
import 'package:surjam/shared/widgets/lesson_stars.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tracker = PracticeTracker.instance;
  late DateTime now;

  setUpAll(() {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async => 1);
    }
    PracticeTracker.clock = () => now;
  });

  tearDownAll(() => PracticeTracker.clock = DateTime.now);

  setUp(() async {
    now = DateTime(2026, 10, 9, 18, 30);
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
    await tracker.reloadForTest();
  });

  /// Plays for [minutes] distinct minutes on [day] (one sound per minute).
  void practise(DateTime day, {int minutes = 1}) {
    for (int m = 0; m < minutes; m++) {
      now = DateTime(day.year, day.month, day.day, 19, m);
      tracker.onSoundPlayed();
    }
  }

  group('Minutes and lessons', () {
    test('Many sounds in one minute count as one minute', () {
      for (int i = 0; i < 20; i++) {
        tracker.onSoundPlayed();
      }
      now = now.add(const Duration(minutes: 1));
      tracker.onSoundPlayed();
      expect(tracker.today.minutes, equals(2));
    });

    test('Playing through the engine counts; replays and metronome clicks do not', () {
      AudioEngine().playPianoNote(60);
      expect(tracker.today.minutes, equals(1));

      now = now.add(const Duration(minutes: 1));
      AudioEngine().playClick();
      AudioEngine().playWithoutRecording(SoundEvent.tabla('dha'));
      expect(tracker.today.minutes, equals(1));
    });

    test('Finishing a lesson on any instrument counts', () {
      final piano = PianoProvider();
      piano.startLearnExercise('ex_progress', [60]);
      piano.onNoteDown(60);

      final guitar = PracticeSession('gtr_progress', ['E Minor']);
      guitar.attempt('E Minor');

      expect(tracker.today.lessons, equals(2));
      expect(tracker.totalLessons, equals(2));
    });

    test('The log survives an app restart', () async {
      practise(DateTime(2026, 10, 9), minutes: 3);
      await tracker.reloadForTest();
      expect(tracker.today.minutes, equals(3));
    });

    test('Daily goal defaults to 5 minutes and can be changed', () async {
      expect(tracker.dailyGoalMinutes, equals(5));
      await tracker.setDailyGoalMinutes(15);
      expect(tracker.dailyGoalMinutes, equals(15));
    });
  });

  group('Streaks', () {
    test('Consecutive days ending today', () {
      practise(DateTime(2026, 10, 6));
      // Oct 7 missed: breaks the streak
      practise(DateTime(2026, 10, 8));
      practise(DateTime(2026, 10, 9));
      now = DateTime(2026, 10, 9, 21);
      expect(tracker.currentStreak, equals(2));
    });

    test('A streak stays alive until today ends without practice', () {
      practise(DateTime(2026, 10, 7));
      practise(DateTime(2026, 10, 8));
      now = DateTime(2026, 10, 9, 8); // nothing played yet today
      expect(tracker.currentStreak, equals(2));
      now = DateTime(2026, 10, 10, 8); // a whole day missed
      expect(tracker.currentStreak, equals(0));
    });

    test('Best streak spans month ends and survives a later gap', () {
      for (final day in [28, 29, 30]) {
        practise(DateTime(2026, 9, day));
      }
      practise(DateTime(2026, 10, 1));
      practise(DateTime(2026, 10, 5));
      now = DateTime(2026, 10, 9, 21);
      expect(tracker.bestStreak, equals(4));
      expect(tracker.currentStreak, equals(0));
    });

    test('Last seven days run oldest to today', () {
      practise(DateTime(2026, 10, 3), minutes: 2);
      practise(DateTime(2026, 10, 9), minutes: 4);
      now = DateTime(2026, 10, 9, 21);
      final week = tracker.recentDays();
      expect(week.map((d) => d.date.day), equals([3, 4, 5, 6, 7, 8, 9]));
      expect(week.map((d) => d.minutes), equals([2, 0, 0, 0, 0, 0, 4]));
    });
  });

  test('Stars reward clean runs', () {
    expect(lessonStars(0, 8), equals(0));
    expect(lessonStars(800, 8), equals(3)); // no mistakes
    expect(lessonStars(650, 8), equals(2)); // a few mistakes (>= 80%)
    expect(lessonStars(400, 8), equals(1));
  });

  testWidgets('Progress screen shows streaks, today and the week on a small phone', (tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    practise(DateTime(2026, 10, 8), minutes: 6);
    practise(DateTime(2026, 10, 9), minutes: 3);
    now = DateTime(2026, 10, 9, 21);

    await tester.pumpWidget(const MaterialApp(home: ProgressScreen()));
    expect(find.text('2 days'), findsNWidgets(2)); // current and best streak
    expect(find.text('3 / 5 min'), findsOneWidget);
    expect(find.text('2 more minutes to reach your daily goal'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'Minutes played in the last 7 days: .*Thu 6 minutes, Fri 3 minutes')), findsOneWidget);
    final chart = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter.runtimeType.toString() == '_WeekChartPainter',
    );
    expect(tester.getSize(chart).width, greaterThan(250)); // spans the card, not collapsed to zero
    expect(tester.takeException(), isNull);
  });
}
