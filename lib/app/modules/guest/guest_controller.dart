import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';

class GuestController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxInt currentIndex = 0.obs; // Inicia en 0 (Mapa)

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed('/login');
  }

  void goToVerifyAccount() {
    // Mostrar diálogo con opciones para verificar cuenta
    Get.dialog(
      AlertDialog(
        title: const Text('Verificar Cuenta'),
        content: const Text(
          '¿Ya tienes una cuenta de estudiante o deseas crear una nueva?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/student-login');
            },
            child: const Text('Iniciar Sesión'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Registrarse'),
          ),
        ],
      ),
    );
  }
}
