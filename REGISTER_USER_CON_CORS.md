# 🔧 Código CORRECTO para register-user con CORS

## ✅ Código Actualizado

Tu función **`register-user`** debe tener este código con CORS agregado:

```typescript
// /supabase/functions/register-user/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ⚠️ CRÍTICO: Headers CORS - SIN ESTO NO FUNCIONA
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
```

## 🚀 Cómo Actualizar

### Paso 1: Ir al Dashboard
```
https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions/register-user
```

### Paso 2: Editar la Función
1. Click en **"Edit"** o el icono de lápiz
2. Verás el código actual de tu función
3. **REEMPLAZA TODO** con el código de arriba
4. Click en **"Deploy"** o **"Save"**

### Paso 3: Esperar y Probar
1. Espera **10-15 segundos** para que se despliegue
2. En la app Flutter, haz **hot reload** (tecla `r`)
3. Intenta **registrar un usuario**
4. Verifica los **logs en terminal**

## 🔍 Comparación

### Tu código ACTUAL (sin CORS)
```typescript
Deno.serve(async (req) => {
  if (req.method !== "POST") {  // ❌ No maneja OPTIONS
    return new Response(JSON.stringify({ error: "..." }), {
      status: 405  // ❌ Sin CORS headers
    });
  }
  // ...
  return new Response(JSON.stringify({...}), {
    status: 200  // ❌ Sin CORS headers
  });
});
```

### Código CORRECTO (con CORS)
```typescript
const corsHeaders = { ... };  // ✅ Headers definidos

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {  // ✅ Maneja OPTIONS
    return new Response('ok', { headers: corsHeaders });
  }
  
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "..." }), {
      status: 405,
      headers: { ...corsHeaders, ... }  // ✅ CORS incluido
    });
  }
  // ...
  return new Response(JSON.stringify({...}), {
    status: 200,
    headers: { ...corsHeaders, ... }  // ✅ CORS incluido
  });
});
```

## 📊 Logs Esperados

### ANTES (Error 405)
```
📤 Iniciando registro en Supabase...
Email: test@alumnos.uat.edu.mx
URL: https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/register-user
❌ Error al registrar en Supabase: ClientException...
📊 Status Code: 405
```

### DESPUÉS (Funcionando)
```
📤 Iniciando registro en Supabase...
Email: test@alumnos.uat.edu.mx
Nombre: Test User
URL: https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/register-user
📥 Respuesta de Supabase: {message: Usuario creado..., user: {...}}
📊 Status Code: 200
✅ Usuario registrado exitosamente en Supabase
```

## ⚠️ Lo Único que Falta

**Código Flutter:** ✅ Ya está actualizado (llama a `register-user`)

**Función Supabase:** ⚠️ Necesita agregar CORS

Solo tienes que:
1. Abrir función en Dashboard
2. Pegar código de arriba
3. Deploy
4. Probar

**Tiempo:** 2 minutos  
**Dificultad:** Fácil (solo copiar y pegar)

---

**Última actualización:** 20 Oct 2025  
**Función:** register-user (correcto ✅)
