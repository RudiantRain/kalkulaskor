// lib/shared/helper/helper.dart
import 'dart:math';

enum ScoreCellState { max, min, normal }

/// Classifies a player's score within a round so the UI can highlight the
/// current leader and trailer of that round.
ScoreCellState scoreCellState(List<int> round, int index) {
  final highest = round.reduce(max);
  final lowest = round.reduce(min);

  if (round[index] == highest) return ScoreCellState.max;
  if (round[index] == lowest) return ScoreCellState.min;
  return ScoreCellState.normal;
}
