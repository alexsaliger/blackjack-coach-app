import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/speed_count_controller.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/playing_card_view.dart';

String _fmtTime(int ms) => '${(ms / 1000).toStringAsFixed(1)} s';

class SpeedCountScreen extends ConsumerStatefulWidget {
  const SpeedCountScreen({super.key});

  @override
  ConsumerState<SpeedCountScreen> createState() => _SpeedCountScreenState();
}

class _SpeedCountScreenState extends ConsumerState<SpeedCountScreen> {
  final _guessController = TextEditingController();

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_guessController.text.trim());
    if (value == null) return;
    ref.read(speedCountProvider.notifier).submit(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(speedCountProvider);
    final controller = ref.read(speedCountProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Speed Count')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: switch (state.phase) {
                SpeedPhase.idle => _idle(context, state, controller),
                SpeedPhase.running => _running(context, state, controller),
                SpeedPhase.entering => _entering(context, state),
                SpeedPhase.finished => _finished(context, state, controller),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _idle(
      BuildContext context, SpeedCountState state, SpeedCountController c) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer, size: 64, color: scheme.secondary),
        const SizedBox(height: 16),
        Text(
          'Zähle den ganzen Shoe so schnell wie möglich herunter. '
          'Tippe dich durch alle Karten und gib am Ende den Running Count ein.',
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        const Text('Decks'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final d in const [1, 2])
              ChoiceChip(
                label: Text('$d'),
                selected: state.decks == d,
                onSelected: (_) => c.chooseDecks(d),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: c.start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start'),
        ),
      ],
    );
  }

  Widget _running(
      BuildContext context, SpeedCountState state, SpeedCountController c) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${state.dealt} / ${state.total}',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text(
              _fmtTime(state.elapsedMs),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.secondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: state.total == 0 ? 0 : state.dealt / state.total,
        ),
        const Spacer(),
        if (state.current != null)
          PlayingCardView(state.current!, width: 150),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: c.nextCard,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 26),
            ),
            child: const Text('Nächste Karte',
                style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _entering(BuildContext context, SpeedCountState state) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 56, color: scheme.secondary),
        const SizedBox(height: 12),
        Text('Shoe durch in ${_fmtTime(state.elapsedMs)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        const Text('Dein finaler Running Count'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _guessController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'z. B. 0',
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: _submit, child: const Text('Prüfen')),
          ],
        ),
      ],
    );
  }

  Widget _finished(
      BuildContext context, SpeedCountState state, SpeedCountController c) {
    final scheme = Theme.of(context).colorScheme;
    final ok = state.wasCorrect ?? false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FeedbackBanner(
          correct: ok,
          message: ok
              ? 'Richtig! Running Count = ${state.truthRunning}'
              : 'Running Count = ${state.truthRunning} '
                  '(dein Tipp: ${state.guess})',
        ),
        const SizedBox(height: 24),
        _resultRow(context, 'Zeit', _fmtTime(state.elapsedMs)),
        _resultRow(context, 'Karten', '${state.dealt}'),
        _resultRow(context, 'Tempo',
            '${state.cardsPerSecond.toStringAsFixed(1)} Karten/s'),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: c.reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Nochmal'),
        ),
        const SizedBox(height: 8),
        Text(
          'Ein vollständig gezählter Shoe endet bei 0 — deine Kontrolle.',
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  Widget _resultRow(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
