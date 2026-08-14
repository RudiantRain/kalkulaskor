import 'dart:async';
import 'package:get/get.dart';
// import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final progressValue = 0.1.obs; // gaya .obs, setara Rx<double>(0.1)
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Future.delayed(const Duration(seconds: 2), () => Get.offNamed(Routes.dashboard));
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (progressValue.value < 1.0) {
        progressValue.value += 0.1;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel(); // 🆕 fix kebocoran yang ada di referensi
    super.onClose();
  }
}