import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Usa dart-define con fallback a dotenv
  static String get supabaseUrl {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
}
