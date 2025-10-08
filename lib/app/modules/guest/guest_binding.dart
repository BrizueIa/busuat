import 'package:get/get.dart';
import 'guest_controller.dart';

class GuestBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuestController>(() => GuestController());
  }
}
