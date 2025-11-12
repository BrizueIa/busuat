import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final _supabase = Supabase.instance.client;

  // Obtener todos los posts con sus ratings
  Future<List<PostModel>> getAllPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .order('id', ascending: false);

      final posts = (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();

      // Cargar ratings para cada post
      return await _loadRatingsForPosts(posts);
    } catch (e) {
      print('❌ Error al obtener posts: $e');
      rethrow;
    }
  }

  // Método privado para cargar ratings de múltiples posts
  Future<List<PostModel>> _loadRatingsForPosts(List<PostModel> posts) async {
    final updatedPosts = <PostModel>[];

    for (var post in posts) {
      if (post.id == null) {
        updatedPosts.add(post);
        continue;
      }

      try {
        // Obtener rating promedio usando la función RPC
        final avgRating = await _supabase.rpc(
          'get_post_average_rating',
          params: {'given_post_id': post.id!},
        );

        // Contar ratings
        final ratingsResponse = await _supabase
            .from('posts_ratings')
            .select('id')
            .eq('post_id', post.id!);

        final ratingsCount = (ratingsResponse as List).length;

        updatedPosts.add(
          post.copyWith(
            averageRating: (avgRating as num?)?.toDouble() ?? 0.0,
            ratingsCount: ratingsCount,
          ),
        );
      } catch (e) {
        print('⚠️ Error al cargar rating para post ${post.id}: $e');
        updatedPosts.add(post);
      }
    }

    return updatedPosts;
  }

  // Crear un nuevo post
  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await _supabase
          .from('posts')
          .insert(post.toJson())
          .select()
          .single();

      print('✅ Post creado exitosamente');
      return PostModel.fromJson(response);
    } catch (e) {
      print('❌ Error al crear post: $e');
      rethrow;
    }
  }

  // Obtener posts de un usuario específico con ratings
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);

      final posts = (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();

      return await _loadRatingsForPosts(posts);
    } catch (e) {
      print('❌ Error al obtener posts del usuario: $e');
      rethrow;
    }
  }

  // Eliminar un post
  Future<void> deletePost(int postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
      print('✅ Post eliminado exitosamente');
    } catch (e) {
      print('❌ Error al eliminar post: $e');
      rethrow;
    }
  }

  // Actualizar un post
  Future<PostModel> updatePost(int postId, PostModel post) async {
    try {
      final response = await _supabase
          .from('posts')
          .update(post.toJson())
          .eq('id', postId)
          .select()
          .single();

      print('✅ Post actualizado exitosamente');
      return PostModel.fromJson(response);
    } catch (e) {
      print('❌ Error al actualizar post: $e');
      rethrow;
    }
  }

  // Buscar posts por categoría con ratings
  Future<List<PostModel>> getPostsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .contains('categories', [category])
          .order('id', ascending: false);

      final posts = (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();

      return await _loadRatingsForPosts(posts);
    } catch (e) {
      print('❌ Error al buscar posts por categoría: $e');
      rethrow;
    }
  }
}
