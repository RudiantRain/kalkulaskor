import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../shared/theme/chart_palette.dart';

/// Cumulative score of every player across the rounds played - one line each,
/// two to four lines.
///
/// The job is "trend over time" plus "tell distinct series apart", so: a
/// multi-line chart with categorical color.
class ScoreProgressChart extends StatelessWidget {
  const ScoreProgressChart({
    super.key,
    required this.rounds,
    required this.playerNames,
    required this.decidingPlayerIndex,
  });

  /// Cumulative totals: outer list is rounds (index 0 is the 0-0 start), inner
  /// list is one entry per player.
  final List<List<int>> rounds;

  final List<String> playerNames;

  /// The player the result is about. Only this line gets a direct end label -
  /// nudging four converging labels apart detaches them from their lines and
  /// reads as noise, so the rest are carried by the legend below.
  final int decidingPlayerIndex;

  static const _plotHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    // Two points are the minimum that can draw a trend.
    if (rounds.length < 2) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final inkColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final surfaceColor = theme.scaffoldBackgroundColor;

    final seriesColors = List.generate(
      playerNames.length,
      (i) => ChartPalette.series(brightness, i),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.maxFinite,
          height: _plotHeight,
          child: CustomPaint(
            painter: _ScoreLinePainter(
              rounds: rounds,
              seriesColors: seriesColors,
              surfaceColor: surfaceColor,
              inkColor: inkColor,
              decidingPlayerIndex: decidingPlayerIndex,
              decidingLabel: playerNames[decidingPlayerIndex],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Legend(
          playerNames: playerNames,
          finalTotals: rounds.last,
          seriesColors: seriesColors,
          inkColor: inkColor,
        ),
      ],
    );
  }
}

/// Identity channel for the lines, and the visible value label every series
/// needs because the hues sit below 3:1 on this surface.
class _Legend extends StatelessWidget {
  const _Legend({
    required this.playerNames,
    required this.finalTotals,
    required this.seriesColors,
    required this.inkColor,
  });

  final List<String> playerNames;
  final List<int> finalTotals;
  final List<Color> seriesColors;
  final Color inkColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (var i = 0; i < playerNames.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // A line-key, matching the mark it identifies. Identity lives in
              // this swatch so the text can stay in readable ink.
              Container(width: 14, height: 2, color: seriesColors[i]),
              const SizedBox(width: 6),
              Text(
                '${playerNames[i]} ${finalTotals[i]}',
                style: TextStyle(fontSize: 12, color: inkColor),
              ),
            ],
          ),
      ],
    );
  }
}

class _ScoreLinePainter extends CustomPainter {
  _ScoreLinePainter({
    required this.rounds,
    required this.seriesColors,
    required this.surfaceColor,
    required this.inkColor,
    required this.decidingPlayerIndex,
    required this.decidingLabel,
  });

  final List<List<int>> rounds;
  final List<Color> seriesColors;
  final Color surfaceColor;
  final Color inkColor;
  final int decidingPlayerIndex;
  final String decidingLabel;

  static const _lineWidth = 2.0;
  static const _endDotRadius = 4.0; // an 8px mark
  static const _surfaceRing = 2.0;
  static const _labelGap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final (minValue, maxValue) = _valueRange();

    final maxTick = _label('$maxValue', muted: true);
    final minTick = _label('$minValue', muted: true);
    final endLabel = _label(decidingLabel, muted: false);

    final tickHeight = max(maxTick.height, minTick.height);

    // Tick and end labels are centred on their value, so the topmost one is
    // half a line tall above the plot. Reserve that, or it gets clipped by the
    // canvas edge. Same for the x-axis band at the bottom.
    final topInset = max(
      _endDotRadius + _surfaceRing,
      max(tickHeight, endLabel.height) / 2,
    );
    final xAxisBand = tickHeight + 4;

    final leftGutter = max(maxTick.width, minTick.width) + _labelGap;
    final rightGutter =
        endLabel.width + _labelGap + _endDotRadius + _surfaceRing;

    final plot = Rect.fromLTRB(
      leftGutter,
      topInset,
      size.width - rightGutter,
      size.height - xAxisBand,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    double xFor(int round) =>
        plot.left + plot.width * (round / (rounds.length - 1));
    double yFor(int value) =>
        plot.bottom -
        plot.height * ((value - minValue) / (maxValue - minValue));

    _paintGrid(canvas, plot, minValue, maxValue, yFor, maxTick, minTick);
    _paintXAxisLabels(canvas, plot, size.height - xAxisBand + 2);
    _paintLines(canvas, xFor, yFor);
    _paintEndDots(canvas, xFor, yFor);

    // Lines get their value at the end - for the one series the story is about.
    final endY = yFor(rounds.last[decidingPlayerIndex]);
    endLabel.paint(
      canvas,
      Offset(
        plot.right + _endDotRadius + _labelGap,
        // Kept inside the canvas: a line finishing at the very top or bottom
        // would otherwise have its label cut in half.
        (endY - endLabel.height / 2).clamp(0.0, size.height - endLabel.height),
      ),
    );
  }

  (int, int) _valueRange() {
    var lowest = rounds.first.first;
    var highest = rounds.first.first;
    for (final round in rounds) {
      for (final total in round) {
        lowest = min(lowest, total);
        highest = max(highest, total);
      }
    }
    // A flat game (everyone still on zero) would divide by zero otherwise.
    if (lowest == highest) return (lowest - 1, highest + 1);
    return (lowest, highest);
  }

  /// Hairline, solid, one step off the surface - never dashed, never loud.
  void _paintGrid(
    Canvas canvas,
    Rect plot,
    int minValue,
    int maxValue,
    double Function(int) yFor,
    TextPainter maxTick,
    TextPainter minTick,
  ) {
    final grid = Paint()
      ..color = inkColor.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (final value in [maxValue, minValue]) {
      final y = yFor(value);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
    }

    // The zero baseline earns a touch more weight: these scores go negative,
    // so "above or below zero" is part of reading the chart.
    if (minValue < 0 && maxValue > 0) {
      final baseline = Paint()
        ..color = inkColor.withValues(alpha: 0.3)
        ..strokeWidth = 1;
      final y = yFor(0);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), baseline);
    }

    maxTick.paint(
      canvas,
      Offset(plot.left - _labelGap - maxTick.width, yFor(maxValue) - maxTick.height / 2),
    );
    minTick.paint(
      canvas,
      Offset(plot.left - _labelGap - minTick.width, yFor(minValue) - minTick.height / 2),
    );
  }

  void _paintXAxisLabels(Canvas canvas, Rect plot, double y) {
    final start = _label('Babak 0', muted: true);
    final end = _label('Babak ${rounds.length - 1}', muted: true);

    start.paint(canvas, Offset(plot.left, y));
    end.paint(canvas, Offset(plot.right - end.width, y));
  }

  void _paintLines(
    Canvas canvas,
    double Function(int) xFor,
    double Function(int) yFor,
  ) {
    for (var player = 0; player < seriesColors.length; player++) {
      final path = Path();
      for (var round = 0; round < rounds.length; round++) {
        final point = Offset(xFor(round), yFor(rounds[round][player]));
        if (round == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = seriesColors[player]
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  /// End markers, each behind a 2px ring in the surface color so they stay
  /// legible where lines cross or two players finish level.
  void _paintEndDots(
    Canvas canvas,
    double Function(int) xFor,
    double Function(int) yFor,
  ) {
    final lastRound = rounds.length - 1;

    for (var player = 0; player < seriesColors.length; player++) {
      final center = Offset(xFor(lastRound), yFor(rounds[lastRound][player]));

      canvas.drawCircle(
        center,
        _endDotRadius + _surfaceRing,
        Paint()..color = surfaceColor,
      );
      canvas.drawCircle(
        center,
        _endDotRadius,
        Paint()..color = seriesColors[player],
      );
    }
  }

  /// Text always wears an ink token, never a series color.
  TextPainter _label(String text, {required bool muted}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 11,
          color: inkColor.withValues(alpha: muted ? 0.6 : 1),
          fontWeight: muted ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  bool shouldRepaint(_ScoreLinePainter old) {
    return old.rounds != rounds ||
        old.seriesColors != seriesColors ||
        old.surfaceColor != surfaceColor ||
        old.inkColor != inkColor ||
        old.decidingPlayerIndex != decidingPlayerIndex ||
        old.decidingLabel != decidingLabel;
  }
}
