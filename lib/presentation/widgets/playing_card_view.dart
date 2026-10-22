import 'package:flutter/material.dart';

import '../../domain/models/card.dart' as bj;

/// A simple visual playing card (rank in the corners, large suit in the middle).
/// Use [PlayingCardView.back] for a face-down card.
class PlayingCardView extends StatelessWidget {
  const PlayingCardView(this.card, {super.key, this.width = 62})
      : faceDown = false;

  const PlayingCardView.back({super.key, this.width = 62})
      : card = null,
        faceDown = true;

  final bj.Card? card;
  final double width;
  final bool faceDown;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.42;
    final radius = width * 0.14;

    if (faceDown || card == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2E4B8F),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white24, width: 2),
        ),
      );
    }

    final c = card!;
    final isRed = c.suit == bj.Suit.hearts || c.suit == bj.Suit.diamonds;
    final color = isRed ? const Color(0xFFD32F2F) : const Color(0xFF1A1A1A);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.08),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                c.rank.label,
                style: TextStyle(
                  color: color,
                  fontSize: width * 0.3,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            Center(
              child: Text(
                c.suit.symbol,
                style: TextStyle(color: color, fontSize: width * 0.42),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                c.suit.symbol,
                style: TextStyle(color: color, fontSize: width * 0.26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
