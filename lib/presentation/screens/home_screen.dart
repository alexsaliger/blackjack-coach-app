import 'package:flutter/material.dart';

import '../help_texts.dart';
import '../widgets/info_button.dart';

/// Landing screen: app title plus tiles for each trainer. The two core
/// trainers are active; the rest are shown as upcoming (Phase 3).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                Text(
                  "Coaches don't Play",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.secondary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Blackjack Strategy & Card Counting Trainer',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: () => showInfoSheet(context, HelpTexts.intro),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text("Neu hier? So funktioniert's"),
                  ),
                ),
                const SizedBox(height: 16),
                _TrainerTile(
                  icon: Icons.style,
                  title: 'Basic Strategy',
                  subtitle: 'Die korrekte Spielentscheidung trainieren',
                  onTap: () => Navigator.pushNamed(context, '/basic'),
                ),
                _TrainerTile(
                  icon: Icons.calculate,
                  title: 'Card Counting',
                  subtitle: 'Hi-Lo Running & True Count üben',
                  onTap: () => Navigator.pushNamed(context, '/counting'),
                ),
                _TrainerTile(
                  icon: Icons.tune,
                  title: 'Deviations',
                  subtitle: 'Illustrious 18 & Fab 4 — Chart & Übung',
                  onTap: () => Navigator.pushNamed(context, '/deviations'),
                ),
                _TrainerTile(
                  icon: Icons.timer,
                  title: 'Speed Count',
                  subtitle: 'Ganzen Shoe gegen die Uhr',
                  onTap: () => Navigator.pushNamed(context, '/speed'),
                ),
                _TrainerTile(
                  icon: Icons.rule,
                  title: 'Regeln & House Edge',
                  subtitle: 'Regelsatz einstellen, Hausvorteil berechnen',
                  onTap: () => Navigator.pushNamed(context, '/rules'),
                ),
                _TrainerTile(
                  icon: Icons.bar_chart,
                  title: 'Statistiken',
                  subtitle: 'Fortschritt & Trefferquoten',
                  onTap: () => Navigator.pushNamed(context, '/stats'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrainerTile extends StatelessWidget {
  const _TrainerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: scheme.secondary.withValues(alpha: 0.18),
          foregroundColor: scheme.secondary,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
