import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../shared/controllers/theme_controller.dart';
import '../views/widgets/about_app_dialog.dart';
import '../views/widgets/add_score_dialog.dart';
import '../views/widgets/delete_score_dialog.dart';
import '../views/widgets/edit_player_name_dialog.dart';
import '../views/widgets/game_result_dialog.dart';
import '../views/widgets/saved_game_dialog.dart';

class DashboardController extends GetxController {
  static const playerCount = 4;
  static const scoreStep = 5;
  static const winningScore = 500;

  static const _playerNamesStorageKey = 'dashboard_player_names';
  static const _playerScoresStorageKey = 'dashboard_player_scores';

  final _storage = GetStorage();
  final showcase = ShowcaseView.register();

  ThemeController get _themeController => Get.find<ThemeController>();

  final playerNames = List.generate(
    playerCount,
    (i) => '${String.fromCharCode(65 + i)}(edit)',
  ).obs;

  final scores = <List<int>>[List.filled(playerCount, 0)].obs;

  final scoreInputIsInvalid = false.obs;

  final editNameController = TextEditingController();
  final scoreEntryControllers = List.generate(
    playerCount,
    (_) => TextEditingController(),
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
    _promptResumeSavedGame();
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

  void _promptResumeSavedGame() {
    if (_storage.read(_playerNamesStorageKey) == null) return;
    _openDialog(SavedGameDialog(controller: this));
  }

  void resumeSavedGame() {
    final savedNames = List<String>.from(
      _storage.read(_playerNamesStorageKey) as List,
    );
    final savedScores = (_storage.read(_playerScoresStorageKey) as List)
        .map((round) => List<int>.from(round as List))
        .toList();
    if (!_claimDialogAction()) return;
    Get.back();

    playerNames.assignAll(savedNames);
    scores.assignAll(savedScores);
  }

  void discardSavedGame() {
    if (!_claimDialogAction()) return;
    Get.back();
    resetGame();
  }

  /// Backs the "OK. Mulai Ulang!" button on the win/lose dialog.
  void acknowledgeGameResult() {
    if (!_claimDialogAction()) return;
    Get.back();
    resetGame();
  }

  Future<void> _persistGame() async {
    await _storage.write(_playerNamesStorageKey, playerNames.toList());
    await _storage.write(
      _playerScoresStorageKey,
      scores.map((round) => round.toList()).toList(),
    );
  }

  Future<void> _clearSavedGame() async {
    await _storage.remove(_playerNamesStorageKey);
    await _storage.remove(_playerScoresStorageKey);
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
    final leadingPlayer = playerNames[totals.indexOf(highestScore)];
    final trailingPlayer = playerNames[totals.indexOf(lowestScore)];

    // _openDialog, not Get.dialog: this runs right after submitScoreEntry has
    // already claimed its action, so the guard has to be re-armed or the
    // result dialog's own button would find it spent and never close.
    if (highestScore >= winningScore) {
      _openDialog(
        GameResultDialog(
          controller: this,
          isWinner: true,
          playerName: leadingPlayer,
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
          playerName: trailingPlayer,
          score: lowestScore,
        ),
        barrierDismissible: false,
      );
      return;
    }

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
