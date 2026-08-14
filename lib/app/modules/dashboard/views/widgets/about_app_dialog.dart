import 'package:flutter/material.dart';

import '../../controllers/dashboard_controller.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Tentang KalkulaSkor'),
      content: const Text(
        'Aplikasi yang dibuat untuk perhitungan skor segala jenis permainan '
        'secara konsekutif dan otomatis.\n\nAplikasi ini dibuat oleh GPR E8/11 '
        'untuk mendukung kegiatan remian bapak-bapak GPR RT 02',
      ),
      actions: [
        TextButton(
          onPressed: controller.closeDialog,
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
