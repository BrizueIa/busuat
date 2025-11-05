import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../marketplace/marketplace_controller.dart';

class MarketplaceView extends StatelessWidget {
  const MarketplaceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador si no existe
    if (!Get.isRegistered<MarketplaceController>()) {
      Get.put(MarketplaceController());
    }

    final controller = Get.find<MarketplaceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedCategory.value == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => controller.changeCategory(category),
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.orange.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.orange : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = controller.filteredPosts;

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay publicaciones',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                if (controller.isStudent)
                  ElevatedButton.icon(
                    onPressed: controller.goToCreatePost,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera publicación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPosts,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _PostCard(post: post);
            },
          ),
        );
      }),
      floatingActionButton: controller.isStudent
          ? FloatingActionButton(
              onPressed: controller.goToCreatePost,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _PostCard extends StatelessWidget {
  final dynamic post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle del post
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: post.imgLink != null && post.imgLink!.isNotEmpty
                    ? Image.network(
                        post.imgLink!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.shade400,
                          );
                        },
                      )
                    : Icon(Icons.image, size: 50, color: Colors.grey.shade400),
              ),
            ),
            // Información del producto
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title ?? 'Sin título',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '\$${post.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (post.categories != null && post.categories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          children: post.categories
                              .take(2)
                              .map<Widget>(
                                (cat) => Chip(
                                  label: Text(
                                    cat,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.orange.shade100,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
