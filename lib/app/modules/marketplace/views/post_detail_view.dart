import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/rating_service.dart';
import '../../../data/repositories/auth_repository.dart';

class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final RatingService _ratingService = RatingService();
  final _supabase = Supabase.instance.client;
  final _authRepository = AuthRepository();

  double _averageRating = 0.0;
  int _ratingsCount = 0;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadRatingData();
  }

  Future<void> _loadRatingData() async {
    final PostModel post = Get.arguments as PostModel;
    if (post.id == null) return;

    setState(() => _isLoadingRating = true);

    try {
      final avgRating = await _ratingService.getPostAverageRating(post.id!);
      final ratings = await _ratingService.getPostRatings(post.id!);

      setState(() {
        _averageRating = avgRating;
        _ratingsCount = ratings.length;
        _isLoadingRating = false;
      });
    } catch (e) {
      print('Error loading rating: $e');
      setState(() => _isLoadingRating = false);
    }
  }

  Future<void> _showRatingDialog() async {
    // Verificar que sea estudiante (no invitado)
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null || currentUser.userType != 'student') {
      Get.snackbar(
        'Error',
        'Debes iniciar sesión como estudiante para calificar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Verificar que el usuario de Supabase esté autenticado
    final user = _supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Error',
        'Debes iniciar sesión para calificar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Verificar que el correo termine con uat.edu.mx
    if (user.email == null || !user.email!.endsWith('uat.edu.mx')) {
      Get.snackbar(
        'Error',
        'Solo usuarios con correo institucional pueden calificar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    int tempRating = 0;

    await Get.dialog(
      AlertDialog(
        title: const Text('Calificar Publicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona tu calificación:'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < tempRating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() => tempRating = index + 1);
                      },
                    );
                  }),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tempRating == 0) {
                Get.snackbar(
                  'Error',
                  'Selecciona una calificación',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();

              final PostModel post = Get.arguments as PostModel;
              final success = await _ratingService.ratePost(
                postId: post.id!,
                rating: tempRating,
                body: null,
              );

              if (success) {
                await _loadRatingData();
                Get.snackbar(
                  'Éxito',
                  'Calificación guardada',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'No se pudo guardar la calificación',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSeller(String phone) async {
    final whatsappUrl = 'https://wa.me/52$phone';
    final uri = Uri.parse(whatsappUrl);

    try {
      // Intentar abrir WhatsApp directamente
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Error',
          'No se pudo abrir WhatsApp. Verifica que esté instalado.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error al abrir WhatsApp: $e');
      Get.snackbar(
        'Error',
        'No se pudo abrir WhatsApp. Verifica que esté instalado.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final PostModel post = Get.arguments as PostModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              background: post.imgLink != null && post.imgLink!.isNotEmpty
                  ? Image.network(
                      post.imgLink!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Precio
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${post.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (post.faculty != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              post.faculty!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Rating
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Estrellas y promedio
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < _averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.orange,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isLoadingRating
                                ? 'Cargando...'
                                : '${_averageRating.toStringAsFixed(1)} ($_ratingsCount)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Botón para calificar
                          if (!_isLoadingRating)
                            TextButton.icon(
                              onPressed: _showRatingDialog,
                              icon: const Icon(Icons.star_rate, size: 18),
                              label: const Text('Calificar'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Categorías
                if (post.categories.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categorías',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: post.categories
                              .map(
                                (cat) => Chip(
                                  label: Text(cat),
                                  backgroundColor: Colors.orange.shade100,
                                  labelStyle: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 1),

                // Descripción
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // Espacio para el botón flotante
              ],
            ),
          ),
        ],
      ),

      // Botón de contactar
      bottomNavigationBar: post.phoneNumber != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _contactSeller(post.phoneNumber!),
                    icon: const Icon(Bootstrap.whatsapp, size: 24),
                    label: const Text(
                      'Contactar Vendedor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
