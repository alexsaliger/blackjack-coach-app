import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/counting_drill_controller.dart';
import '../help_texts.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/info_button.dart';
import '../widgets/playing_card_view.dart';
import '../widgets/signed_count_input.dart';
import '../widgets/stat_bar.dart';

class CountingDrillScreen extends ConsumerStatefulWidget {
  const CountingDrillScreen({super.key});

  @override
  ConsumerState<CountingDrillScreen> createState() =>
      _CountingDrillScreenState();
}

class _CountingDrillScreenState extends ConsumerState<CountingDrillScreen> {
  final _guessController = TextEditingController();

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _check() {
    final value = int.tryParse(_guessController.text.trim());
    if (value == null) return;
    ref.read(countingDrillProvider.notifier).checkRunningCount(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(countingDrillProvider);
    final controller = ref.read(countingDrillProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    final accuracy =
        state.total == 0 ? 0 : (state.correct / state.total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Counting'),
        actions: const [InfoButton(HelpTexts.counting)],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                StatBar(stats: {
                  'Decks übrig': state.decksRemaining.toStringAsFixed(1),
                  'Karten': '${state.cardsRemaining}',
                  'Count-Quote': '$accuracy%',
                }),
                const SizedBox(height: 24),

                // Dealt cards
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: state.dealt.isEmpty
                      ? Text(
                          'Tippe „Nächste Karte", um zu starten',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          reverse: true,
                          child: Row(
                            children: [
                              for (final c in state.dealt) ...[
                                PlayingCardView(c, width: 54),
                                const SizedBox(width: 6),
                              ],
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                if (state.needsReshuffle)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Cut-Card erreicht – bitte neuen Shoe starten.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),

                FilledButton.icon(
                  onPressed: state.needsReshuffle ? null : controller.dealNext,
                  icon: const Icon(Icons.add),
                  label: const Text('Nächste Karte'),
                ),
                const SizedBox(height: 24),

                Text('Dein Running Count',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SignedCountInput(
                        controller: _guessController,
                        onSubmitted: _check,
                        hint: 'z. B. -2',
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _check,
                      child: const Text('Prüfen'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (state.revealed) ...[
                  FeedbackBanner(
                    correct: state.wasCorrect ?? false,
                    message: (state.wasCorrect ?? false)
                        ? 'Richtig! Running Count = ${state.truthRunning}'
                        : 'Running Count = ${state.truthRunning} '
                            '(dein Tipp: ${state.guess})',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'True Count ≈ ${state.truthTrue?.toStringAsFixed(1)}  '
                    '(${state.decksRemaining.toStringAsFixed(1)} Decks übrig)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],

                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: controller.resetShoe,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Neuer Shoe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
