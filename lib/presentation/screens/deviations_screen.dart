import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hand.dart';
import '../../domain/strategy/deviations.dart';
import '../../state/deviation_drill_controller.dart';
import '../help_texts.dart';
import '../widgets/action_buttons.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/info_button.dart';
import '../widgets/playing_card_view.dart';
import '../widgets/stat_bar.dart';

String _fmtIndex(double i) => 'TC ≥ ${i.toStringAsFixed(0)}';

class DeviationsScreen extends StatelessWidget {
  const DeviationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Deviations'),
          actions: const [InfoButton(HelpTexts.deviations)],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Übersicht'),
              Tab(text: 'Üben'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              _OverviewTab(),
              _PracticeTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.shield, color: scheme.secondary),
                title: const Text('Versicherung'),
                subtitle: Text(
                    'Nehmen ab ${_fmtIndex(Deviations.insuranceIndex)}'),
              ),
            ),
            const SizedBox(height: 8),
            _header(context, 'Illustrious 18'),
            for (final d in Deviations.illustrious18) _row(context, d),
            const SizedBox(height: 16),
            _header(context, 'Fab 4 — Surrender'),
            for (final d in Deviations.fab4) _row(context, d),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );

  Widget _row(BuildContext context, Deviation d) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(d.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(
              '${d.atOrAbove.label} ab ${_fmtIndex(d.index)} '
              '(sonst ${d.below.label})',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeTab extends ConsumerWidget {
  const _PracticeTab();

  String _handLabel(Hand hand) {
    if (hand.isPair) return 'Paar ${hand.cards.first.rank.label}';
    final prefix = hand.isSoft ? 'Soft ' : '';
    return '$prefix${hand.total}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviationDrillProvider);
    final controller = ref.read(deviationDrillProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final s = state.scenario;
    final tc = s.trueCount.toStringAsFixed(0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            StatBar(stats: {
              'Treffer': '${state.correct}/${state.total}',
              'Quote': '${(state.accuracy * 100).round()}%',
              'Streak': '${state.streak}',
              'Best': '${state.bestStreak}',
            }),
            const SizedBox(height: 20),

            // True count badge — the decisive input for deviations.
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.secondary, width: 1.5),
                ),
                child: Text(
                  'True Count: $tc',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Dealer', style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              children: [
                PlayingCardView(s.dealerUp, width: 66),
                const SizedBox(width: 8),
                const PlayingCardView.back(width: 66),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Deine Hand',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                Text(
                  _handLabel(s.player),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: scheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in s.player.cards) ...[
                  PlayingCardView(c, width: 66),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),

            ActionButtons(
              onAction: controller.answer,
              revealed: state.revealed,
              correct: state.correctAction,
              chosen: state.chosen,
            ),
            const SizedBox(height: 18),

            if (state.revealed) ...[
              FeedbackBanner(
                correct: state.wasCorrect ?? false,
                message: (state.wasCorrect ?? false)
                    ? 'Richtig! ${state.correctAction?.label}'
                    : 'Korrekt: ${state.correctAction?.label}',
              ),
              const SizedBox(height: 8),
              Text(
                '${s.deviation.name} · ${s.deviation.atOrAbove.label} ab '
                '${_fmtIndex(s.deviation.index)} (sonst ${s.deviation.below.label})',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: controller.next,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Nächste Hand'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
