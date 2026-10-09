import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/learn/practice_session.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/guitar/models/guitar_chord_model.dart';
import 'package:surjam/features/guitar/providers/guitar_provider.dart';
import 'package:surjam/features/guitar/screens/guitar_screen.dart';
import 'package:surjam/features/learn/models/practice_lesson.dart';
import 'package:surjam/features/learn/screens/exercise_list_screen.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';
import 'package:surjam/features/tabla/models/taal_model.dart';
import 'package:surjam/features/tabla/providers/tabla_provider.dart';
import 'package:surjam/features/tabla/screens/tabla_screen.dart';

/// Bols that have a button on the tabla screen.
const _playableBols = {'dha', 'dhin', 'na', 'tin', 'ge', 'ke', 'ta', 'tun'};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async => 1);
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  group('PracticeSession', () {
    test('Correct targets score, mistakes cost points, completion saves the best score', () async {
      final session = PracticeSession('test_practice_${DateTime.now().microsecondsSinceEpoch}', ['A', 'B']);
      expect(session.target, equals('A'));
      expect(session.attempt('B'), isFalse);
      expect(session.mistakes, equals(1));
      expect(session.score, equals(0)); // never below zero
      expect(session.attempt('a'), isTrue); // case-insensitive
      expect(session.attempt('B'), isTrue);
      expect(session.isComplete, isTrue);
      expect(session.target, isNull);
      expect(session.score, equals(200));
      expect(session.bestScore, equals(200));

      session.restart();
      expect((session.step, session.score, session.mistakes, session.target), equals((0, 0, 0, 'A')));
    });
  });

  group('Lesson content', () {
    test('Every guitar target is a chord in the library', () {
      final chordNames = GuitarChordModel.preloadedChords.map((c) => c.name).toSet();
      for (final lesson in PracticeLesson.guitarLessons) {
        expect(chordNames.containsAll(lesson.targets), isTrue, reason: lesson.id);
      }
    });

    test('Every tabla target has a button, and each theka matches its taal', () {
      for (final lesson in PracticeLesson.tablaLessons) {
        for (final bol in lesson.targets) {
          expect(_playableBols, contains(bol.toLowerCase()), reason: '${lesson.id}: $bol');
        }
      }
      for (final taal in TaalModel.preloadedTaals) {
        final lesson = PracticeLesson.tablaLessons.firstWhere((l) => l.id == 'tbl_${taal.id}');
        expect(lesson.targets, equals([for (final b in taal.beats) b.bol]), reason: taal.id);
      }
    });

    test('Lesson ids are unique and do not clash with piano lessons', () {
      final ids = PracticeLesson.all.map((l) => l.id).toList();
      expect(ids.toSet().length, equals(ids.length));
      expect(ids.every((id) => id.startsWith('gtr_') || id.startsWith('tbl_')), isTrue);
    });
  });

  group('Guitar practice', () {
    GuitarChordModel chord(String name) => GuitarChordModel.preloadedChords.firstWhere((c) => c.name == name);

    testWidgets('Strumming the target chord advances; a wrong chord is a mistake', (tester) async {
      final guitar = GuitarProvider();
      guitar.startPractice('gtr_test', ['E Minor', 'A7']);
      expect(guitar.chordCategory, equals('Minor')); // palette shows the target

      guitar.selectChord(chord('C Major'));
      guitar.strumChord();
      expect(guitar.practice!.mistakes, equals(1));

      guitar.selectChord(chord('E Minor'));
      guitar.strumChord();
      expect(guitar.practice!.target, equals('A7'));
      expect(guitar.chordCategory, equals('7th')); // moved to the next target's category

      guitar.selectChord(chord('A7'));
      guitar.strumChord(isDownStrum: false);
      expect(guitar.practice!.isComplete, isTrue);
      await tester.pump(const Duration(seconds: 1));
      guitar.dispose();
    });

    testWidgets('Auto strum is turned off and never counts', (tester) async {
      final guitar = GuitarProvider();
      guitar.startAutoStrum();
      guitar.startPractice('gtr_test', ['E Minor']);
      expect(guitar.isAutoStrumming, isFalse);

      guitar.selectChord(chord('E Minor'));
      guitar.strumChord(isAutomated: true);
      expect(guitar.practice!.step, equals(0));
      await tester.pump(const Duration(seconds: 1));
      guitar.dispose();
    });
  });

  group('Tabla practice', () {
    testWidgets('Only the player\'s own strokes count', (tester) async {
      final tabla = TablaProvider();
      tabla.startTaalPlayer();
      tabla.startPractice('tbl_test', ['Dha', 'Na']);
      expect(tabla.isPlayingTaal, isFalse);

      tabla.triggerBol('Dha', isAutomated: true);
      expect(tabla.practice!.step, equals(0));
      tabla.triggerBol('Dha');
      tabla.triggerBol('Tin');
      tabla.triggerBol('Na');
      expect(tabla.practice!.isComplete, isTrue);
      expect(tabla.practice!.mistakes, equals(1));
      await tester.pump(const Duration(seconds: 1));
      tabla.dispose();
    });
  });

  group('Learn hub', () {
    Future<void> openHub(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => PianoProvider(),
        child: const MaterialApp(home: ExerciseListScreen()),
      ));
    }

    testWidgets('A guitar lesson opens the guitar in practice mode', (tester) async {
      await openHub(tester);
      await tester.tap(find.text('Guitar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PracticeLesson.guitarLessons.first.title));
      await tester.pumpAndSettle();

      expect(find.byType(GuitarScreen), findsOneWidget);
      expect(find.text('Next: E Minor  (1/8)'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });

    testWidgets('A tabla lesson opens the tabla in practice mode', (tester) async {
      await openHub(tester);
      await tester.tap(find.text('Tabla'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Basic Bols'));
      await tester.pumpAndSettle();

      expect(find.byType(TablaScreen), findsOneWidget);
      expect(find.text('Next: Dha  (1/12)'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });
  });
}
