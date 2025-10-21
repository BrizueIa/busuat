# 🔧 Solución Error 405 - Edge Function No Desplegada

## ❌ Problema

Estás recibiendo un **Error 405** al intentar registrar usuarios. Esto significa que la edge function `register-user` **NO ESTÁ DESPLEGADA** en Supabase.

```
Status: 405
Error: La edge function "register-user" no existe o no está desplegada
```

## ✅ Solución Rápida (5 minutos)

### Opción 1: Verificar si existe la función

```bash
# Instalar Supabase CLI (si no lo tienes)
npm install -g supabase

# Login
supabase login

# Verificar funciones existentes
supabase functions list --project-ref tzvyirisalzyaapkbwyw
```

**Si la función NO aparece en la lista** → Continúa con Opción 2

### Opción 2: Crear y Desplegar la Función

#### Paso 1: Crear la función

```bash
cd /home/brizuela/development/flutterProjects/busuat
supabase functions new register-user
```

Esto creará: `supabase/functions/register-user/index.ts`

#### Paso 2: Copiar el código

Abre el archivo `EDGE_FUNCTION_EXAMPLE.md` y copia el código completo de la función.

O usa este código simplificado:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, password, name } = await req.json()

    // Validaciones
    if (!email || !password) {
      throw new Error('Email y contraseña son requeridos')
    }

    if (!email.endsWith('@uat.edu.mx') && !email.endsWith('.uat.edu.mx')) {
      throw new Error('Debes usar un correo institucional @uat.edu.mx')
    }

    // Crear cliente Supabase
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Crear usuario
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

#### Paso 3: Pegar el código

Pega el código en: `supabase/functions/register-user/index.ts`

#### Paso 4: Desplegar

```bash
supabase functions deploy register-user --project-ref tzvyirisalzyaapkbwyw
```

Deberías ver:
```
✓ register-user deployed successfully
```

#### Paso 5: Verificar

```bash
supabase functions list --project-ref tzvyirisalzyaapkbwyw
```

Deberías ver `register-user` en la lista.

### Opción 3: Verificar en Dashboard

1. Ve a: https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions
2. Busca `register-user`
3. Si no existe → Usa Opción 2
4. Si existe pero no funciona → Revisa logs

## 🧪 Probar la Función

Una vez desplegada:

```bash
curl -X POST \
  'https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/register-user' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6dnlpcmlzYWx6eWFhcGtid3l3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTM1MDUsImV4cCI6MjA3NDY2OTUwNX0.q2VUzlWq1Tw6e0w9X9V7k7AyoWNiNC_bfQWxeJWedMU' \
  -d '{
    "email": "test@uat.edu.mx",
    "password": "password123",
    "name": "Test User"
  }'
```

Respuesta esperada:
```json
{
  "success": true,
  "data": {
    "id": "uuid...",
    "email": "test@uat.edu.mx",
    "name": "Test User"
  }
}
```

## 🎯 Probar en la App

Una vez desplegada la función:

1. En la app, ir a Registro
2. Llenar formulario con email @uat.edu.mx
3. Presionar Registrarse
4. Deberías ver en logs:

```
📤 Iniciando registro en Supabase...
📥 Respuesta de Supabase: {success: true, data: {...}}
Status: 200
✅ Usuario registrado exitosamente en Supabase
```

## 🔍 Verificar Logs en Supabase

1. Dashboard: https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions
2. Click en `register-user`
3. Pestaña **Logs**
4. Ver invocaciones recientes

## ❓ Si sigue sin funcionar

### 1. Verificar variables de entorno

En Supabase Dashboard → Settings → API:
- Verifica que `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` estén correctas

### 2. Verificar CORS

La función debe incluir headers CORS. Revisa que el código tenga:

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```

### 3. Revisar logs de error

```bash
supabase functions logs register-user --project-ref tzvyirisalzyaapkbwyw
```

### 4. Probar desde Dashboard

1. Dashboard → Edge Functions → register-user
2. Pestaña **Invoke**
3. Body:
```json
{
  "email": "test@uat.edu.mx",
  "password": "test123",
  "name": "Test"
}
```
4. Click **Invoke function**

## 📝 Cambios Realizados en el Código

### AuthRepository
- ✅ Cambiado de `Future<bool>` a `Future<Map<String, dynamic>>`
- ✅ Eliminado el fallback local
- ✅ Detección específica de error 405
- ✅ Mensajes de error detallados

### RegisterController
- ✅ Manejo de respuesta con Map
- ✅ Mensajes personalizados por tipo de error
- ✅ NO permite registro si Supabase falla
- ✅ Instrucciones claras al usuario

## 🚨 IMPORTANTE

**Ahora el sistema NO tiene fallback local.** Si Supabase falla:
- ❌ El usuario NO puede registrarse
- ✅ Recibe un mensaje claro del problema
- ✅ Se muestran instrucciones para solucionarlo

Esto asegura que TODOS los usuarios estén en la base de datos de Supabase.

---

**Última actualización:** 20 Oct 2025  
**Error:** 405 Method Not Allowed  
**Causa:** Edge function no desplegada  
**Solución:** Desplegar función con Supabase CLI
