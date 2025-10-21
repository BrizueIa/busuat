import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final GetStorage _storage = GetStorage();
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _userKey = 'current_user';
  static const String _usersKey = 'users';

  // Guardar usuario actual
  Future<void> saveCurrentUser(UserModel user) async {
    await _storage.write(_userKey, user.toJson());
  }

  // Obtener usuario actual
  UserModel? getCurrentUser() {
    final userData = _storage.read(_userKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  // Registrar nuevo estudiante (con Supabase - SIN FALLBACK)
  Future<Map<String, dynamic>> registerStudent(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      print('📤 Iniciando registro en Supabase...');
      print('Email: $email');
      print('Nombre: $name');

      // Llamar a la edge function de Supabase
      final response = await _supabase.functions.invoke(
        'register-user',
        body: {'email': email, 'password': password, 'name': name},
        method: HttpMethod.post,
      );

      print('📥 Respuesta de Supabase: ${response.data}');
      print('📊 Status Code: ${response.status}');

      // Error 405 - Método no permitido (puede ser problema de CORS)
      if (response.status == 405) {
        print('❌ Error 405: Método no permitido');
        print('⚠️ Posibles causas:');
        print('   1. La edge function no maneja el método POST correctamente');
        print('   2. Falta configuración CORS en la función');
        print('   3. La función no está desplegada correctamente');
        return {
          'success': false,
          'error': 'METHOD_NOT_ALLOWED',
          'message':
              'Error 405: La función existe pero no acepta la petición.\n\n'
              'Posibles causas:\n'
              '• Configuración CORS incorrecta\n'
              '• Método HTTP no soportado\n'
              '• Función no desplegada correctamente\n\n'
              'Revisa los logs en Supabase Dashboard.',
        };
      }

      // Error 404 - Endpoint no encontrado
      if (response.status == 404) {
        print('❌ Error 404: Endpoint no encontrado');
        return {
          'success': false,
          'error': 'ENDPOINT_NOT_FOUND',
          'message': 'El servicio de registro no está disponible.',
        };
      }

      // Verificar si la respuesta fue exitosa
      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Tu función devuelve "message" y "user", no "success" y "data"
        if (data['user'] != null) {
          print('✅ Usuario registrado exitosamente en Supabase');

          // Extraer datos del usuario
          final userData = data['user'] as Map<String, dynamic>;
          final userObj = userData['user'] as Map<String, dynamic>?;
          final userId =
              userObj?['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString();

          // Guardar también en local storage como respaldo
          List users = _storage.read(_usersKey) ?? [];
          final newUser = {
            'id': userId,
            'email': email,
            'password': password,
            'name': name,
            'userType': 'student',
          };
          users.add(newUser);
          await _storage.write(_usersKey, users);

          // Guardar como usuario actual
          final userModel = UserModel(
            id: userId,
            email: email,
            name: name,
            userType: 'student',
          );
          await saveCurrentUser(userModel);

          return {'success': true, 'userId': userId};
        } else {
          final errorMsg =
              data['error']?.toString() ?? 'Respuesta inválida del servidor';
          print('❌ Error en la respuesta de Supabase: $errorMsg');
          return {
            'success': false,
            'error': 'SERVER_ERROR',
            'message': errorMsg,
          };
        }
      } else {
        print('❌ Error en la petición. Status: ${response.status}');
        return {
          'success': false,
          'error': 'HTTP_ERROR',
          'message':
              'Error en la conexión con el servidor (Status: ${response.status})',
        };
      }
    } catch (e) {
      print('❌ Error al registrar en Supabase: $e');

      // Detectar tipo de error
      String errorType = 'UNKNOWN_ERROR';
      String errorMessage = 'Error de conexión con el servidor';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        errorType = 'NETWORK_ERROR';
        errorMessage =
            'No se pudo conectar al servidor. Verifica tu conexión a internet.';
      } else if (e.toString().contains('TimeoutException')) {
        errorType = 'TIMEOUT_ERROR';
        errorMessage = 'La conexión tardó demasiado. Intenta nuevamente.';
      } else if (e.toString().contains('FunctionsException')) {
        errorType = 'FUNCTION_ERROR';
        errorMessage =
            'Error en el servicio de registro. Verifica que la edge function esté desplegada.';
      }

      return {
        'success': false,
        'error': errorType,
        'message': errorMessage,
        'details': e.toString(),
      };
    }
  }

  // Login de estudiante (con Supabase Auth)
  Future<Map<String, dynamic>> loginStudent(
    String email,
    String password,
  ) async {
    try {
      print('📤 Iniciando login en Supabase Auth...');
      print('Email: $email');

      // Intentar login con Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('📥 Respuesta de Supabase Auth');
      print('Usuario: ${response.user?.email}');
      print('Session: ${response.session != null ? "Activa" : "No activa"}');

      if (response.user != null) {
        print('✅ Login exitoso en Supabase Auth');

        // Extraer datos del usuario
        final userId = response.user!.id;
        final userName = response.user!.userMetadata?['name'] as String?;

        // Guardar sesión localmente
        final userModel = UserModel(
          id: userId,
          email: email,
          name: userName,
          userType: 'student',
        );
        await saveCurrentUser(userModel);

        // También guardar en lista local para compatibilidad
        List users = _storage.read(_usersKey) ?? [];
        final existingUserIndex = users.indexWhere((u) => u['email'] == email);

        if (existingUserIndex == -1) {
          users.add({
            'id': userId,
            'email': email,
            'password': password,
            'name': userName,
            'userType': 'student',
          });
          await _storage.write(_usersKey, users);
        }

        return {'success': true, 'userId': userId, 'name': userName};
      } else {
        print('❌ Login falló: No se recibió usuario');
        return {
          'success': false,
          'error': 'INVALID_CREDENTIALS',
          'message': 'Credenciales inválidas',
        };
      }
    } catch (e) {
      print('❌ Error en login: $e');

      // Detectar tipo de error
      String errorType = 'UNKNOWN_ERROR';
      String errorMessage = 'Error al iniciar sesión';

      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('Invalid email or password')) {
        errorType = 'INVALID_CREDENTIALS';
        errorMessage = 'Email o contraseña incorrectos';
      } else if (e.toString().contains('Email not confirmed')) {
        errorType = 'EMAIL_NOT_CONFIRMED';
        errorMessage = 'Por favor confirma tu correo electrónico';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        errorType = 'NETWORK_ERROR';
        errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión.';
      }

      return {
        'success': false,
        'error': errorType,
        'message': errorMessage,
        'details': e.toString(),
      };
    }
  }

  // Login como invitado
  Future<void> loginAsGuest() async {
    final guestUser = UserModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      userType: 'guest',
    );
    await saveCurrentUser(guestUser);
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _storage.remove(_userKey);
  }

  // Verificar si hay sesión activa
  bool hasActiveSession() {
    return _storage.hasData(_userKey);
  }
}
