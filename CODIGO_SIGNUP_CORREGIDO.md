# 🔧 Código CORREGIDO - Edge Function signup

## ❌ Problema en tu código actual

Tu función **NO tiene headers CORS**, por eso el navegador rechaza la petición antes de que llegue al servidor.

**Tu código actual NO tiene:**
```typescript
// ❌ FALTA ESTO
const corsHeaders = { ... }

// ❌ FALTA manejo de OPTIONS
if (req.method === 'OPTIONS') { ... }

// ❌ FALTA incluir CORS en las respuestas
return new Response(..., { headers: corsHeaders })
```

## ✅ Código CORREGIDO con CORS

Reemplaza TODO el contenido de `/supabase/functions/signup/index.ts` con esto:

```typescript
// /supabase/functions/signup/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ⚠️ CRÍTICO: Headers CORS - SIN ESTO NO FUNCIONA EN NAVEGADORES
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Variables de entorno
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  // ⚠️ CRÍTICO: Manejar OPTIONS para CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: corsHeaders,
      status: 200 
    });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method Not Allowed" }), 
      {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }, // ⚠️ CORS agregado
      }
    );
  }

  try {
    const { email, name, password } = await req.json();
    
    if (!email || !name || !password) {
      return new Response(
        JSON.stringify({
          error: "Faltan campos requeridos: email, name o password"
        }), 
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }, // ⚠️ CORS agregado
        }
      );
    }

    // --- Validación de dominio ---
    const regex = /^[^@]+@([a-zA-Z0-9-]+\.)?uat\.edu\.mx$/;
    if (!regex.test(email)) {
      return new Response(
        JSON.stringify({
          error: "El correo debe ser institucional y terminar en .uat.edu.mx"
        }), 
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }, // ⚠️ CORS agregado
        }
      );
    }

    // --- Revisar si ya existe ---
    const { data: users, error: listError } = await supabase.auth.admin.listUsers({
      page: 1,
      perPage: 200
    });
    
    if (listError) throw listError;

    if (users?.users.some((u) => u.email === email)) {
      return new Response(
        JSON.stringify({
          error: "El usuario ya existe"
        }), 
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }, // ⚠️ CORS agregado
        }
      );
    }

    // --- Crear usuario ---
    const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { name }
    });
    
    if (createError) throw createError;

    return new Response(
      JSON.stringify({
        message: "Usuario creado y contraseña enviada al correo.",
        user: newUser
      }), 
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }, // ⚠️ CORS agregado
      }
    );

  } catch (err) {
    console.error(err);
    return new Response(
      JSON.stringify({
        error: err.message || "Error interno"
      }), 
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }, // ⚠️ CORS agregado
      }
    );
  }
});
```

## 🔍 Cambios Realizados

### 1. Agregado CORS Headers (LÍNEA 5-9)
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
```

### 2. Agregado Manejo OPTIONS (LÍNEA 18-23)
```typescript
if (req.method === 'OPTIONS') {
  return new Response('ok', { 
    headers: corsHeaders,
    status: 200 
  });
}
```

Sin esto, el navegador rechaza la petición ANTES de enviarla.

### 3. Agregado CORS en TODAS las Respuestas
```typescript
// Antes:
return new Response(JSON.stringify({...}), { status: 400 });

// Ahora:
return new Response(JSON.stringify({...}), { 
  status: 400,
  headers: { ...corsHeaders, 'Content-Type': 'application/json' },
});
```

## 🚀 Cómo Actualizar

### Opción 1: Desde Supabase Dashboard (MÁS FÁCIL)

1. Ve a: https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions/signup
2. Click en **"Edit"** o el icono de lápiz
3. **BORRA TODO** el código actual
4. **PEGA** el código corregido de arriba
5. Click en **"Deploy"** o **"Save"**
6. Espera 10-15 segundos

### Opción 2: Desde archivo local

Si tienes el archivo localmente:

```bash
# Editar archivo
nano /home/brizuela/development/flutterProjects/busuat/supabase/functions/signup/index.ts

# Pegar código corregido

# Desplegar
supabase functions deploy signup --project-ref tzvyirisalzyaapkbwyw
```

## 🧪 Probar que Funciona

### Desde la app Flutter:

1. **Recarga la app** (hot reload o restart)
2. Intenta **registrar un usuario**
3. Verifica los **logs en terminal**:

**ANTES (con error):**
```
📤 Iniciando registro en Supabase...
❌ Error al registrar en Supabase: ...
Status: 405
```

**DESPUÉS (funcionando):**
```
📤 Iniciando registro en Supabase...
Email: test@alumnos.uat.edu.mx
Nombre: Test User
📥 Respuesta de Supabase: {message: "Usuario creado...", user: {...}}
📊 Status Code: 200
✅ Usuario registrado exitosamente en Supabase
```

### Desde cURL:

```bash
curl -X POST \
  'https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/signup' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6dnlpcmlzYWx6eWFhcGtid3l3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTM1MDUsImV4cCI6MjA3NDY2OTUwNX0.q2VUzlWq1Tw6e0w9X9V7k7AyoWNiNC_bfQWxeJWedMU' \
  -d '{
    "email": "prueba@alumnos.uat.edu.mx",
    "password": "test12345",
    "name": "Usuario Prueba"
  }'
```

Respuesta esperada:
```json
{
  "message": "Usuario creado y contraseña enviada al correo.",
  "user": {
    "user": {
      "id": "uuid...",
      "email": "prueba@alumnos.uat.edu.mx",
      ...
    }
  }
}
```

## 📋 Checklist

Después de actualizar, verifica:

- [ ] Código tiene `const corsHeaders = { ... }`
- [ ] Maneja `if (req.method === 'OPTIONS')`
- [ ] TODAS las respuestas incluyen `headers: { ...corsHeaders, ... }`
- [ ] Función desplegada (status: "Active" en Dashboard)
- [ ] Esperas 10-15 segundos después de desplegar
- [ ] App recargada (hot reload)

## 🎯 Cambios en Flutter

También actualicé el código Flutter para:
1. Llamar a `signup` en vez de `register-user`
2. Manejar la estructura de respuesta correcta (`user` en vez de `data`)

## ⚠️ Por qué daba Error 405

**Problema:** Cuando el navegador intenta hacer una petición POST a otro dominio (CORS), primero envía una petición **OPTIONS** (preflight) para verificar permisos.

**Sin CORS:**
```
Navegador → OPTIONS → Supabase
                    ← 405 (no manejado)
Navegador: ❌ RECHAZA LA PETICIÓN
```

**Con CORS:**
```
Navegador → OPTIONS → Supabase
                    ← 200 OK (con CORS headers)
Navegador → POST → Supabase
                 ← 200 OK (con datos)
Navegador: ✅ ÉXITO
```

## 🔍 Verificar en Logs

Dashboard → Functions → signup → Logs

Deberías ver:
- Peticiones OPTIONS con status 200
- Peticiones POST con status 200
- Sin errores 405

---

**IMPORTANTE:** El problema era CORS, no tu anon key ni la función en sí. Con estos cambios funcionará perfectamente.

**Última actualización:** 20 Oct 2025
