import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/main.dart';

void main() {
  testWidgets('Rise app displays its main navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const RiseApp());

    expect(find.text('Rise 🌅'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
  });
}