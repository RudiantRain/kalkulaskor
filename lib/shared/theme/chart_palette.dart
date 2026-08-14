// lib/shared/theme/chart_palette.dart
import 'package:flutter/material.dart';

/// Categorical colors for chart series.
///
/// Slots 1-4 of a validated categorical palette, in fixed order. The dark
/// column is the same four hues re-stepped for a dark surface - NOT the light
/// values reused: the light steps fail the dark lightness band outright
/// (`#eb6834` L 0.671, `#eda100` L 0.764, band 0.48-0.67).
///
/// Verified with the dataviz palette validator against this app's own surfaces
/// (`scaffoldBackgroundColor`: light `#F3F3F3`, dark `#424242`):
/// lightness band, chroma floor, CVD separation and normal-vision floor all
/// pass in both modes (worst adjacent CVD ΔE 9.1 light / 8.4 dark, target ≥8).
///
/// Contrast against the surface warns below 3:1 in both modes, which obliges
/// "relief": every series must carry a visible value label. That is why the
/// chart ships a legend listing each player's final score - it is not optional
/// decoration.
class ChartPalette {
  const ChartPalette._();

  /// Slot order is the colorblind-safety mechanism - do not reorder.
  static const _lightSeries = <Color>[
    Color(0xFF2A78D6), // 1 blue
    Color(0xFFEB6834), // 2 orange
    Color(0xFF1BAF7A), // 3 aqua
    Color(0xFFEDA100), // 4 yellow
  ];

  static const _darkSeries = <Color>[
    Color(0xFF3987E5),
    Color(0xFFD95926),
    Color(0xFF199E70),
    Color(0xFFC98500),
  ];

  /// Color for the series at [index].
  ///
  /// Keyed to the player's position, never to their rank - a leader changing
  /// must not repaint the lines. Hues are never cycled; the game caps players
  /// at four, which is exactly the number of slots.
  static Color series(Brightness brightness, int index) {
    final slots = brightness == Brightness.dark ? _darkSeries : _lightSeries;
    return slots[index.clamp(0, slots.length - 1)];
  }
}
