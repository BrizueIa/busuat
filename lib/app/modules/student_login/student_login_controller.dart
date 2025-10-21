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

    final result = await _authRepository.loginStudent(email, password);

    isLoading.value = false;

    if (result['success'] == true) {
      final userName = result['name'] ?? 'Usuario';
      Get.snackbar(
        'Bienvenido',
        '¡Hola $userName!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      Get.offAllNamed('/home');
    } else {
      final errorType = result['error'] ?? 'UNKNOWN_ERROR';
      final errorMessage = result['message'] ?? 'Error al iniciar sesión';

      String title = 'Error de Inicio de Sesión';
      String message = errorMessage;

      if (errorType == 'INVALID_CREDENTIALS') {
        title = '❌ Credenciales Inválidas';
        message =
            'Email o contraseña incorrectos.\n\nVerifica tus datos e intenta nuevamente.';
      } else if (errorType == 'NETWORK_ERROR') {
        title = '🌐 Sin Conexión';
        message =
            'No se pudo conectar al servidor.\n\nVerifica tu conexión a internet.';
      }

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      print('❌ Error de login: $errorType');
      print('❌ Mensaje: $errorMessage');
      if (result['details'] != null) {
        print('❌ Detalles: ${result['details']}');
      }
    }
  }

  void goToRegister() {
    Get.toNamed('/register');
  }

  void goBack() {
    Get.back();
  }
}
