# Edge Function: register-user

## 📝 Código de Ejemplo

Este es un ejemplo de cómo debe verse tu edge function `register-user` en Supabase.

### Archivo: `supabase/functions/register-user/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Manejo de preflight CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Leer body de la petición
    const { email, password, name } = await req.json()

    // Validaciones básicas
    if (!email || !password) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Email y contraseña son requeridos' 
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    // Validar email de dominio UAT
    if (!email.endsWith('@uat.edu.mx')) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Debes usar un correo institucional @uat.edu.mx' 
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    // Crear cliente de Supabase con Service Role Key para bypasear RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Registrar usuario en auth.users
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true, // Auto-confirmar email (opcional)
      user_metadata: {
        name: name || '',
      },
    })

    if (authError) {
      console.error('Error al crear usuario en auth:', authError)
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: authError.message 
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    // Crear perfil de usuario en tabla profiles (si tienes una)
    const { data: profileData, error: profileError } = await supabaseAdmin
      .from('profiles')
      .insert({
        id: authData.user.id,
        email: email,
        name: name || '',
        user_type: 'student',
        created_at: new Date().toISOString(),
      })
      .select()
      .single()

    if (profileError) {
      console.error('Error al crear perfil:', profileError)
      // No retornamos error porque el usuario ya se creó en auth
      // Solo logueamos el error
    }

    // Respuesta exitosa
    return new Response(
      JSON.stringify({ 
        success: true, 
        data: {
          id: authData.user.id,
          email: email,
          name: name || '',
          created_at: authData.user.created_at,
        }
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )

  } catch (error) {
    console.error('Error general:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Error interno del servidor'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})
```

## 🗄️ Estructura de Base de Datos

### Tabla: `profiles`

Si usas una tabla adicional para perfiles de usuario, debe tener esta estructura:

```sql
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  name text,
  user_type text default 'student',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS
alter table profiles enable row level security;

-- Políticas de seguridad
-- Los usuarios pueden ver y actualizar solo su propio perfil
create policy "Users can view own profile"
  on profiles for select
  using ( auth.uid() = id );

create policy "Users can update own profile"
  on profiles for update
  using ( auth.uid() = id );

-- La función puede insertar cualquier perfil (usando service role key)
create policy "Service role can insert profiles"
  on profiles for insert
  with check ( true );
```

## 🚀 Desplegar la Edge Function

### Paso 1: Instalar Supabase CLI

```bash
# Con npm
npm install -g supabase

# Con brew (macOS)
brew install supabase/tap/supabase

# Con scoop (Windows)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### Paso 2: Login en Supabase

```bash
supabase login
```

### Paso 3: Inicializar proyecto (si no lo has hecho)

```bash
cd /home/brizuela/development/flutterProjects/busuat
supabase init
```

### Paso 4: Crear la función

```bash
supabase functions new register-user
```

Esto creará el archivo: `supabase/functions/register-user/index.ts`

### Paso 5: Copiar el código

Copia el código de ejemplo anterior en `supabase/functions/register-user/index.ts`

### Paso 6: Desplegar

```bash
# Desplegar a tu proyecto
supabase functions deploy register-user --project-ref tzvyirisalzyaapkbwyw

# O si ya tienes linkado el proyecto
supabase link --project-ref tzvyirisalzyaapkbwyw
supabase functions deploy register-user
```

### Paso 7: Verificar

```bash
# Ver funciones desplegadas
supabase functions list --project-ref tzvyirisalzyaapkbwyw
```

## 🧪 Probar la Edge Function

### Desde la terminal

```bash
curl -X POST \
  'https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/register-user' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -d '{
    "email": "test@uat.edu.mx",
    "password": "password123",
    "name": "Test User"
  }'
```

### Desde Supabase Dashboard

1. Ve a **Edge Functions** → `register-user`
2. Click en la pestaña **Invoke**
3. Pega este JSON en el body:
```json
{
  "email": "test@uat.edu.mx",
  "password": "password123",
  "name": "Test User"
}
```
4. Click en **Invoke function**

## 🔐 Variables de Entorno

La edge function necesita estas variables de entorno (Supabase las provee automáticamente):

- `SUPABASE_URL`: URL de tu proyecto
- `SUPABASE_SERVICE_ROLE_KEY`: Key con permisos administrativos
- `SUPABASE_ANON_KEY`: Key pública (si la necesitas)

Estas están disponibles automáticamente en las edge functions.

## 📋 Logs de la Edge Function

Para ver los logs en tiempo real:

```bash
supabase functions logs register-user --project-ref tzvyirisalzyaapkbwyw
```

O desde el Dashboard:
1. **Edge Functions** → `register-user`
2. Pestaña **Logs**

## 🐛 Troubleshooting

### Error: "Service role key not found"

**Solución:** Asegúrate de que la función tenga acceso a las variables de entorno.

### Error: "Table profiles does not exist"

**Solución:** Crea la tabla `profiles` con el SQL proporcionado arriba.

### Error: "Permission denied for table profiles"

**Solución:** Verifica las políticas RLS o usa service role key.

### Error: "Email already exists"

**Solución:** Esto es esperado, Supabase auth no permite emails duplicados.

## 🎯 Alternativa Simple (Sin tabla profiles)

Si no quieres crear una tabla adicional, puedes simplificar la función:

```typescript
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, password, name } = await req.json()

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Solo crear usuario en auth, sin tabla profiles
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { name },
    })

    if (error) throw error

    return new Response(
      JSON.stringify({ 
        success: true, 
        data: {
          id: data.user.id,
          email: email,
          name: name,
        }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})
```

Esta versión más simple solo usa `auth.users` de Supabase.

---

**Nota:** Reemplaza `tzvyirisalzyaapkbwyw` con tu project-ref si es diferente.
