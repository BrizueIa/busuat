import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';

class GuestController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed('/login');
  }
}
