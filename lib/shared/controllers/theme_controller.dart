// lib/shared/controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../theme/app_theme.dart';

class ThemeController extends GetxController {
  static const _storageKey = 'isDarkMode';

  final _box = GetStorage();
  final isDarkMode = false.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// The ThemeData currently in effect. Widgets that sit outside the view's
  /// own `Theme` wrapper (dialogs, snackbars - they are separate routes) read
  /// this to stay in sync.
  ThemeData get currentTheme => isDarkMode.value ? AppTheme.dark : AppTheme.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read<bool>(_storageKey) ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write(_storageKey, isDarkMode.value);

    // Deliberately NOT Get.changeThemeMode() / Get.changeTheme().
    //
    // Both call GetMaterialController.update(), and GetMaterialApp is built
    // inside a GetBuilder<GetMaterialController> - so they rebuild the whole
    // app, Navigator and Overlay included. That rebuild breaks GetX's own
    // navigation bookkeeping: Get.back() stops closing the open dialog, and
    // SnackbarController fails its overlay lookup and then throws
    // LateInitializationError on its late _controller field.
    //
    // Nothing here needs that. Views apply `currentTheme` through a plain
    // Theme widget, so flipping isDarkMode is the entire theme switch.
  }
}
