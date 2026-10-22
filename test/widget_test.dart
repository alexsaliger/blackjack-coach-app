import 'package:coaches_dont_play/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen shows the app title and the two core trainers',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CoachesApp()));
    await tester.pumpAndSettle();

    expect(find.text("Coaches don't Play"), findsOneWidget);
    expect(find.text('Basic Strategy'), findsOneWidget);
    expect(find.text('Card Counting'), findsOneWidget);
  });

  testWidgets('Tapping Basic Strategy opens the drill with action buttons',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CoachesApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Basic Strategy'));
    await tester.pumpAndSettle();

    // The drill screen shows the play-decision buttons.
    expect(find.text('Hit'), findsOneWidget);
    expect(find.text('Stand'), findsOneWidget);
  });
}
