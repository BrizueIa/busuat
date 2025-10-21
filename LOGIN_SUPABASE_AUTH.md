# 🔐 Login Integrado con Supabase Auth

## ✅ Cambios Realizados

### Problema Anterior

**Registro:** Guardaba en Supabase Auth ✅  
**Login:** Solo buscaba en local storage ❌

Esto causaba inconsistencias:
- Usuario registrado desde otra computadora → No podía hacer login
- Local storage limpiado → Perdía acceso aunque existiera en Supabase

### Solución Implementada

Ahora el login **SÍ usa Supabase Auth** con `signInWithPassword`.

## 🔧 Código Actualizado

### 1. AuthRepository - loginStudent()

**Antes:**
```dart
Future<bool> loginStudent(String email, String password) async {
  // Solo buscaba en GetStorage
  List users = _storage.read(_usersKey) ?? [];
  final user = users.firstWhere(...);
  return user != null;
}
```

**Ahora:**
```dart
Future<Map<String, dynamic>> loginStudent(String email, String password) async {
  // Usa Supabase Auth
  final response = await _supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  
  if (response.user != null) {
    // Guardar sesión localmente
    // Retornar éxito con datos
    return {'success': true, 'userId': ..., 'name': ...};
  }
  
  return {'success': false, 'error': ..., 'message': ...};
}
```

### 2. StudentLoginController

**Actualizado para manejar Map:**
```dart
final result = await _authRepository.loginStudent(email, password);

if (result['success'] == true) {
  // Éxito → Ir a /home
} else {
  // Error → Mostrar mensaje específico
}
```

## 🎯 Flujo Completo

### Registro
```
Usuario → Formulario
      ↓
Edge Function register-user
      ↓
Supabase Auth (createUser)
      ↓
Usuario creado en auth.users
      ↓
Guardar en local (respaldo)
      ↓
Crear sesión → /home
```

### Login
```
Usuario → Formulario
      ↓
Supabase Auth (signInWithPassword)
      ↓
Validar credenciales en auth.users
      ↓
✅ Válido → Crear sesión
      ↓
Guardar en local (respaldo)
      ↓
Ir a /home
```

## 📊 Tipos de Error en Login

| Error | Causa | Mensaje |
|-------|-------|---------|
| INVALID_CREDENTIALS | Email/password incorrectos | "Email o contraseña incorrectos" |
| EMAIL_NOT_CONFIRMED | Email no verificado | "Por favor confirma tu correo electrónico" |
| NETWORK_ERROR | Sin internet | "No se pudo conectar al servidor" |
| UNKNOWN_ERROR | Otro error | "Error al iniciar sesión" |

## 🧪 Pruebas

### Caso 1: Login Exitoso
```
1. Registrar usuario: test@alumnos.uat.edu.mx
2. Hacer logout
3. Intentar login con mismo email/password
4. ✅ Debe entrar exitosamente
```

**Logs esperados:**
```
📤 Iniciando login en Supabase Auth...
Email: test@alumnos.uat.edu.mx
📥 Respuesta de Supabase Auth
Usuario: test@alumnos.uat.edu.mx
Session: Activa
✅ Login exitoso en Supabase Auth
```

### Caso 2: Credenciales Incorrectas
```
1. Intentar login con password incorrecto
2. ❌ Debe mostrar error
```

**Logs esperados:**
```
📤 Iniciando login en Supabase Auth...
❌ Error en login: Invalid login credentials
❌ Error de login: INVALID_CREDENTIALS
❌ Mensaje: Email o contraseña incorrectos
```

### Caso 3: Usuario No Existe
```
1. Intentar login con email que no existe
2. ❌ Debe mostrar error
```

**Mensaje:** "Email o contraseña incorrectos"

### Caso 4: Sin Internet
```
1. Desconectar internet
2. Intentar login
3. ❌ Error de red
```

**Mensaje:** "No se pudo conectar al servidor"

## ✅ Ventajas

### 1. Consistencia Total
- Registro y login usan la misma base de datos
- No hay discrepancias entre local y remoto

### 2. Sincronización
- Login desde cualquier dispositivo
- Usuario siempre accesible si existe en Supabase

### 3. Seguridad
- Supabase maneja hash de contraseñas
- Sesiones manejadas por Supabase Auth
- Tokens seguros

### 4. Respaldo Local
- Guarda sesión en GetStorage
- Permite funcionamiento offline después del login

## 🔄 Compatibilidad

El código mantiene compatibilidad guardando datos en local storage:

```dart
// Guardar sesión localmente
await saveCurrentUser(userModel);

// Guardar en lista local para compatibilidad
List users = _storage.read(_usersKey) ?? [];
// ...
await _storage.write(_usersKey, users);
```

Esto permite:
- Funcionar con código antiguo
- Acceso rápido a datos de usuario
- Caché local

## 📝 Notas Importantes

### 1. Primera Vez
Si el usuario fue registrado ANTES de estos cambios (solo en local):
- ❌ NO podrá hacer login
- ✅ Debe registrarse nuevamente

### 2. Migración
Para migrar usuarios existentes en local a Supabase:
- Necesitarías una función de migración
- O pedir a usuarios que se registren de nuevo

### 3. Email Confirmation
La función register-user crea usuarios con:
```typescript
email_confirm: true
```

Si cambias esto a `false`:
- Usuario recibirá email de confirmación
- Debe confirmar antes de poder hacer login

## 🐛 Troubleshooting

### Error: "Invalid login credentials"
**Causa:** Email o password incorrectos  
**Solución:** Verificar datos o registrarse

### Error: "Email not confirmed"
**Causa:** Email no verificado (si cambiaste email_confirm)  
**Solución:** Revisar email y confirmar

### Error: Network
**Causa:** Sin conexión a Supabase  
**Solución:** Verificar internet y que Supabase esté activo

### Usuario no puede hacer login después de registro
**Causa:** Función register-user no tiene CORS  
**Solución:** Agregar CORS (ver REGISTER_USER_CON_CORS.md)

## 📊 Estado Final

| Funcionalidad | Backend | Estado |
|---------------|---------|--------|
| Registro | Supabase Auth + Edge Function | ✅ Implementado |
| Login | Supabase Auth | ✅ Implementado |
| Logout | Local Storage | ✅ Funcional |
| Sesión | GetStorage + Supabase | ✅ Híbrido |
| Guest Mode | Local | ✅ Funcional |

---

**Fecha:** 20 Oct 2025  
**Cambio:** Login integrado con Supabase Auth  
**Estado:** ✅ Completado
