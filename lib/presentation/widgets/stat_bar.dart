import 'package:flutter/material.dart';

/// A small row of labelled statistics (accuracy, streak, …).
class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.stats});

  /// Ordered label → value pairs.
  final Map<String, String> stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final entry in stats.entries)
          Column(
            children: [
              Text(
                entry.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scheme.secondary,
                ),
              ),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
