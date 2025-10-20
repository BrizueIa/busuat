import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../guest_controller.dart';

class GuestProfileView extends StatelessWidget {
  const GuestProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuestController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.grey.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar de invitado
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            // Título
            const Text(
              'Modo Invitado',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cuenta no verificada',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Estado de la cuenta
            _buildSectionCard(
              title: 'Estado de la Cuenta',
              icon: Icons.account_circle_outlined,
              children: [
                _buildInfoRow(
                  Icons.person_outline,
                  'Tipo de cuenta',
                  'Invitado',
                  Colors.grey.shade700,
                ),
                const Divider(height: 30),
                _buildInfoRow(
                  Icons.lock_outline,
                  'Estado',
                  'Limitado',
                  Colors.orange.shade700,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Mensaje informativo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.blue.shade700, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¿Eres estudiante de la UAT?',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifica tu cuenta con tu correo institucional para acceder a todas las funcionalidades exclusivas.',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón de verificar cuenta
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.goToVerifyAccount,
                      icon: const Icon(Icons.verified_user),
                      label: const Text(
                        'Verificar mi Cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Botón de cerrar sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text('¿Estás seguro de que deseas salir?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.logout();
                          },
                          child: const Text(
                            'Salir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String feature, bool isAvailable) {
    return Row(
      children: [
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          color: isAvailable ? Colors.green.shade400 : Colors.red.shade400,
          size: 24,
        ),
        const SizedBox(width: 16),
        Icon(
          icon,
          color: isAvailable ? Colors.grey.shade700 : Colors.grey.shade400,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 16,
              color: isAvailable ? Colors.grey.shade800 : Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              decoration: isAvailable ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }
}
