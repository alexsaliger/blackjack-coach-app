import 'package:flutter/material.dart';

import '../../domain/models/action.dart';

/// The row of play-decision buttons. Once [revealed] is true, the [correct]
/// action is highlighted green and a wrong [chosen] action red, giving instant
/// visual feedback.
class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onAction,
    this.actions = PlayerAction.values,
    this.enabled = true,
    this.revealed = false,
    this.correct,
    this.chosen,
  });

  final void Function(PlayerAction action) onAction;
  final List<PlayerAction> actions;
  final bool enabled;
  final bool revealed;
  final PlayerAction? correct;
  final PlayerAction? chosen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final action in actions)
          _button(context, scheme, action),
      ],
    );
  }

  Widget _button(BuildContext context, ColorScheme scheme, PlayerAction action) {
    Color? bg;
    Color? fg;
    if (revealed) {
      if (action == correct) {
        bg = const Color(0xFF2E7D32);
        fg = Colors.white;
      } else if (action == chosen) {
        bg = const Color(0xFFC62828);
        fg = Colors.white;
      }
    }

    return FilledButton(
      onPressed: enabled && !revealed ? () => onAction(action) : null,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg,
        disabledForegroundColor: fg,
      ),
      child: Text(action.label),
    );
  }
}
