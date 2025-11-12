import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'marketplace_controller.dart';
import '../../data/services/phone_storage_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imgLinkController = TextEditingController();

  final List<String> _selectedCategories = [];
  final MarketplaceController controller = Get.find<MarketplaceController>();
  final PhoneStorageService _phoneService = PhoneStorageService();

  String? _selectedPhone;
  String? _selectedFacultad;
  List<Map<String, String>> _savedPhones = [];

  final List<String> _facultades = [
    'Ingeniería',
    'Medicina',
    'Derecho',
    'Administración',
    'Arquitectura',
    'Contaduría',
    'Enfermería',
    'Psicología',
    'Educación',
    'Artes',
    'Otra',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedPhones();
  }

  Future<void> _loadSavedPhones() async {
    final phones = _phoneService.getSavedPhones();
    setState(() {
      _savedPhones = phones;
    });
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

  Future<void> _createPost() async {
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

    if (_selectedPhone == null) {
      Get.snackbar(
        'Error',
        'Selecciona un número de teléfono',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_selectedFacultad == null) {
      Get.snackbar(
        'Error',
        'Selecciona tu facultad',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;

    await controller.createPost(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      imgLink: _imgLinkController.text.trim().isEmpty
          ? null
          : _imgLinkController.text.trim(),
      categories: _selectedCategories,
      phoneNumber: _selectedPhone,
      faculty: _selectedFacultad,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar categorías para no incluir "Todos"
    final availableCategories = controller.categories
        .where((cat) => cat != 'Todos')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Publicación'),
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
                      return 'El título es requerido';
                    }
                    if (value.trim().length < 3) {
                      return 'El título debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                  maxLength: 100,
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
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es requerida';
                    }
                    if (value.trim().length < 10) {
                      return 'La descripción debe tener al menos 10 caracteres';
                    }
                    return null;
                  },
                  maxLength: 500,
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El precio es requerido';
                    }
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Ingresa un precio válido';
                    }
                    if (price < 0) {
                      return 'El precio no puede ser negativo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Teléfono de contacto
                if (_savedPhones.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No tienes teléfonos guardados',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Necesitas registrar al menos un número de teléfono para publicar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Get.toNamed('/manage-phones');
                            _loadSavedPhones();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Teléfono'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Teléfono de contacto *',
                      hintText: 'Selecciona un teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    initialValue: _selectedPhone,
                    items: _savedPhones.map((phoneData) {
                      final phone = phoneData['phone'] ?? '';
                      final label = phoneData['label'] ?? '';
                      return DropdownMenuItem(
                        value: phone,
                        child: Text('$label ($phone)'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPhone = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un teléfono';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Facultad
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Facultad *',
                    hintText: 'Selecciona tu facultad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  initialValue: _selectedFacultad,
                  items: _facultades.map((facultad) {
                    return DropdownMenuItem(
                      value: facultad,
                      child: Text(facultad),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFacultad = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona tu facultad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Imagen (próximamente)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subir Imagen',
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
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Categorías
                Text(
                  'Categorías *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.orange.shade100,
                      checkmarkColor: Colors.orange,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.orange : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Botón de crear
                ElevatedButton(
                  onPressed: _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Publicar',
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
