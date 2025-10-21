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
    if (!email.toLowerCase().endsWith('.uat.edu.mx')) {
      Get.snackbar(
        'Error de Validación',
        'Debes usar un correo institucional válido de la UAT que termine en .uat.edu.mx\n\nEjemplo: tu.nombre@uat.edu.mx',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    // Validación adicional: verificar formato correcto
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+\.uat\.edu\.mx$');
    final emailParts = email.split('@');
    if (emailParts.length != 2 || !emailRegex.hasMatch(emailParts[1])) {
      Get.snackbar(
        'Error de Formato',
        'El formato del correo no es válido. Debe ser: usuario@subdominio.uat.edu.mx',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
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
      print('📝 Iniciando registro - Email: $email, Nombre: $name');

      // Registrar en Supabase
      final result = await _authRepository.registerStudent(
        email,
        password,
        name: name,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        Get.snackbar(
          'Éxito',
          'Registro completado exitosamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.offAllNamed('/home');
      } else {
        // Manejar diferentes tipos de error
        final errorType = result['error'] ?? 'UNKNOWN_ERROR';
        final errorMessage = result['message'] ?? 'Error desconocido';

        String title = 'Error de Registro';
        String message = errorMessage;
        Duration duration = const Duration(seconds: 4);

        // Personalizar mensaje según el tipo de error
        if (errorType == 'FUNCTION_NOT_FOUND') {
          title = '⚠️ Servicio No Disponible';
          message =
              'La función de registro no está desplegada en Supabase.\n\n'
              'Por favor:\n'
              '1. Verifica que la edge function "register-user" esté desplegada\n'
              '2. Revisa los logs de Supabase\n'
              '3. Consulta QUICKSTART_SUPABASE.md para instrucciones';
          duration = const Duration(seconds: 8);
        } else if (errorType == 'NETWORK_ERROR') {
          title = '🌐 Error de Conexión';
          message =
              'No se pudo conectar al servidor.\n\nVerifica tu conexión a internet.';
          duration = const Duration(seconds: 5);
        } else if (errorType == 'FUNCTION_ERROR') {
          title = '⚙️ Error del Servidor';
          message =
              'La función de registro tiene un error.\n\n'
              'Verifica que la edge function esté correctamente desplegada.';
          duration = const Duration(seconds: 6);
        }

        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          duration: duration,
          margin: const EdgeInsets.all(16),
        );

        // Imprimir detalles técnicos en consola
        print('❌ Tipo de error: $errorType');
        print('❌ Mensaje: $errorMessage');
        if (result['details'] != null) {
          print('❌ Detalles técnicos: ${result['details']}');
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error Inesperado',
        'Ocurrió un error inesperado: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      print('❌ Error inesperado en RegisterController: $e');
    }
  }

  void goToLogin() {
    Get.back();
  }

  void goToStudentLogin() {
    Get.offNamed('/student-login');
  }
}
