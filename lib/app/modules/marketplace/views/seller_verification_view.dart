import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../data/repositories/auth_repository.dart';

class SellerVerificationView extends StatelessWidget {
  const SellerVerificationView({super.key});

  // Número de WhatsApp del staff (reemplazar con el número real)
  static const String staffWhatsAppNumber =
      '528333514381'; // Formato: código país + número sin espacios ni guiones

  // Generar mensaje con UID del usuario
  String _generateWhatsAppMessage(String userId) {
    return '''
Hola! 👋

Quiero verificarme para publicar en el marketplace.

MI UID: $userId

Estoy listo para proporcionar la siguiente información:

📦 Información de productos:
- Fotos de los productos que vendo
- Descripción detallada de lo que vendo

🆔 Documentación:
- Foto de mi INE (Identificación Oficial)
- Foto de mi credencial de estudiante

Quedo atento a sus indicaciones.
''';
  }

  Future<void> _openWhatsApp() async {
    // Obtener el UID del usuario actual
    final userId =
        Supabase.instance.client.auth.currentUser?.id ?? 'DESCONOCIDO';

    // Generar mensaje con UID
    final whatsappMessage = _generateWhatsAppMessage(userId);

    // Formatear el mensaje para URL
    final encodedMessage = Uri.encodeComponent(whatsappMessage);

    // Crear el enlace de WhatsApp
    final whatsappUrl =
        'https://wa.me/$staffWhatsAppNumber?text=$encodedMessage';
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
          'No se pudo abrir WhatsApp. Asegúrate de tener la aplicación instalada.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      print('Error al abrir WhatsApp: $e');
      Get.snackbar(
        'Error',
        'No se pudo abrir WhatsApp. Verifica que esté instalado.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final currentUser = authRepository.getCurrentUser();
    final isStudent = currentUser != null && currentUser.userType == 'student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Vendedor'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: !isStudent
          ? _buildNotStudentView(context)
          : _buildVerificationView(context),
    );
  }

  // Vista cuando el usuario NO es estudiante
  Widget _buildNotStudentView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Acceso Restringido',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Para solicitar verificación como vendedor, primero debes iniciar sesión con tu cuenta de estudiante.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  // Aquí podrías redirigir al login si lo deseas
                  // Get.toNamed(Routes.STUDENT_LOGIN);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Volver',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vista principal de verificación (para estudiantes)
  Widget _buildVerificationView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con ícono
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Conviértete en Vendedor Verificado!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gana la confianza de la comunidad universitaria',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Advertencia importante
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300, width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Verificación Obligatoria',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Es necesario estar verificado para poder crear publicaciones en el marketplace. Esto garantiza la seguridad de toda la comunidad.',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sección de requisitos
          Text(
            'Requisitos para Verificación',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Card de información del negocio
          _RequirementCard(
            icon: Icons.store,
            iconColor: Colors.blue,
            title: 'Información de tu Negocio',
            description:
                'Deberás proporcionar fotos claras de los productos que vendes y una descripción detallada de tu actividad comercial.',
          ),
          const SizedBox(height: 12),

          // Card de INE
          _RequirementCard(
            icon: Icons.badge,
            iconColor: Colors.green,
            title: 'Identificación Oficial (INE)',
            description:
                'Foto de tu credencial de INE para verificar tu identidad. Esta información será confidencial y solo usada para validación.',
          ),
          const SizedBox(height: 12),

          // Card de credencial estudiantil
          _RequirementCard(
            icon: Icons.school,
            iconColor: Colors.purple,
            title: 'Credencial de Estudiante',
            description:
                'Foto de tu credencial estudiantil vigente de la UAT para confirmar que eres parte de la comunidad universitaria.',
          ),
          const SizedBox(height: 32),

          // Sección de beneficios
          Text(
            'Beneficios de la Verificación',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _BenefitItem(
            icon: Icons.check_circle,
            text: 'Insignia de verificado en tus publicaciones',
          ),
          const SizedBox(height: 8),
          _BenefitItem(
            icon: Icons.check_circle,
            text: 'Mayor confianza de los compradores',
          ),
          const SizedBox(height: 8),
          _BenefitItem(
            icon: Icons.check_circle,
            text: 'Acceso a funciones exclusivas para vendedores',
          ),
          const SizedBox(height: 8),
          _BenefitItem(
            icon: Icons.check_circle,
            text: 'Prioridad en el marketplace',
          ),
          const SizedBox(height: 32),

          // Nota de privacidad
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tus datos personales serán tratados de forma confidencial y únicamente utilizados para el proceso de verificación.',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botón de contacto por WhatsApp
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Bootstrap.whatsapp, size: 24),
              label: const Text(
                'Contactar al Staff por WhatsApp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // Color de WhatsApp
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Texto explicativo adicional
          Text(
            'Al presionar el botón, se abrirá WhatsApp con un mensaje predefinido. Envía ese mensaje al staff y ellos te guiarán en el proceso de verificación.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget para tarjetas de requisitos
class _RequirementCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _RequirementCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para items de beneficios
class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}
