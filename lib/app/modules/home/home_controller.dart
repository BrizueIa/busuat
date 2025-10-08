import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class HomeController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxInt currentIndex = 1.obs; // Inicia en 1 (Mapa - centro)
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authRepository.getCurrentUser();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed('/login');
  }
}
