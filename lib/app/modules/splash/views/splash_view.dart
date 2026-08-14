// lib/app/modules/splash/views/splash_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.2),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    Get.isDarkMode
                        ? 'assets/kalkulatoremiwhite.png'
                        : 'assets/kalkulatoremiblack.png',
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.05),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: CircularProgressIndicator(
                  color: Get.theme.indicatorColor,
                ),
              ),
            ),
            Spacer(),
            Container(
              margin: const EdgeInsets.all(20),
              height: Get.height * 0.25,
              padding: const EdgeInsets.all(20),
              width: Get.width,
              decoration: BoxDecoration(
                color: Get.theme.canvasColor,
                borderRadius: BorderRadius.circular(20),
                // Yellow color
              ),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'KalkulaSkor',
                    style: TextStyle(
                      fontSize: 38,
                      fontFamily: 'Roboto',
                      color: Get.theme.scaffoldBackgroundColor,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          blurRadius: 1, // Softness of the shadow
                          color: Get.theme.indicatorColor, // Shadow color
                          offset: Offset(1.0, 1.0), // X and Y displacement
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Aplikasi yang dibuat untuk perhitungan skor segala jenis permainan secara konsekutif dan otomatis',
                    style: TextStyle(
                      color: Get.theme.scaffoldBackgroundColor,
                      fontFamily: 'Roboto',
                      fontSize: 17,
                      shadows: [
                        Shadow(
                          blurRadius: 1, // Softness of the shadow
                          color: Get.theme.indicatorColor, // Shadow color
                          offset: Offset(1.0, 1.0), // X and Y displacement
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.offNamed(Routes.dashboard),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Mulai Sekarang",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Get.theme.canvasColor,
                          fontWeight: FontWeight.normal,
                          shadows: [
                            Shadow(
                              blurRadius: 1, // Softness of the shadow
                              color: Get.theme.indicatorColor, // Shadow color
                              offset: Offset(1.0, 1.0), // X and Y displacement
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.05),
          ],
        ),
      ),
    );
  }
}
