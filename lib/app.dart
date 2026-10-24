import 'package:flutter/material.dart';

import 'presentation/screens/basic_strategy_drill_screen.dart';
import 'presentation/screens/counting_drill_screen.dart';
import 'presentation/screens/deviations_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/rules_screen.dart';
import 'presentation/screens/speed_count_screen.dart';
import 'presentation/theme/app_theme.dart';

/// Root app widget: theme and routing for the trainer screens.
class CoachesApp extends StatelessWidget {
  const CoachesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Coaches don't Play",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/basic': (_) => const BasicStrategyDrillScreen(),
        '/counting': (_) => const CountingDrillScreen(),
        '/deviations': (_) => const DeviationsScreen(),
        '/speed': (_) => const SpeedCountScreen(),
        '/rules': (_) => const RulesScreen(),
      },
    );
  }
}
