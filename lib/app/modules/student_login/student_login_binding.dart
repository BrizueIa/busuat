import 'package:get/get.dart';
import 'student_login_controller.dart';

class StudentLoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentLoginController>(() => StudentLoginController());
  }
}
