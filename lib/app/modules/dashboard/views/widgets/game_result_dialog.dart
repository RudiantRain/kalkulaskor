import 'package:flutter/material.dart';

import '../../controllers/dashboard_controller.dart';
import 'score_progress_chart.dart';

class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.controller,
    required this.isWinner,
    required this.playerIndex,
    required this.score,
  });

  final DashboardController controller;
  final bool isWinner;

  /// Position of the player the result is about - an index rather than a name,
  /// so the chart can key the highlight to the right line even if two players
  /// happen to share a name.
  final int playerIndex;

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = isWinner
        ? theme.canvasColor
        : theme.colorScheme.error;
    final textColor = theme.textTheme.bodyLarge?.color;
    final playerName = controller.playerNames[playerIndex];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // Scrollable: the chart and its legend make this the tallest dialog in
      // the app, and a short screen would otherwise overflow.
      content: SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 20),
            Divider(
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Grafik Skor',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Read while the dialog is up: resetGame only runs after it closes,
            // so the full history is still in place here.
            ScoreProgressChart(
              rounds: controller.scores.toList(),
              playerNames: controller.playerNames.toList(),
              decidingPlayerIndex: playerIndex,
            ),
             const SizedBox(height: 20),
            Divider(
              color: Colors.grey,
            ),
          ],
        ),
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
