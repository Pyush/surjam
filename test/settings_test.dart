import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surjam/features/piano/providers/piano_provider.dart';
import 'package:surjam/features/settings/screens/privacy_policy_screen.dart';
import 'package:surjam/features/settings/screens/settings_screen.dart';
import 'package:surjam/main.dart';

void main() {
  testWidgets('Settings opens from the home screen and changes note labels', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SurJamApp());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.text('Sargam (Sa, Re, Ga)'));
    await tester.pump();
    final piano = Provider.of<PianoProvider>(tester.element(find.byType(SettingsScreen)), listen: false);
    expect(piano.keyLabelMode, equals('sargam'));

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.text('Microphone'), findsOneWidget);
  });
}
