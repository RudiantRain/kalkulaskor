// lib/app/data/models/game_settings.dart

/// The rules of one game: how many players, the multiple every score must fall
/// on, and the total that ends the game.
///
/// Immutable, so a form can build a candidate set and validate it without
/// touching the game in progress. The bounds live here as the single source of
/// truth - the setup form's validators and the controller both read them.
class GameSettings {
  const GameSettings({
    required this.playerCount,
    required this.scoreStep,
    required this.winningScore,
  });

  final int playerCount;
  final int scoreStep;
  final int winningScore;

  static const minPlayerCount = 2;
  static const maxPlayerCount = 4;
  static const minScoreStep = 1;
  static const maxScoreStep = 1000;
  static const minWinningScore = 10;
  static const maxWinningScore = 9999;

  static const defaults = GameSettings(
    playerCount: 4,
    scoreStep: 5,
    winningScore: 500,
  );

  GameSettings copyWith({int? playerCount, int? scoreStep, int? winningScore}) {
    return GameSettings(
      playerCount: playerCount ?? this.playerCount,
      scoreStep: scoreStep ?? this.scoreStep,
      winningScore: winningScore ?? this.winningScore,
    );
  }

  // --- Validation -----------------------------------------------------------
  // Each returns null when valid, or the message to show under the field.
  // int.tryParse throughout: keyboardType.number still admits '-', '.' and
  // pasted text, and a FormatException here would take the dialog down.

  static String? validateScoreStep(String? input) {
    final value = int.tryParse(input?.trim() ?? '');
    if (value == null) return 'Isi dengan angka';
    if (value < minScoreStep || value > maxScoreStep) {
      return 'Antara $minScoreStep - $maxScoreStep';
    }
    return null;
  }

  static String? validateWinningScore(String? input, {String? scoreStepInput}) {
    final value = int.tryParse(input?.trim() ?? '');
    if (value == null) return 'Isi dengan angka';
    if (value < minWinningScore || value > maxWinningScore) {
      return 'Antara $minWinningScore - $maxWinningScore';
    }

    // Cross-field: a target below the step would end the game on the very
    // first entry, so it is never a valid combination.
    final step = int.tryParse(scoreStepInput?.trim() ?? '');
    if (step != null && value < step) {
      return 'Tidak boleh kurang dari kelipatan ($step)';
    }
    return null;
  }

  // --- Storage --------------------------------------------------------------

  Map<String, dynamic> toJson() => {
    'playerCount': playerCount,
    'scoreStep': scoreStep,
    'winningScore': winningScore,
  };

  /// Rebuilds from stored JSON, falling back to [defaults] field by field so a
  /// partially written or older record can never produce an unusable game.
  factory GameSettings.fromJson(Map<dynamic, dynamic> json) {
    int read(String key, int fallback) {
      final value = json[key];
      return value is int ? value : fallback;
    }

    return GameSettings(
      playerCount: read('playerCount', defaults.playerCount)
          .clamp(minPlayerCount, maxPlayerCount),
      scoreStep: read('scoreStep', defaults.scoreStep)
          .clamp(minScoreStep, maxScoreStep),
      winningScore: read('winningScore', defaults.winningScore)
          .clamp(minWinningScore, maxWinningScore),
    );
  }
}
