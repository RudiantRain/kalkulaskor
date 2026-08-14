import 'package:flutter/material.dart';

import '../../controllers/dashboard_controller.dart';

class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.controller,
    required this.isWinner,
    required this.playerName,
    required this.score,
  });

  final DashboardController controller;
  final bool isWinner;
  final String playerName;
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor =
        isWinner ? theme.indicatorColor : theme.colorScheme.error;
    final textColor = theme.textTheme.bodyLarge?.color;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GAME!',
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Icon(
            isWinner
                ? Icons.emoji_events_rounded
                : Icons.sentiment_very_dissatisfied_rounded,
            size: 72,
            color: accentColor,
          ),
          const SizedBox(height: 10),
          Text(
            '$playerName ${isWinner ? 'MENANG!' : 'KALAH!'}',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Skor $score',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: controller.acknowledgeGameResult,
          child: const Text('OK. Mulai Ulang!'),
        ),
      ],
    );
  }
}
