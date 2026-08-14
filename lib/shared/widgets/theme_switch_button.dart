import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    return Obx(() => IconButton(
          onPressed: controller.toggleTheme,
          icon: Icon(controller.isDarkMode.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
        ));
  }
}