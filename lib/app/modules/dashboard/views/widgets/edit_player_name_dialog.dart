import 'package:flutter/material.dart';

import '../../controllers/dashboard_controller.dart';

class EditPlayerNameDialog extends StatelessWidget {
  const EditPlayerNameDialog({
    super.key,
    required this.controller,
    required this.playerIndex,
  });

  final DashboardController controller;
  final int playerIndex;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Ubah nama pemain?'),
      content: TextFormField(
        controller: controller.editNameController,
        maxLength: 6,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: controller.closeDialog,
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => controller.savePlayerName(playerIndex),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
