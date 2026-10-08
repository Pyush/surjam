import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/main.dart';

void main() {
  testWidgets('SurJamApp builds without throwing exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(const SurJamApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SurJamApp), findsOneWidget);
  });
}
