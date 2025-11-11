import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationService {
  final _supabase = Supabase.instance.client;

  /// Verifica si un usuario está verificado en la tabla verified_users
  Future<bool> isUserVerified(String userId) async {
    try {
      print('🔍 Verificando usuario: $userId');

      final response = await _supabase
          .from('verified_users')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      print('📋 Respuesta de verified_users: $response');

      final isVerified = response != null;
      print('✅ Usuario verificado: $isVerified');

      return isVerified;
    } catch (e) {
      print('❌ Error al verificar usuario: $e');
      return false;
    }
  }

  /// Obtiene la información de verificación de un usuario
  Future<Map<String, dynamic>?> getVerificationInfo(String userId) async {
    try {
      final response = await _supabase
          .from('verified_users')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error al obtener info de verificación: $e');
      return null;
    }
  }
}
