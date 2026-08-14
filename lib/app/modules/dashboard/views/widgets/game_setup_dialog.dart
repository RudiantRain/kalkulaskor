import 'package:flutter/material.dart';

import '../../../../data/models/game_settings.dart';
import '../../controllers/dashboard_controller.dart';

/// Form that starts a new game: how many players, the score multiple, and the
/// total that wins.
///
/// Stateful, unlike the other dialogs, because the form owns editing state that
/// must be discardable - the controller's own fields are never touched until
/// "Mulai" passes validation.
class GameSetupDialog extends StatefulWidget {
  const GameSetupDialog({
    super.key,
    required this.controller,
    required this.initialSettings,
    required this.cancellable,
  });

  final DashboardController controller;
  final GameSettings initialSettings;

  /// When false there is no game to fall back on, so the form cannot be
  /// dismissed - not by a button, the barrier, or the Android back gesture.
  final bool cancellable;

  @override
  State<GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<GameSetupDialog> {
  final _formKey = GlobalKey<FormState>();

  late int _playerCount = widget.initialSettings.playerCount;
  late final _scoreStepController = TextEditingController(
    text: '${widget.initialSettings.scoreStep}',
  );
  late final _winningScoreController = TextEditingController(
    text: '${widget.initialSettings.winningScore}',
  );

  @override
  void dispose() {
    _scoreStepController.dispose();
    _winningScoreController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.controller.startNewGame(
      GameSettings(
        playerCount: _playerCount,
        // Validated above, so these parse cleanly.
        scoreStep: int.parse(_scoreStepController.text.trim()),
        winningScore: int.parse(_winningScoreController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.cancellable,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Pengaturan Pencatatan Skor'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mulai mencatat skor setelah pengaturan selesai',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),

              const Text('Kolom Catatan Skor'),
              const SizedBox(height: 6),
              SegmentedButton<int>(
                segments: [
                  for (
                    var count = GameSettings.minPlayerCount;
                    count <= GameSettings.maxPlayerCount;
                    count++
                  )
                    ButtonSegment(value: count, label: Text('$count')),
                ],
                selected: {_playerCount},
                onSelectionChanged: (selection) {
                  setState(() => _playerCount = selection.first);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _scoreStepController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kelipatan skor',
                  helperText:
                      'Skor harus kelipatan angka ini '
                      '(${GameSettings.minScoreStep}-'
                      '${GameSettings.maxScoreStep})',
                ),
                validator: GameSettings.validateScoreStep,
                // Re-validate the target too: it must not fall below the step.
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _winningScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Skor (Selesai)',
                  helperText:
                      'Pencatatan selesai saat skor ini tercapai '
                      '(${GameSettings.minWinningScore}-'
                      '${GameSettings.maxWinningScore})',
                ),
                validator: (input) => GameSettings.validateWinningScore(
                  input,
                  scoreStepInput: _scoreStepController.text,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (widget.cancellable)
            TextButton(
              onPressed: widget.controller.closeDialog,
              child: const Text('Batal'),
            ),
          TextButton(onPressed: _submit, child: const Text('Mulai')),
        ],
      ),
    );
  }
}
