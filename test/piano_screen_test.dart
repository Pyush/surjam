import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/audio/metronome_service.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/piano/models/chord_scale_data.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';
import 'package:surjam/features/piano/screens/piano_screen.dart';
import 'package:surjam/features/piano/widgets/keyboard_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async => 1);
    }
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  for (final size in const [Size(360, 640), Size(393, 852)]) {
    testWidgets('Selecting a scale or chord never resizes the keyboard (${size.width.toInt()}dp)', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final piano = PianoProvider();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: piano),
          ChangeNotifierProvider(create: (_) => MetronomeService()),
        ],
        child: const MaterialApp(home: PianoScreen()),
      ));
      await tester.pump();
      final keyboard = find.byType(KeyboardWidget);
      final initial = tester.getRect(keyboard);

      final clearButton = find.byTooltip('Clear highlights');
      expect(tester.widget<Visibility>(find.ancestor(of: clearButton, matching: find.byType(Visibility)).first).visible, isFalse);

      piano.selectScale(MusicTheoryData.scales.keys.first);
      await tester.pump();
      expect(tester.getRect(keyboard), equals(initial));
      expect(tester.widget<Visibility>(find.ancestor(of: clearButton, matching: find.byType(Visibility)).first).visible, isTrue);

      piano.selectChord(MusicTheoryData.chords.keys.last);
      await tester.pump();
      expect(tester.getRect(keyboard), equals(initial));

      await tester.tap(clearButton);
      await tester.pump();
      expect(piano.selectedScale, isNull);
      expect(piano.selectedChord, isNull);
      expect(tester.getRect(keyboard), equals(initial));

      // A lesson shows its progress in the toolbar's place, also without moving the keys.
      piano.startLearnExercise('ex_layout', [60, 62]);
      await tester.pump();
      expect(tester.getRect(keyboard), equals(initial));
      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.byTooltip('Clear highlights').hitTestable(), findsNothing); // toolbar hidden

      piano.onNoteDown(60);
      piano.onNoteDown(62); // completes the lesson: result view
      await tester.pump();
      expect(piano.isLearnComplete, isTrue);
      expect(tester.getRect(keyboard), equals(initial));

      piano.stopLearnExercise();
      await tester.pump();
      expect(tester.getRect(keyboard), equals(initial));

      // Let audio timers from the key presses finish.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });
  }
}
