import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/audio/metronome_service.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/dholak/models/dholak_model.dart';
import 'package:surjam/features/dholak/providers/dholak_provider.dart';
import 'package:surjam/features/dholak/screens/dholak_screen.dart';
import 'package:surjam/features/djlooper/providers/dj_looper_provider.dart';
import 'package:surjam/features/djlooper/screens/dj_looper_screen.dart';
import 'package:surjam/features/guitar/providers/guitar_provider.dart';
import 'package:surjam/features/guitar/screens/guitar_screen.dart';
import 'package:surjam/features/harmonium/providers/harmonium_provider.dart';
import 'package:surjam/features/harmonium/screens/harmonium_screen.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';
import 'package:surjam/features/piano/screens/piano_screen.dart';
import 'package:surjam/features/tabla/providers/tabla_provider.dart';
import 'package:surjam/features/tabla/screens/tabla_screen.dart';
import 'package:surjam/features/violin/providers/violin_provider.dart';
import 'package:surjam/features/violin/screens/violin_screen.dart';
import 'package:surjam/features/xylophone/providers/xylophone_provider.dart';
import 'package:surjam/features/xylophone/screens/xylophone_screen.dart';
import 'package:surjam/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async => 1);
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  /// Runs the real app (with its global providers) and opens [screen] on top of Home.
  Future<NavigatorState> openScreen(WidgetTester tester, Widget screen) async {
    // Wide logical size: the test font draws every glyph as a full square, which would
    // otherwise overflow dropdowns that real fonts fit comfortably.
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SurJamApp());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute(builder: (_) => screen));
    await tester.pumpAndSettle();
    return navigator;
  }

  // Screen-scoped providers sit inside the screen widget, so look them up from its Scaffold.
  T providerOn<T>(WidgetTester tester, Type screenType) => Provider.of<T>(
        tester.element(find.descendant(of: find.byType(screenType), matching: find.byType(Scaffold)).first),
        listen: false,
      );

  Future<void> leave(WidgetTester tester, NavigatorState navigator) async {
    navigator.pop();
    await tester.pumpAndSettle();
  }

  /// Lets audio timers started by key presses run out so the test ends cleanly.
  Future<void> drain(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 31));
  }

  group('Leaving a screen stops its sound', () {
    testWidgets('Tabla taal sequencer', (tester) async {
      final navigator = await openScreen(tester, const TablaScreen());
      final tabla = providerOn<TablaProvider>(tester, TablaScreen);
      tabla.startTaalPlayer();
      await tester.pump(const Duration(seconds: 1));

      await leave(tester, navigator);
      final beatWhenLeft = tabla.currentBeatIndex;
      await tester.pump(const Duration(seconds: 3));
      expect(tabla.currentBeatIndex, equals(beatWhenLeft), reason: 'taal kept playing after leaving');
      await drain(tester);
    });

    testWidgets('Piano metronome and Listen demo', (tester) async {
      final navigator = await openScreen(tester, const PianoScreen());
      final piano = providerOn<PianoProvider>(tester, PianoScreen);
      final metronome = providerOn<MetronomeService>(tester, PianoScreen);
      metronome.start();
      piano.startLearnExercise('ex_long', List.generate(20, (i) => 60 + i % 12));
      piano.toggleLearnDemo();
      await tester.pump(const Duration(milliseconds: 300));

      await leave(tester, navigator);
      expect(metronome.isPlaying, isFalse, reason: 'metronome kept clicking after leaving');
      expect(piano.isDemoPlaying, isFalse, reason: 'demo kept playing after leaving');
      await drain(tester);
    });
  });

  group('Sending the app to the background stops ongoing sound', () {
    Future<void> background(WidgetTester tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
    }

    tearDown(() {
      TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });

    testWidgets('Tabla taal', (tester) async {
      await openScreen(tester, const TablaScreen());
      final tabla = providerOn<TablaProvider>(tester, TablaScreen);
      tabla.startTaalPlayer();
      await background(tester);
      expect(tabla.isPlayingTaal, isFalse);
      await drain(tester);
    });

    testWidgets('Piano metronome and demo', (tester) async {
      await openScreen(tester, const PianoScreen());
      final piano = providerOn<PianoProvider>(tester, PianoScreen);
      final metronome = providerOn<MetronomeService>(tester, PianoScreen);
      metronome.start();
      piano.startLearnExercise('ex_bg', [60, 62, 64]);
      piano.toggleLearnDemo();
      await background(tester);
      expect(metronome.isPlaying, isFalse);
      expect(piano.isDemoPlaying, isFalse);
      await drain(tester);
    });

    testWidgets('Dholak beat loop', (tester) async {
      await openScreen(tester, const DholakScreen());
      final dholak = providerOn<DholakProvider>(tester, DholakScreen);
      dholak.setPattern(DholakFolkPattern.preloadedPatterns.first);
      dholak.startLoop();
      await background(tester);
      expect(dholak.isLoopPlaying, isFalse);
      await drain(tester);
    });

    testWidgets('DJ loops', (tester) async {
      await openScreen(tester, const DJLooperScreen());
      final dj = providerOn<DJLooperProvider>(tester, DJLooperScreen);
      dj.toggleTrack('drums');
      await background(tester);
      expect(dj.isMasterPlaying, isFalse);
      await drain(tester);
    });

    testWidgets('Guitar auto strum', (tester) async {
      await openScreen(tester, const GuitarScreen());
      final guitar = providerOn<GuitarProvider>(tester, GuitarScreen);
      guitar.startAutoStrum();
      await background(tester);
      expect(guitar.isAutoStrumming, isFalse);
      await drain(tester);
    });

    testWidgets('Harmonium drone', (tester) async {
      await openScreen(tester, const HarmoniumScreen());
      final harmonium = providerOn<HarmoniumProvider>(tester, HarmoniumScreen);
      harmonium.startDrone('sa');
      await background(tester);
      expect(harmonium.activeDrone, equals('none'));
      await drain(tester);
    });
  });

  group('Leaving a screen right after playing a note is safe', () {
    // Key highlights clear on a short timer; closing the screen first used to notify a
    // disposed provider.
    testWidgets('Xylophone', (tester) async {
      final navigator = await openScreen(tester, const XylophoneScreen());
      providerOn<XylophoneProvider>(tester, XylophoneScreen).playKey(60);
      await leave(tester, navigator);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await drain(tester);
    });

    testWidgets('Violin', (tester) async {
      final navigator = await openScreen(tester, const ViolinScreen());
      providerOn<ViolinProvider>(tester, ViolinScreen).onFingerTap(0, 2);
      await leave(tester, navigator);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await drain(tester);
    });
  });

  group('Unsaved recordings are kept when leaving', () {
    testWidgets('Piano', (tester) async {
      final navigator = await openScreen(tester, const PianoScreen());
      final piano = providerOn<PianoProvider>(tester, PianoScreen);
      final before = StorageService().getSavedRecordings().length;
      piano.startRecording();
      piano.onNoteDown(60);
      await leave(tester, navigator);
      await tester.pump(const Duration(milliseconds: 100));
      expect(piano.isRecording, isFalse);
      expect(StorageService().getSavedRecordings().length, equals(before + 1));
      await drain(tester);
    });

    testWidgets('Tabla', (tester) async {
      final navigator = await openScreen(tester, const TablaScreen());
      final tabla = providerOn<TablaProvider>(tester, TablaScreen);
      final before = StorageService().getSavedRecordings().length;
      tabla.startRecording();
      tabla.triggerBol('Dha');
      await leave(tester, navigator);
      await tester.pump(const Duration(milliseconds: 100));
      expect(StorageService().getSavedRecordings().length, equals(before + 1));
      await drain(tester);
    });
  });
}
