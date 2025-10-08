import 'package:get/get.dart';
import 'auth_options_controller.dart';

class AuthOptionsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthOptionsController>(() => AuthOptionsController());
  }
}
