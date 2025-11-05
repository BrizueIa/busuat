import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/post_model.dart';
import 'marketplace_controller.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imgLinkController = TextEditingController();

  final List<String> _selectedCategories = [];
  final MarketplaceController controller = Get.find<MarketplaceController>();
  late PostModel _originalPost;

  @override
  void initState() {
    super.initState();
    // Obtener el post a editar de los argumentos
    _originalPost = Get.arguments as PostModel;

    // Pre-llenar el formulario con los datos existentes
    _titleController.text = _originalPost.title;
    _descriptionController.text = _originalPost.description;
    _priceController.text = _originalPost.price.toString();
    _imgLinkController.text = _originalPost.imgLink ?? '';
    _selectedCategories.addAll(_originalPost.categories);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imgLinkController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      Get.snackbar(
        'Error',
        'Selecciona al menos una categoría',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;

    // Crear el post actualizado
    final updatedPost = _originalPost.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      imgLink: _imgLinkController.text.trim().isEmpty
          ? null
          : _imgLinkController.text.trim(),
      categories: _selectedCategories,
    );

    await controller.updatePost(updatedPost);
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar categorías para no incluir "Todos"
    final availableCategories = controller.categories
        .where((cat) => cat != 'Todos')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Publicación'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    hintText: 'Ej: iPhone 12 Pro Max',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El título debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    hintText: 'Describe tu producto...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    if (value.trim().length < 10) {
                      return 'La descripción debe tener al menos 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Precio
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio *',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El precio es obligatorio';
                    }
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Ingresa un precio válido';
                    }
                    if (price < 0) {
                      return 'El precio debe ser mayor o igual a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sección de imagen (próximamente disponible)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Imagen del producto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Próximamente disponible',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Categorías
                const Text(
                  'Categorías *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => _toggleCategory(category),
                      selectedColor: Colors.orange.shade200,
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Botón de actualizar
                ElevatedButton(
                  onPressed: _updatePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Actualizar Publicación',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
