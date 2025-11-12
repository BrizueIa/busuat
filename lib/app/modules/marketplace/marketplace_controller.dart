import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';
import '../../data/services/verification_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_pages.dart';

class MarketplaceController extends GetxController {
  final PostService _postService = PostService();
  final VerificationService _verificationService = VerificationService();
  final AuthRepository _authRepository = AuthRepository();
  final _supabase = Supabase.instance.client;

  // Lista de posts
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'Todos'.obs;

  // Categorías disponibles
  final List<String> categories = [
    'Todos',
    'Comida',
    'Bebidas',
    'Celulares',
    'Videojuegos',
    'Ropa',
    'Otros',
  ];

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  // Verificar si el usuario es estudiante (no invitado)
  bool get isStudent {
    final currentUser = _authRepository.getCurrentUser();
    return currentUser != null && currentUser.userType == 'student';
  }

  // Verificar si hay un usuario logueado
  bool get isLoggedIn {
    return _supabase.auth.currentUser != null;
  }

  // Navegar a la vista de verificación de vendedor
  void goToVerification() {
    if (!isLoggedIn) {
      Get.snackbar(
        'Acceso Denegado',
        'Debes iniciar sesión para solicitar verificación',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(Routes.SELLER_VERIFICATION);
  }

  // Cargar todos los posts
  Future<void> loadPosts() async {
    try {
      isLoading.value = true;
      final allPosts = await _postService.getAllPosts();
      posts.value = allPosts;
    } catch (e) {
      print('❌ Error al cargar posts: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar las publicaciones',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrar posts por categoría
  List<PostModel> get filteredPosts {
    if (selectedCategory.value == 'Todos') {
      return posts;
    }
    return posts
        .where((post) => post.categories.contains(selectedCategory.value))
        .toList();
  }

  // Cambiar categoría seleccionada
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  // Navegar a crear post (solo estudiantes verificados)
  Future<void> goToCreatePost() async {
    if (!isStudent) {
      Get.snackbar(
        'Acceso Denegado',
        'Solo los estudiantes pueden crear publicaciones',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Error',
        'Debes iniciar sesión',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Verificar si el usuario está verificado
    final isVerified = await _verificationService.isUserVerified(user.id);
    if (!isVerified) {
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text('Verificación Obligatoria'),
            ],
          ),
          content: const Text(
            'Para crear publicaciones en el marketplace es obligatorio estar verificado como vendedor.\n\n✓ Protege a la comunidad\n✓ Genera confianza\n✓ Previene fraudes\n\nContacta al staff por WhatsApp para completar tu verificación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                goToVerification();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Verificarme Ahora'),
            ),
          ],
        ),
      );
      return;
    }

    Get.toNamed('/create-post');
  }

  // Crear un nuevo post
  Future<void> createPost({
    required String title,
    required String description,
    required double price,
    String? imgLink,
    required List<String> categories,
    String? phoneNumber,
    String? faculty,
  }) async {
    try {
      // Verificar primero con el AuthRepository
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser == null || currentUser.userType != 'student') {
        Get.snackbar(
          'Error',
          'Debes iniciar sesión como estudiante para crear publicaciones',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Verificar también con Supabase
      final user = _supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Sesión no válida. Por favor inicia sesión nuevamente',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print('👤 Usuario actual UID: ${user.id}');
      print('📧 Email del usuario: ${user.email}');

      // Verificar que el usuario esté verificado
      final isVerified = await _verificationService.isUserVerified(user.id);
      print('🔐 Resultado de verificación: $isVerified');

      if (!isVerified) {
        Get.snackbar(
          'Error',
          'Debes estar verificado para crear publicaciones',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      isLoading.value = true;

      final post = PostModel(
        userId: user.id,
        title: title,
        description: description,
        price: price,
        imgLink: imgLink,
        categories: categories,
        phoneNumber: phoneNumber,
        faculty: faculty,
      );

      await _postService.createPost(post);

      // Recargar la lista de posts después de crear uno nuevo
      await loadPosts();

      // Volver a la vista anterior
      Get.back();

      // Mostrar mensaje de éxito después de volver
      Get.snackbar(
        'Éxito',
        'Publicación creada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear la publicación',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Eliminar un post (solo el dueño)
  Future<void> deletePost(PostModel post) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null || post.userId != user.id) {
        Get.snackbar(
          'Error',
          'No tienes permiso para eliminar esta publicación',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _postService.deletePost(post.id!);

      // Recargar la lista después de eliminar
      await loadPosts();

      Get.snackbar(
        'Éxito',
        'Publicación eliminada',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la publicación',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Refrescar posts (pull to refresh)
  Future<void> refreshPosts() async {
    await loadPosts();
  }

  // Obtener posts del usuario actual
  List<PostModel> get myPosts {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    return posts.where((post) => post.userId == user.id).toList();
  }

  // Navegar a editar post
  void goToEditPost(PostModel post) {
    final user = _supabase.auth.currentUser;
    if (user == null || post.userId != user.id) {
      Get.snackbar(
        'Error',
        'No tienes permiso para editar esta publicación',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed('/edit-post', arguments: post);
  }

  // Eliminar post con confirmación
  void deletePostWithConfirmation(PostModel post) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar Publicación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta publicación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deletePost(post);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Actualizar un post
  Future<void> updatePost(PostModel post) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null || post.userId != user.id) {
        Get.snackbar(
          'Error',
          'No tienes permiso para editar esta publicación',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (post.id == null) {
        Get.snackbar(
          'Error',
          'ID de publicación no válido',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;

      await _postService.updatePost(post.id!, post);

      // Recargar la lista después de actualizar
      await loadPosts();

      Get.snackbar(
        'Éxito',
        'Publicación actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back(); // Volver a la vista anterior
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la publicación',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
