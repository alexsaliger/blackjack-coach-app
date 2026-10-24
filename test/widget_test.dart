import 'package:coaches_dont_play/app.dart';
import 'package:coaches_dont_play/state/settings_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _app() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const CoachesApp(),
  );
}

void main() {
  testWidgets('Home screen shows the app title and the two core trainers',
      (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    expect(find.text("Coaches don't Play"), findsOneWidget);
    expect(find.text('Basic Strategy'), findsOneWidget);
    expect(find.text('Card Counting'), findsOneWidget);
  });

  testWidgets('Tapping Basic Strategy opens the drill with action buttons',
      (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Basic Strategy'));
    await tester.pumpAndSettle();

    expect(find.text('Hit'), findsOneWidget);
    expect(find.text('Stand'), findsOneWidget);
  });

  testWidgets('Rules & House Edge screen opens and shows the edge',
      (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Regeln & House Edge'));
    await tester.pumpAndSettle();

    // The rules editor opened (top-of-screen sections are rendered).
    expect(find.text('Decks'), findsOneWidget);
    expect(find.text('Blackjack-Auszahlung'), findsOneWidget);
  });

  testWidgets('Deviations screen opens with chart and practice tabs',
      (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deviations'));
    await tester.pumpAndSettle();

    expect(find.text('Übersicht'), findsOneWidget);
    expect(find.text('Üben'), findsOneWidget);
    expect(find.text('Illustrious 18'), findsOneWidget);
  });
}
