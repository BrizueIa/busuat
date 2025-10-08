import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
// TODO: Descomentar cuando Supabase esté configurado
// import '../../data/services/api_service.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  // TODO: Descomentar cuando Supabase esté configurado
  // final ApiService _apiService = ApiService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validación de campos vacíos
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Validación de email válido
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

    // Validación de email institucional UAT
    if (!email.contains('.uat.edu.mx')) {
      Get.snackbar(
        'Error',
        'Debes usar un correo institucional (@uat.edu.mx)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Validación de longitud de contraseña
    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'La contraseña debe tener al menos 6 caracteres',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Validación de coincidencia de contraseñas
    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Las contraseñas no coinciden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // TODO: TEMPORALMENTE DESACTIVADO - Activar cuando Supabase esté configurado
      // 1. Registrar en la API de Supabase
      /* 
      final apiResponse = await _apiService.registerUser(
        email: email,
        name: name,
        password: password,
      );

      if (apiResponse == null) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'No se pudo conectar con el servidor. Intenta nuevamente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return;
      }
      */

      print('📝 Registro local - Email: $email, Nombre: $name');

      // 2. Guardar localmente para mantener el sistema de permisos
      final localSuccess = await _authRepository.registerStudent(
        email,
        password,
        name: name,
      );

      isLoading.value = false;

      if (localSuccess) {
        Get.snackbar(
          'Éxito',
          'Registro completado exitosamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Error',
          'El correo ya está registrado localmente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  void goToLogin() {
    Get.back();
  }

  void goToStudentLogin() {
    Get.offNamed('/student-login');
  }
}
