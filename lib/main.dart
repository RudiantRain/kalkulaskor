// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'shared/controllers/theme_controller.dart';
import 'shared/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // 🆕 wajib sebelum GetStorage() dipakai di mana pun
  Get.put(
    ThemeController(),
    permanent: true,
  ); // 🆕 daftar sebelum runApp -> tema awal langsung benar, tidak flicker
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KalkulaSkor',
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.pages,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Startup mode only, and read once on purpose - this must never rebuild.
      // Runtime switching is done by the views applying
      // ThemeController.currentTheme through a Theme widget; see
      // ThemeController.toggleTheme for why nothing here may be reactive.
      themeMode: themeController.themeMode,
    );
  }
}
