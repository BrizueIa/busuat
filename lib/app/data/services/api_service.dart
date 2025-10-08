import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Registra un usuario en la API de Supabase usando Supabase Functions
  ///
  /// Parámetros:
  /// - [email]: Correo electrónico del usuario
  /// - [name]: Nombre del usuario
  /// - [password]: Contraseña del usuario
  ///
  /// Retorna un Map con la respuesta del servidor o null si hay error
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      print('📤 Invocando función Supabase: register-user');
      print('📦 Datos: email=$email, name=$name');

      // Exactamente como el ejemplo de Supabase
      final res = await _supabase.functions.invoke(
        'register-user',
        body: {'email': email, 'name': name, 'password': password},
      );

      print('📥 Status: ${res.status}');
      print('📥 Data type: ${res.data.runtimeType}');
      print('📥 Data: ${res.data}');

      // Manejar diferentes tipos de respuesta
      final data = res.data;

      if (res.status == 200 || res.status == 201) {
        print('✅ Registro exitoso');

        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is String) {
          try {
            return jsonDecode(data) as Map<String, dynamic>;
          } catch (e) {
            print('⚠️ Respuesta no es JSON: $data');
            return {'success': true, 'message': data};
          }
        } else {
          return {'success': true, 'data': data};
        }
      } else {
        print('❌ Error: Status ${res.status}');
        print('❌ Data: $data');
        return null;
      }
    } on FunctionException catch (error) {
      print('');
      print('💥 ========== ERROR DE FUNCIÓN ==========');
      print('Status: ${error.status}');
      print('Reason: ${error.reasonPhrase}');
      print('Details: ${error.details}');
      print('=========================================');
      print('');

      // Mostrar el error completo
      print('🔍 Diagnóstico:');
      if (error.status == 404) {
        print('   ❌ La función "register-user" NO EXISTE o NO está desplegada');
        print('   💡 Verifica en Supabase Dashboard > Edge Functions');
      } else if (error.status == 500) {
        print('   ❌ Error interno en la función');
        print('   � Revisa los logs de la función en Supabase');
      } else {
        print('   ❌ Error desconocido: ${error.status}');
      }

      return null;
    } catch (error, stackTrace) {
      print('');
      print('💥 ========== EXCEPCIÓN ==========');
      print('Error: $error');
      print('Tipo: ${error.runtimeType}');
      print('Stack: $stackTrace');
      print('==================================');
      print('');

      return null;
    }
  }
}
