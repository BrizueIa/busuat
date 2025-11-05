import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final _supabase = Supabase.instance.client;

  // Obtener todos los posts
  Future<List<PostModel>> getAllPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .order('id', ascending: false);

      return (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } catch (e) {
      print('❌ Error al obtener posts: $e');
      rethrow;
    }
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

  // Obtener posts de un usuario específico
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);

      return (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
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

  // Buscar posts por categoría
  Future<List<PostModel>> getPostsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .contains('categories', [category])
          .order('id', ascending: false);

      return (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } catch (e) {
      print('❌ Error al buscar posts por categoría: $e');
      rethrow;
    }
  }
}
