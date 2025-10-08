import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';

class StudentLoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Por favor ingresa un correo válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final success = await _authRepository.loginStudent(email, password);

    isLoading.value = false;

    if (success) {
      Get.snackbar(
        'Éxito',
        'Bienvenido de nuevo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
      Get.offAllNamed('/home');
    } else {
      Get.snackbar(
        'Error',
        'Correo o contraseña incorrectos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  void goToRegister() {
    Get.toNamed('/register');
  }

  void goBack() {
    Get.back();
  }
}
