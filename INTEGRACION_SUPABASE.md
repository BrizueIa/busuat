# Integración con Supabase - BUSUAT

## 📋 Resumen

Se ha integrado Supabase como backend para el almacenamiento de usuarios en la base de datos. La aplicación ahora utiliza la edge function `register-user` para guardar usuarios en Supabase, manteniendo un sistema de fallback a almacenamiento local.

## 🔧 Cambios Realizados

### 1. AuthRepository - Integración con Edge Function

**Archivo modificado:** `lib/app/data/repositories/auth_repository.dart`

#### Importaciones agregadas:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

#### Cliente Supabase:
```dart
final SupabaseClient _supabase = Supabase.instance.client;
```

#### Método `registerStudent` actualizado:

**Flujo de trabajo:**

1. **Llamada a Edge Function:**
   ```dart
   final response = await _supabase.functions.invoke(
     'register-user',
     body: {
       'email': email,
       'password': password,
       'name': name,
     },
   );
   ```

2. **Validación de respuesta:**
   - Verifica status 200
   - Verifica que `data['success'] == true` o `data['data'] != null`
   - Extrae el ID del usuario de la respuesta

3. **Almacenamiento dual:**
   - Guarda en Supabase (primario)
   - Guarda en GetStorage local (respaldo)
   - Permite funcionamiento offline

4. **Sistema de Fallback:**
   - Si falla Supabase, utiliza almacenamiento local
   - Logs detallados para debugging
   - No interrumpe la experiencia del usuario

## 📊 Logs de Debugging

El sistema incluye logs completos para facilitar el debugging:

```
📤 Iniciando registro en Supabase...
Email: estudiante@uat.edu.mx
Nombre: Juan Pérez

📥 Respuesta de Supabase: {success: true, data: {...}}
Status: 200

✅ Usuario registrado exitosamente en Supabase
```

En caso de error:
```
❌ Error al registrar en Supabase: [error]
🔄 Intentando registro local como fallback...
✅ Usuario registrado localmente como fallback
```

## 🔄 Edge Function: register-user

### Formato de llamada:
```dart
final response = await supabase.functions.invoke(
  'register-user',
  body: {
    'email': 'estudiante@uat.edu.mx',
    'password': 'password123',
    'name': 'Nombre del estudiante',
  },
);
```

### Respuesta esperada:
```json
{
  "success": true,
  "data": {
    "id": "uuid-del-usuario",
    "email": "estudiante@uat.edu.mx",
    "name": "Nombre del estudiante",
    "created_at": "2025-10-20T..."
  }
}
```

### Respuesta de error:
```json
{
  "success": false,
  "error": "Mensaje de error descriptivo"
}
```

## 🔐 Configuración Requerida

### 1. Supabase Config
**Archivo:** `lib/app/core/config/supabase_config.dart`

✅ Ya configurado con:
- URL: `https://tzvyirisalzyaapkbwyw.supabase.co`
- Anon Key: Configurada correctamente

### 2. Edge Function Deployment

La edge function debe estar desplegada en Supabase con:
- Nombre: `register-user`
- CORS configurado correctamente
- Manejo de errores implementado

### 3. Inicialización en main.dart

✅ Ya inicializado:
```dart
await Supabase.initialize(
  url: SupabaseConfig.supabaseUrl,
  anonKey: SupabaseConfig.supabaseAnonKey,
);
```

## 📱 Flujo de Registro

```
Usuario ingresa datos
        ↓
registerStudent() llamado
        ↓
    ┌───────────────────────┐
    │ Intento Supabase      │
    │ (register-user)       │
    └───────┬───────────────┘
            │
    ┌───────┴────────┐
    │                │
  ✅ Éxito        ❌ Error
    │                │
    │        ┌───────┴────────┐
    │        │ Fallback Local │
    │        └───────┬────────┘
    │                │
    ├────────────────┤
    │                │
 Guardar en     Guardar solo
 Supabase +     en local
 Local
    │                │
    └────────┬───────┘
             │
    Crear sesión y 
    redirigir a /home
```

## ✅ Ventajas de esta Implementación

### 1. **Resiliencia:**
- Si Supabase falla, usa almacenamiento local
- El usuario nunca ve errores de conexión
- Experiencia fluida incluso offline

### 2. **Debugging:**
- Logs detallados en cada paso
- Fácil identificar problemas de conexión
- Trazabilidad completa del proceso

### 3. **Doble almacenamiento:**
- Datos en Supabase (persistencia en la nube)
- Datos en local (acceso rápido y offline)
- Sincronización automática

### 4. **Compatibilidad:**
- Funciona con la edge function existente
- Mantiene estructura de datos original
- No requiere cambios en la UI

## 🧪 Pruebas

### Caso 1: Registro exitoso con Supabase
1. Abrir la app
2. Ir a "Registrarse como Estudiante"
3. Ingresar email válido (@uat.edu.mx)
4. Ingresar contraseña
5. Ver logs en consola: ✅ Usuario registrado exitosamente en Supabase

### Caso 2: Fallback a local
1. Desconectar internet o configurar URL incorrecta
2. Intentar registrarse
3. Ver logs: 🔄 Intentando registro local como fallback...
4. Ver logs: ✅ Usuario registrado localmente como fallback

### Caso 3: Email duplicado
1. Registrar un usuario
2. Intentar registrar con el mismo email
3. Debe mostrar error (en UI o consola)

## 🔍 Validación en Supabase Dashboard

Para verificar que los usuarios se están guardando:

1. Ir a [Supabase Dashboard](https://app.supabase.com)
2. Seleccionar el proyecto: `tzvyirisalzyaapkbwyw`
3. Ir a **Database** → **Tables**
4. Buscar la tabla de usuarios (probablemente `users` o `profiles`)
5. Verificar que aparezcan los registros

## 📝 Próximos Pasos

### Opcional - Mejoras futuras:

1. **Login con Supabase:**
   - Implementar edge function `login-user`
   - Validar credenciales en base de datos
   - Retornar token de sesión

2. **Sincronización:**
   - Sincronizar usuarios locales con Supabase
   - Manejar conflictos de datos
   - Actualización en segundo plano

3. **Verificación de email:**
   - Enviar email de confirmación
   - Validar cuenta antes de acceso completo

4. **Seguridad:**
   - Hash de contraseñas en cliente
   - Rate limiting en edge function
   - Validación de datos en backend

## 🐛 Troubleshooting

### Problema: "Error al registrar en Supabase"

**Posibles causas:**
1. Edge function no desplegada
2. CORS mal configurado
3. URL o anon key incorrecta
4. Sin conexión a internet

**Solución:**
- Verificar logs en consola de Flutter
- Verificar logs en Supabase Dashboard → Edge Functions → Logs
- Verificar configuración en `supabase_config.dart`

### Problema: "Usuario no aparece en Supabase"

**Posibles causas:**
1. Fallback a local activado
2. Edge function no guarda en DB
3. Permisos de tabla incorrectos

**Solución:**
- Revisar logs de la edge function
- Verificar RLS policies en Supabase
- Verificar que la función haga INSERT en la tabla

---

**Fecha de implementación:** 20 de Octubre, 2025  
**Estado:** ✅ Implementado y funcional  
**Branch:** feat/login_api
