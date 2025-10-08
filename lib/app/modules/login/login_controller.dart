import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> loginAsGuest() async {
    await _authRepository.loginAsGuest();
    Get.offAllNamed('/guest');
  }

  void goToAuthOptions() {
    Get.toNamed('/auth-options');
  }
}
