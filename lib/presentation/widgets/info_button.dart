import 'package:flutter/material.dart';

import '../help_texts.dart';

/// An AppBar info icon that opens a bottom sheet explaining a concept.
class InfoButton extends StatelessWidget {
  const InfoButton(this.help, {super.key});

  final HelpText help;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: 'Was ist das?',
      onPressed: () => showInfoSheet(context, help),
    );
  }
}

/// Shows [help] as a scrollable bottom sheet. Reusable from anywhere.
Future<void> showInfoSheet(BuildContext context, HelpText help) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
            maxWidth: 560,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: scheme.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        help.title,
                        style: Theme.of(ctx)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  help.body,
                  style: Theme.of(ctx)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
