import 'package:get/get.dart';

class AuthOptionsController extends GetxController {
  void goToLogin() {
    Get.toNamed('/student-login');
  }

  void goToRegister() {
    Get.toNamed('/register');
  }

  void goBack() {
    Get.back();
  }
}
