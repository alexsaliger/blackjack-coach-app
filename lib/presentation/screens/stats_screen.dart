import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/stats.dart';
import '../../state/stats_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiken')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _categoryCard(context, 'Basic Strategy', stats.basic),
                _categoryCard(context, 'Card Counting', stats.counting,
                    showStreak: false),
                _categoryCard(context, 'Deviations', stats.deviations),
                _speedCard(context, stats),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _confirmReset(context, ref),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Statistiken zurücksetzen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(BuildContext context, String title, CategoryStats s,
      {bool showStreak = true}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _metric(context, '${(s.accuracy * 100).round()}%', 'Quote'),
                _metric(context, '${s.correct}/${s.total}', 'Treffer'),
                if (showStreak)
                  _metric(context, '${s.bestStreak}', 'Beste Streak'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _speedCard(BuildContext context, StatsData stats) {
    final best = stats.speedBestTimeMs == 0
        ? '–'
        : '${(stats.speedBestTimeMs / 1000).toStringAsFixed(1)} s';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Speed Count',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _metric(context, best, 'Bestzeit'),
                _metric(context, '${stats.speedRuns}', 'Läufe'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(BuildContext context, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.secondary)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Statistiken zurücksetzen?'),
        content: const Text('Alle gespeicherten Statistiken werden gelöscht.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Zurücksetzen')),
        ],
      ),
    );
    if (ok == true) ref.read(statsProvider.notifier).resetAll();
  }
}
