import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/core/config/supabase_config.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (solo si existe .env)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      'ℹ️ No se encontró .env, usando dart-define o variables del sistema',
    );
  }

  await GetStorage.init();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Autenticación anónima temporal para pruebas
  try {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      await Supabase.instance.client.auth.signInAnonymously();
      debugPrint('✅ Usuario anónimo creado para pruebas');
    } else {
      debugPrint('✅ Usuario ya autenticado: ${currentUser.id}');
    }
  } catch (e) {
    debugPrint('⚠️ Error en autenticación anónima: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BUSUAT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
