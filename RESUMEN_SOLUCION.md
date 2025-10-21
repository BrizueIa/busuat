# 🎯 RESUMEN SOLUCIÓN ERROR 405

## ❌ Problema Identificado

Tu función `signup` existe y funciona, pero **falta CORS**.

```
Tu código actual:
❌ Sin corsHeaders
❌ Sin manejo OPTIONS
❌ Sin CORS en respuestas
= Error 405 en navegador
```

## ✅ Solución Aplicada

### 1. Cambios en Flutter ✅

**Actualizado:** `lib/app/data/repositories/auth_repository.dart`

```dart
// ANTES: llamaba a 'register-user'
final response = await _supabase.functions.invoke('register-user', ...)

// AHORA: llama a 'signup'
final response = await _supabase.functions.invoke('signup', ...)
```

**También actualizado:** Manejo de respuesta
```dart
// Tu función devuelve: { message: "...", user: {...} }
if (data['user'] != null) {
  // Extraer userId de user.user.id
}
```

### 2. Cambios Necesarios en Supabase ⚠️

**Archivo:** `supabase/functions/signup/index.ts`

Debes agregar 3 cosas:

#### A) CORS Headers (al inicio)
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
```

#### B) Manejo OPTIONS (después de Deno.serve)
```typescript
if (req.method === 'OPTIONS') {
  return new Response('ok', { 
    headers: corsHeaders,
    status: 200 
  });
}
```

#### C) CORS en TODAS las respuestas
```typescript
// TODAS las respuestas deben incluir:
return new Response(
  JSON.stringify({...}),
  {
    status: 200, // o 400, 405, 500
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  }
);
```

## 🚀 Pasos para Solucionar

### ⚡ RÁPIDO (5 minutos)

1. **Ir a Supabase Dashboard:**
   https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions/signup

2. **Click "Edit"** (icono de lápiz)

3. **Reemplazar código completo** con el de: `CODIGO_SIGNUP_CORREGIDO.md`

4. **Click "Deploy"**

5. **Esperar 10-15 segundos**

6. **Recargar app Flutter** (hot reload o restart)

7. **Probar registro**

## 🧪 Verificación

**En terminal Flutter verás:**

### ANTES (Error)
```
📤 Iniciando registro en Supabase...
❌ Error al registrar en Supabase: ClientException...
📊 Status Code: 405
```

### DESPUÉS (Funcionando)
```
📤 Iniciando registro en Supabase...
Email: test@alumnos.uat.edu.mx
Nombre: Test User
URL: https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/signup
📥 Respuesta de Supabase: {message: Usuario creado..., user: {...}}
📊 Status Code: 200
✅ Usuario registrado exitosamente en Supabase
```

## 📋 Checklist de Solución

- [x] Código Flutter actualizado (llama a 'signup')
- [x] Código Flutter maneja respuesta correcta
- [ ] **Función signup actualizada con CORS** ← ESTO FALTA
- [ ] Función desplegada en Supabase
- [ ] App recargada
- [ ] Registro probado

## 🔍 Diagnóstico del Error 405

```
Flujo SIN CORS:
Navegador → OPTIONS (preflight)
         → Servidor NO responde correctamente
         → Navegador RECHAZA petición
         → Error 405 (antes de llegar a POST)

Flujo CON CORS:
Navegador → OPTIONS (preflight)
         → Servidor: 200 OK + CORS headers
         → Navegador: ✅ Permitido
         → POST con datos
         → Servidor: 200 OK + datos
         → ✅ ÉXITO
```

## 📚 Archivos de Referencia

1. **CODIGO_SIGNUP_CORREGIDO.md** - Código completo listo para copiar
2. **FUNCION_CORRECTA_405.md** - Explicación detallada de CORS
3. **SOLUCION_ERROR_405.md** - Guía alternativa

## 💡 Punto Clave

**Tu anon key está correcta ✅**  
**Tu función existe ✅**  
**Tu código Flutter está actualizado ✅**

**SOLO FALTA:** Agregar CORS a la función en Supabase.

---

**Próximo paso:** Actualizar código de la función en Supabase Dashboard (5 minutos)
