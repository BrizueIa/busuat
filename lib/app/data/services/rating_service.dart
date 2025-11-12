import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_rating_model.dart';

class RatingService {
  final _supabase = Supabase.instance.client;

  /// Obtiene el rating promedio de un post usando la edge function
  Future<double> getPostAverageRating(int postId) async {
    try {
      print('🔍 Obteniendo rating promedio para post: $postId');

      final response = await _supabase.rpc(
        'get_post_average_rating',
        params: {'given_post_id': postId},
      );

      print('📊 Rating promedio obtenido: $response');

      if (response == null) return 0.0;

      return (response as num).toDouble();
    } catch (e) {
      print('❌ Error al obtener rating promedio: $e');
      return 0.0;
    }
  }

  /// Obtiene todos los ratings de un post
  Future<List<PostRatingModel>> getPostRatings(int postId) async {
    try {
      final response = await _supabase
          .from('posts_ratings')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PostRatingModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error al obtener ratings: $e');
      return [];
    }
  }

  /// Crea o actualiza el rating de un usuario para un post
  Future<bool> ratePost({
    required int postId,
    required int rating,
    String? body,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return false;
      }

      final data = {
        'post_id': postId,
        'rating': rating,
        if (body != null && body.isNotEmpty) 'body': body,
      };

      // Simplemente insertar el rating (sin verificar duplicados)
      await _supabase.from('posts_ratings').insert(data);

      print('✅ Rating guardado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al guardar rating: $e');
      return false;
    }
  }

  /// Obtiene el conteo de ratings por estrellas
  Future<Map<int, int>> getRatingDistribution(int postId) async {
    try {
      final response = await _supabase
          .from('posts_ratings')
          .select('rating')
          .eq('post_id', postId);

      final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var item in response as List) {
        final rating = item['rating'] as int;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      print('❌ Error al obtener distribución de ratings: $e');
      return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    }
  }
}
