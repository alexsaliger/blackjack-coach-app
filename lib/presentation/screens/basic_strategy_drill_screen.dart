import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hand.dart';
import '../../state/basic_strategy_drill_controller.dart';
import '../widgets/action_buttons.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/playing_card_view.dart';
import '../widgets/stat_bar.dart';

class BasicStrategyDrillScreen extends ConsumerWidget {
  const BasicStrategyDrillScreen({super.key});

  String _handLabel(Hand hand) {
    if (hand.isPair) return 'Paar ${hand.cards.first.rank.label}';
    final prefix = hand.isSoft ? 'Soft ' : '';
    return '$prefix${hand.total}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicStrategyDrillProvider);
    final controller = ref.read(basicStrategyDrillProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final s = state.scenario;

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Strategy')),
      body: SafeArea(
        child: Center(
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
                const SizedBox(height: 28),

                // Dealer
                Text('Dealer', style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PlayingCardView(s.dealerUp, width: 70),
                    const SizedBox(width: 8),
                    const PlayingCardView.back(width: 70),
                  ],
                ),
                const SizedBox(height: 28),

                // Player
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deine Hand',
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                    Text(
                      _handLabel(s.player),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final c in s.player.cards) ...[
                      PlayingCardView(c, width: 70),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 28),

                ActionButtons(
                  onAction: controller.answer,
                  revealed: state.revealed,
                  correct: state.correctAction,
                  chosen: state.chosen,
                ),
                const SizedBox(height: 20),

                if (state.revealed) ...[
                  FeedbackBanner(
                    correct: state.wasCorrect ?? false,
                    message: (state.wasCorrect ?? false)
                        ? 'Richtig! ${state.correctAction?.label}'
                        : 'Korrekt wäre: ${state.correctAction?.label}',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.next,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Nächste Hand'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
