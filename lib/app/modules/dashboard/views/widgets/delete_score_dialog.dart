import 'package:flutter/material.dart';

import '../../controllers/dashboard_controller.dart';

class DeleteScoreDialog extends StatelessWidget {
  const DeleteScoreDialog({
    super.key,
    required this.controller,
    required this.roundIndex,
  });

  final DashboardController controller;
  final int roundIndex;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text('Hapus skor babak ke-${roundIndex + 1}?'),
      content: const Text('Silahkan input ulang skor babak ini.'),
      actions: [
        TextButton(
          onPressed: controller.closeDialog,
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => controller.deleteScoreRound(roundIndex),
          child: const Text('Ya'),
        ),
      ],
    );
  }
}
