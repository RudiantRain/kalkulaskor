import 'package:flutter/material.dart';

import '../../controllers/dashboard_controller.dart';

class SavedGameDialog extends StatelessWidget {
  const SavedGameDialog({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Data Skor Ditemukan!'),
      content: const Text('Ingin melanjutkan skor dari permainan sebelumnya?'),
      actions: [
        TextButton(
          onPressed: controller.discardSavedGame,
          child: const Text('Mulai Ulang'),
        ),
        TextButton(
          onPressed: controller.resumeSavedGame,
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}
