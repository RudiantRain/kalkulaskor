import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../shared/controllers/theme_controller.dart';
import '../../../data/models/game_settings.dart';
import '../views/widgets/about_app_dialog.dart';
import '../views/widgets/add_score_dialog.dart';
import '../views/widgets/delete_score_dialog.dart';
import '../views/widgets/edit_player_name_dialog.dart';
import '../views/widgets/game_result_dialog.dart';
import '../views/widgets/game_setup_dialog.dart';
import '../views/widgets/saved_game_dialog.dart';

class DashboardController extends GetxController {
  static const _playerNamesStorageKey = 'dashboard_player_names';
  static const _playerScoresStorageKey = 'dashboard_player_scores';
  static const _settingsStorageKey = 'dashboard_game_settings';

  final _storage = GetStorage();
  final showcase = ShowcaseView.register();

  ThemeController get _themeController => Get.find<ThemeController>();

  /// The rules of the game in progress. Reactive so the indicator chips and
  /// the score grid follow a change immediately.
  final settings = GameSettings.defaults.obs;

  int get playerCount => settings.value.playerCount;
  int get scoreStep => settings.value.scoreStep;
  int get winningScore => settings.value.winningScore;

  final playerNames = _defaultPlayerNames(
    GameSettings.defaults.playerCount,
  ).obs;

  final scores = <List<int>>[
    List.filled(GameSettings.defaults.playerCount, 0),
  ].obs;

  final scoreInputIsInvalid = false.obs;

  final editNameController = TextEditingController();

  /// One field per player, so this list is rebuilt whenever playerCount
  /// changes. Not final for that reason - see [_rebuildScoreEntryControllers].
  var scoreEntryControllers = List.generate(
    GameSettings.defaults.playerCount,
    (_) => TextEditingController(),
  );

  static List<String> _defaultPlayerNames(int count) => List.generate(
    count,
    (i) => '${String.fromCharCode(65 + i)}(edit)',
  );

  final playerNamesShowcaseKey = GlobalKey();
  final addScoreShowcaseKey = GlobalKey();
  final undoScoreShowcaseKey = GlobalKey();

  // Deliberately onReady, not onInit: this controller is registered with
  // Get.lazyPut, so onInit runs while DashboardView.build() is still
  // resolving `controller`. Showing a dialog there reaches Flutter's
  // element tree mid-build and throws "visitChildElements() called
  // during build". onReady fires one frame later, once the tree settled.
  @override
  void onReady() {
    super.onReady();

    // A game already on record is resumed, never reconfigured - the setup form
    // must not appear and interrupt a match in progress.
    if (_hasSavedGame) {
      _openDialog(SavedGameDialog(controller: this));
    } else {
      openGameSetupDialog(cancellable: false);
    }
  }

  @override
  void onClose() {
    showcase.unregister();
    editNameController.dispose();
    for (final controller in scoreEntryControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  void startTour() {
    showcase.startShowCase([
      playerNamesShowcaseKey,
      addScoreShowcaseKey,
      undoScoreShowcaseKey,
    ]);
  }

  // ---------------------------------------------------------------------------
  // Dialog plumbing
  //
  // Two taps on the same dialog button can be dispatched inside a single
  // frame, before the route has finished popping. So an action body must run
  // at most once per opened dialog, while Get.back() must still ALWAYS run -
  // a dialog left open after a committed score is what allows a double entry.
  //
  // The claim flag is plain controller state on purpose: it cannot be
  // invalidated by a widget rebuild the way GetX's own routing flags can.
  // ---------------------------------------------------------------------------

  bool _dialogActionClaimed = false;

  /// Opens [dialog] and re-arms the one-action-per-dialog guard.
  void _openDialog(Widget dialog, {bool barrierDismissible = true}) {
    _dialogActionClaimed = false;

    // A dialog is its own route, so it sits outside the Theme that
    // DashboardView installs and has to be given the current theme here.
    Get.dialog(
      Theme(data: _themeController.currentTheme, child: dialog),
      barrierDismissible: barrierDismissible,
    );
  }

  /// True for the first action after a dialog opened, false for any repeat.
  bool _claimDialogAction() {
    if (_dialogActionClaimed) return false;
    _dialogActionClaimed = true;
    return true;
  }

  /// Backs the plain "Batal" / "Tutup" buttons.
  void closeDialog() {
    if (!_claimDialogAction()) return;
    Get.back();
  }

  void openAboutDialog() => _openDialog(AboutAppDialog(controller: this));

  bool get _hasSavedGame => _storage.read(_playerNamesStorageKey) != null;

  /// Shows the form that starts a new game.
  ///
  /// [cancellable] is false wherever there is no game left to fall back on
  /// (first launch, after a winner, after discarding a saved game) - there the
  /// form is also barrier- and back-proof. It is true only for the pop-up menu,
  /// where cancelling means "never mind, keep playing".
  void openGameSetupDialog({required bool cancellable}) {
    _openDialog(
      GameSetupDialog(
        controller: this,
        initialSettings: settings.value,
        cancellable: cancellable,
      ),
      barrierDismissible: cancellable,
    );
  }

  /// Applies [newSettings] and clears the board for a fresh game.
  void startNewGame(GameSettings newSettings) {
    if (!_claimDialogAction()) return;
    Get.back();

    _applySettings(newSettings);
    playerNames.assignAll(_namesResizedTo(newSettings.playerCount));
    scores.assignAll([List.filled(newSettings.playerCount, 0)]);
    _persistGame();
  }

  void _applySettings(GameSettings newSettings) {
    settings.value = newSettings;
    _rebuildScoreEntryControllers(newSettings.playerCount);
  }

  /// One entry field per player. The old controllers are disposed here; leaving
  /// them behind on every player-count change would leak them.
  void _rebuildScoreEntryControllers(int count) {
    if (scoreEntryControllers.length == count) return;

    for (final entry in scoreEntryControllers) {
      entry.dispose();
    }
    scoreEntryControllers = List.generate(count, (_) => TextEditingController());
  }

  /// Keeps the names already entered, trimming or padding to [count]. Groups
  /// tend to be the same people game after game.
  List<String> _namesResizedTo(int count) {
    final defaults = _defaultPlayerNames(count);
    return List.generate(
      count,
      (i) => i < playerNames.length ? playerNames[i] : defaults[i],
    );
  }

  void resumeSavedGame() {
    final savedNames = List<String>.from(
      _storage.read(_playerNamesStorageKey) as List,
    );
    final savedScores = (_storage.read(_playerScoresStorageKey) as List)
        .map((round) => List<int>.from(round as List))
        .toList();
    final savedSettings = _readSavedSettings(fallbackPlayerCount: savedNames.length);

    if (!_claimDialogAction()) return;
    Get.back();

    // Settings first: every row in `scores` is playerCount wide, so restoring
    // the board before its rules would leave the grid and the entry form
    // disagreeing about how many players there are.
    _applySettings(savedSettings);
    playerNames.assignAll(savedNames);
    scores.assignAll(savedScores);
  }

  /// Reads the stored rules. Games recorded before settings existed have no
  /// entry, so the player count is inferred from the saved names instead.
  GameSettings _readSavedSettings({required int fallbackPlayerCount}) {
    final stored = _storage.read(_settingsStorageKey);
    if (stored is Map) return GameSettings.fromJson(stored);

    return GameSettings.defaults.copyWith(
      playerCount: fallbackPlayerCount.clamp(
        GameSettings.minPlayerCount,
        GameSettings.maxPlayerCount,
      ),
    );
  }

  void discardSavedGame() {
    if (!_claimDialogAction()) return;
    Get.back();

    // Take the previous names and rules into memory before the record goes:
    // restarting is normally the same group playing the same variant, so those
    // are the values the setup form should open with.
    _adoptSavedNamesAndSettings();

    resetGame();
    _openSetupDialogNextFrame();
  }

  /// Loads only the names and rules of the stored game, not its scores.
  void _adoptSavedNamesAndSettings() {
    final storedNames = _storage.read(_playerNamesStorageKey);
    if (storedNames is! List) return;

    final savedNames = List<String>.from(storedNames);
    _applySettings(_readSavedSettings(fallbackPlayerCount: savedNames.length));
    playerNames.assignAll(savedNames);
  }

  /// Backs the "OK. Mulai Ulang!" button on the win/lose dialog.
  void acknowledgeGameResult() {
    if (!_claimDialogAction()) return;
    Get.back();
    resetGame();
    _openSetupDialogNextFrame();
  }

  /// Chaining one dialog straight after closing another reaches for GetX's
  /// overlay while it is still tearing down ("No Overlay widget found"). The
  /// next frame is safe.
  void _openSetupDialogNextFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openGameSetupDialog(cancellable: false);
    });
  }

  Future<void> _persistGame() async {
    await _storage.write(_playerNamesStorageKey, playerNames.toList());
    await _storage.write(
      _playerScoresStorageKey,
      scores.map((round) => round.toList()).toList(),
    );
    await _storage.write(_settingsStorageKey, settings.value.toJson());
  }

  Future<void> _clearSavedGame() async {
    await _storage.remove(_playerNamesStorageKey);
    await _storage.remove(_playerScoresStorageKey);
    await _storage.remove(_settingsStorageKey);
  }

  void openEditPlayerNameDialog(int index) {
    editNameController.clear();
    _openDialog(EditPlayerNameDialog(controller: this, playerIndex: index));
  }

  void savePlayerName(int index) {
    final newName = editNameController.text.trim();
    if (!_claimDialogAction()) return;
    Get.back();

    if (newName.isNotEmpty) {
      playerNames[index] = newName;
      _persistGame();
    }
  }

  void openAddScoreDialog() {
    for (final controller in scoreEntryControllers) {
      controller.clear();
    }
    scoreInputIsInvalid.value = false;
    _openDialog(AddScoreDialog(controller: this));
  }

  void submitScoreEntry() {
    // Validate and compute everything BEFORE touching any state, so a bad
    // entry leaves the dialog exactly as the player left it.
    final roundInput = <int>[];
    for (final entry in scoreEntryControllers) {
      final text = entry.text.trim();

      // tryParse, never parse: keyboardType.number still lets '-', '.', ','
      // and pasted text through. A FormatException thrown here would abort
      // the method before Get.back() and leave the dialog stuck open.
      final value = text.isEmpty ? 0 : int.tryParse(text);
      if (value == null || value % scoreStep != 0) {
        scoreInputIsInvalid.value = true;
        return;
      }
      roundInput.add(value);
    }

    final previousTotals = scores.last;
    final newTotals = List.generate(
      roundInput.length,
      (i) => previousTotals[i] + roundInput[i],
    );

    scoreInputIsInvalid.value = false;

    // Claim, close, then commit. Only the first tap gets past the claim, and
    // its Get.back() is unconditional - so a committed score always has a
    // closed dialog to go with it, and nothing between the two can throw.
    if (!_claimDialogAction()) return;
    Get.back();

    scores.add(newTotals);
    _persistGame();

    // The dialog's route is popped but the overlay it lived in has not
    // finished rebuilding this frame, so opening a dialog/snackbar right
    // here throws "No Overlay widget found". Next frame is safe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceRoundOutcome(newTotals);
    });
  }

  void _announceRoundOutcome(List<int> totals) {
    final highestScore = totals.reduce(max);
    final lowestScore = totals.reduce(min);
    final leadingIndex = totals.indexOf(highestScore);
    final trailingIndex = totals.indexOf(lowestScore);

    // _openDialog, not Get.dialog: this runs right after submitScoreEntry has
    // already claimed its action, so the guard has to be re-armed or the
    // result dialog's own button would find it spent and never close.
    if (highestScore >= winningScore) {
      _openDialog(
        GameResultDialog(
          controller: this,
          isWinner: true,
          playerIndex: leadingIndex,
          score: highestScore,
        ),
        barrierDismissible: false,
      );
      return;
    }

    if (lowestScore <= -winningScore) {
      _openDialog(
        GameResultDialog(
          controller: this,
          isWinner: false,
          playerIndex: trailingIndex,
          score: lowestScore,
        ),
        barrierDismissible: false,
      );
      return;
    }

    final leadingPlayer = playerNames[leadingIndex];

    _showMessage(
      'Selamat!',
      '$leadingPlayer sedang unggul!',
      icon: Icons.keyboard_double_arrow_up_rounded,
    );
  }

  /// Shows a transient message through Flutter's own ScaffoldMessenger.
  ///
  /// Deliberately NOT Get.snackbar. Get.back() refuses to pop a route while
  /// GetX believes one of its snackbars is open - it closes the snackbar and
  /// returns instead of popping (extension_navigation.dart:821-824). If a GetX
  /// snackbar ever fails to build its overlay, that flag stays set and its
  /// SnackbarController is left with an uninitialised `late _controller`, so
  /// from then on EVERY Get.back() throws LateInitializationError and no
  /// dialog can be closed again. ScaffoldMessenger never touches that flag.
  void _showMessage(
    String title,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = Get.context;
    if (context == null) return;

    final theme = _themeController.currentTheme;
    final textColor = theme.textTheme.bodyLarge?.color;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: theme.cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: theme.indicatorColor),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(message, style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  void confirmDeleteLastScore() {
    if (scores.length == 1) {
      _showMessage(
        'Mohon maaf',
        'Tidak ada baris nilai yang bisa dikoreksi',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    _openDialog(
      DeleteScoreDialog(controller: this, roundIndex: scores.length - 1),
    );
  }

  void deleteScoreRound(int roundIndex) {
    // Guarded for the same reason as submitScoreEntry, mirrored: without it
    // a double tap on "Ya" would remove two rounds instead of one.
    if (!_claimDialogAction()) return;
    Get.back();

    scores.removeAt(roundIndex);
    _persistGame();
  }

  void resetGame() {
    scores.assignAll([List.filled(playerCount, 0)]);
    _clearSavedGame();
  }
}
