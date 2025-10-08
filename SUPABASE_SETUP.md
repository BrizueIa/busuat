# Configuración de Supabase

## 🔑 Obtener tus credenciales de Supabase

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Ve a **Settings** → **API**
3. Copia las siguientes credenciales:
   - **URL**: Ya está configurada en `supabase_config.dart`
   - **anon/public key**: Necesitas copiar esta clave

## 📝 Configurar el proyecto

1. Abre el archivo: `lib/app/core/config/supabase_config.dart`

2. Reemplaza `YOUR_ANON_KEY_HERE` con tu **anon key** de Supabase:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://tzvyirisalzyaapkbwyw.supabase.co';
  static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI'; // ← Pega tu anon key aquí
}
```

## 🚀 Instalar dependencias

Ejecuta:
```bash
flutter pub get
```

## ✅ Verificar que la función esté desplegada

1. En Supabase Dashboard, ve a **Edge Functions**
2. Verifica que `register-user` esté desplegada y activa
3. La función debe tener configurado CORS correctamente

## 🔧 Configuración CORS en la función Supabase

Tu función `register-user` debe incluir estos headers:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // Manejo de CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    const { email, name, password } = await req.json()
    
    // Tu lógica de registro aquí...
    
    return new Response(
      JSON.stringify({ success: true, data: result }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        },
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      },
    )
  }
})
```

## 📱 Probar el registro

Una vez configurado todo:
1. Ejecuta la app: `flutter run`
2. Intenta registrarte
3. Verifica la consola para ver los logs detallados
