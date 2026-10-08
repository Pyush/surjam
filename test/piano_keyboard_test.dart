import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';
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

  Future<PianoProvider> pumpKeyboard(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final provider = PianoProvider();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: Scaffold(body: KeyboardWidget())),
    ));
    return provider;
  }

  ScrollPosition keyboardScroll(WidgetTester tester) =>
      tester.state<ScrollableState>(find.byType(Scrollable)).position;

  testWidgets('Portrait phone keeps keys finger-sized and scrolls', (tester) async {
    await pumpKeyboard(tester, const Size(393, 600));
    expect(tester.getSize(find.text('C4')).width, lessThan(44)); // label sits inside the key
    expect(keyboardScroll(tester).maxScrollExtent, greaterThan(0));
    // 14 white keys of at least 44dp.
    expect(keyboardScroll(tester).maxScrollExtent + 393, greaterThanOrEqualTo(14 * 44.0));
  });

  testWidgets('Landscape fits both octaves without scrolling', (tester) async {
    await pumpKeyboard(tester, const Size(852, 393));
    expect(keyboardScroll(tester).maxScrollExtent, equals(0));
  });

  testWidgets('Learn mode scrolls to an off-screen target note', (tester) async {
    final provider = await pumpKeyboard(tester, const Size(393, 600));
    provider.startLearnExercise('ex_scroll', [60, 83]); // C4 then B5 at the far right
    await tester.pumpAndSettle();
    expect(keyboardScroll(tester).pixels, equals(0));

    provider.onNoteDown(60);
    await tester.pumpAndSettle();
    expect(keyboardScroll(tester).pixels, greaterThan(0));
    expect(tester.getCenter(find.text('B5')).dx, inInclusiveRange(0, 393));

    // Let audio playback timers started by the key press finish.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 31));
  });
}
