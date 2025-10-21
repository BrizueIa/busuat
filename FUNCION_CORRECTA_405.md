# 🔧 Código Correcto Edge Function - register-user

## ⚠️ Problema Detectado

Tienes la función desplegada en:
```
https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/register-user
```

Pero recibes **Error 405** → Esto significa que:
- ✅ La función existe
- ❌ NO acepta peticiones POST correctamente
- ❌ Puede tener problema de CORS o manejo de método HTTP

## ✅ Código Correcto de la Función

Asegúrate de que tu edge function tenga EXACTAMENTE este código:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

// ⚠️ IMPORTANTE: Headers CORS - DEBEN estar al inicio
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // ⚠️ CRÍTICO: Manejar OPTIONS (preflight CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: corsHeaders,
      status: 200 
    })
  }

  // ⚠️ Solo aceptar POST
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: `Método ${req.method} no permitido. Solo se acepta POST.` 
      }),
      {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }

  try {
    // Leer body
    const { email, password, name } = await req.json()

    // Validaciones
    if (!email || !password) {
      throw new Error('Email y contraseña son requeridos')
    }

    // Validar dominio UAT
    const isValidUATEmail = email.endsWith('@uat.edu.mx') || 
                            email.endsWith('.uat.edu.mx')
    
    if (!isValidUATEmail) {
      throw new Error('Debes usar un correo institucional de la UAT (@uat.edu.mx)')
    }

    // Crear cliente Supabase con Service Role
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Crear usuario en auth
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true, // Auto-confirmar para desarrollo
      user_metadata: {
        name: name || '',
      },
    })

    if (authError) {
      throw new Error(`Error al crear usuario: ${authError.message}`)
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
    console.error('❌ Error en register-user:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Error interno del servidor'
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})
```

## 🔍 Puntos Críticos

### 1. Headers CORS (OBLIGATORIOS)
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}
```

### 2. Manejo OPTIONS (Preflight)
```typescript
if (req.method === 'OPTIONS') {
  return new Response('ok', { 
    headers: corsHeaders,
    status: 200 
  })
}
```

Sin esto, el navegador rechaza la petición antes de enviarla.

### 3. Solo Aceptar POST
```typescript
if (req.method !== 'POST') {
  return new Response(..., { status: 405 })
}
```

### 4. Incluir CORS en TODAS las respuestas
```typescript
return new Response(
  JSON.stringify({...}),
  {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  }
)
```

## 🚀 Cómo Actualizar la Función

### Opción 1: Desde Dashboard (Recomendado)

1. Ve a: https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions/register-user
2. Click en **"Edit"** o **"Code"**
3. **REEMPLAZA TODO** el código con el de arriba
4. Click en **"Deploy"** o **"Save"**
5. Espera a que se despliegue (status: "Active")

### Opción 2: Desde CLI

```bash
cd /home/brizuela/development/flutterProjects/busuat

# Si no existe el directorio
mkdir -p supabase/functions/register-user

# Copiar código
# Pega el código de arriba en: supabase/functions/register-user/index.ts

# Desplegar
supabase functions deploy register-user --project-ref tzvyirisalzyaapkbwyw
```

## 🧪 Probar la Función

### Desde terminal (cURL)

```bash
curl -X POST \
  'https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/register-user' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6dnlpcmlzYWx6eWFhcGtid3l3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTM1MDUsImV4cCI6MjA3NDY2OTUwNX0.q2VUzlWq1Tw6e0w9X9V7k7AyoWNiNC_bfQWxeJWedMU' \
  -d '{
    "email": "prueba@alumnos.uat.edu.mx",
    "password": "test12345",
    "name": "Usuario Prueba"
  }'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "data": {
    "id": "uuid...",
    "email": "prueba@alumnos.uat.edu.mx",
    "name": "Usuario Prueba",
    "created_at": "2025-10-20T..."
  }
}
```

### Desde Supabase Dashboard

1. Dashboard → Edge Functions → register-user
2. Pestaña **"Invoke"**
3. Body:
```json
{
  "email": "test@alumnos.uat.edu.mx",
  "password": "password123",
  "name": "Test User"
}
```
4. Click **"Invoke function"**

## 🔍 Revisar Logs

Para ver qué está pasando:

1. Dashboard: https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions/register-user/logs
2. Busca invocaciones recientes
3. Revisa errores o warnings

O desde CLI:
```bash
supabase functions logs register-user --project-ref tzvyirisalzyaapkbwyw
```

## ✅ Checklist de Verificación

Asegúrate de que tu función tenga:

- [ ] Headers CORS definidos
- [ ] Manejo de OPTIONS (preflight)
- [ ] Solo acepta POST
- [ ] CORS en todas las respuestas (200, 400, 405)
- [ ] Content-Type: application/json
- [ ] Manejo de errores con try/catch
- [ ] Validación de email UAT
- [ ] Usa SUPABASE_SERVICE_ROLE_KEY (no anon key)

## 🎯 Después de Actualizar

1. **Espera 10-15 segundos** para que se despliegue
2. **Recarga la app** en el navegador
3. **Intenta registrar** un usuario
4. **Verifica logs** en la terminal Flutter

Deberías ver:
```
📤 Iniciando registro en Supabase...
Email: test@alumnos.uat.edu.mx
Nombre: Test User
URL: https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/register-user
📥 Respuesta de Supabase: {success: true, data: {...}}
📊 Status Code: 200
✅ Usuario registrado exitosamente en Supabase
```

## 🚨 Si Aún Da Error 405

1. **Verifica en Dashboard** que la función esté "Active"
2. **Revisa logs** para ver errores específicos
3. **Asegúrate** de que reemplazaste TODO el código
4. **Espera** unos segundos después de desplegar
5. **Limpia caché** del navegador (Ctrl+Shift+R)

## 📞 Debugging Adicional

Si necesitas más información, mira los logs en Flutter:
```
📊 Status Code: 405
```

Y los logs en Supabase Dashboard mostrarán el error exacto.

---

**IMPORTANTE:** El problema NO es el anon key (está correcta). El problema es CORS o manejo de método HTTP en la función.

**Última actualización:** 20 Oct 2025
