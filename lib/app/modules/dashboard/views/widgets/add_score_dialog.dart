import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';

class AddScoreDialog extends StatelessWidget {
  const AddScoreDialog({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final entryFields = controller.scoreEntryControllers;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Tambahkan Skor?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tuliskan skor semua pemain sekaligus, lalu simpan',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < entryFields.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == entryFields.length - 1 ? 0 : 8,
                    ),
                    child: TextFormField(
                      controller: entryFields[i],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text(controller.playerNames[i]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.scoreInputIsInvalid.value,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Mohon isi masing-masing skor dengan bilangan kelipatan '
                  '${controller.scoreStep}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: controller.closeDialog,
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: controller.submitScoreEntry,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
