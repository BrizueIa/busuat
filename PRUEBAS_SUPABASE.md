# Guía de Pruebas - Integración Supabase

## 🧪 Cómo probar el registro con Supabase

### Preparación

1. **Asegúrate de que la edge function esté desplegada:**
   - Ve a [Supabase Dashboard](https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions)
   - Verifica que `register-user` aparezca en la lista
   - Estado debe ser "Active" o "Deployed"

2. **Verifica la configuración:**
   - ✅ URL: `https://tzvyirisalzyaapkbwyw.supabase.co`
   - ✅ Anon Key: Configurada en `supabase_config.dart`

### Pasos para probar

#### 1. Abrir la consola de Flutter

En la terminal donde corre `flutter run`, podrás ver los logs en tiempo real.

#### 2. Realizar un registro

1. En la app, ir a "Entrar como Estudiante"
2. Seleccionar "Registrarse"
3. Llenar el formulario:
   - **Nombre:** Juan Pérez
   - **Email:** estudiante@uat.edu.mx
   - **Contraseña:** password123
4. Presionar "Registrarse"

#### 3. Verificar logs en Flutter

Deberías ver en la consola:

**✅ Registro exitoso:**
```
📤 Iniciando registro en Supabase...
Email: estudiante@uat.edu.mx
Nombre: Juan Pérez
📥 Respuesta de Supabase: {success: true, data: {...}}
Status: 200
✅ Usuario registrado exitosamente en Supabase
```

**❌ Error (fallback a local):**
```
📤 Iniciando registro en Supabase...
Email: estudiante@uat.edu.mx
Nombre: Juan Pérez
❌ Error al registrar en Supabase: [mensaje de error]
🔄 Intentando registro local como fallback...
✅ Usuario registrado localmente como fallback
```

#### 4. Verificar en Supabase Dashboard

1. Ve a [Supabase Dashboard](https://app.supabase.com/project/tzvyirisalzyaapkbwyw)
2. Ir a **Database** → **Tables**
3. Buscar la tabla donde se guardan los usuarios
4. Verificar que aparezca el registro con:
   - Email: `estudiante@uat.edu.mx`
   - Nombre: `Juan Pérez`
   - Fecha de creación

#### 5. Verificar en Edge Functions Logs

1. En Supabase Dashboard, ir a **Edge Functions**
2. Click en `register-user`
3. Ir a la pestaña **Logs**
4. Deberías ver la invocación con:
   - Status: 200
   - Body: `{email: "estudiante@uat.edu.mx", password: "...", name: "Juan Pérez"}`
   - Response: `{success: true, data: {...}}`

## 🐛 Problemas Comunes

### Error: "Failed to invoke function"

**Síntomas:**
```
❌ Error al registrar en Supabase: FunctionException...
```

**Posibles causas:**
1. Edge function no está desplegada
2. Nombre de función incorrecto
3. CORS no configurado

**Solución:**
1. Verificar en Dashboard que `register-user` esté activa
2. Verificar nombre exacto de la función (case-sensitive)
3. Revisar código de la edge function para CORS headers

### Error: "Network error"

**Síntomas:**
```
❌ Error al registrar en Supabase: SocketException...
```

**Posibles causas:**
1. Sin conexión a internet
2. URL incorrecta
3. Firewall bloqueando petición

**Solución:**
1. Verificar conexión a internet
2. Verificar URL en `supabase_config.dart`
3. Probar abrir la URL en el navegador

### Warning: "The value of the field '_supabase' isn't used"

**Síntomas:**
```
Warning: The value of the field '_supabase' isn't used.
```

**Causa:**
Esto es normal si aún no has probado el registro. El campo se usará cuando ejecutes el método `registerStudent()`.

**Solución:**
No requiere acción, el warning desaparecerá al usar el método.

## 📊 Estructura esperada de la Edge Function

Tu edge function `register-user` debe recibir y procesar:

### Request Body:
```json
{
  "email": "estudiante@uat.edu.mx",
  "password": "password123",
  "name": "Juan Pérez"
}
```

### Response esperado (exitoso):
```json
{
  "success": true,
  "data": {
    "id": "uuid-generado",
    "email": "estudiante@uat.edu.mx",
    "name": "Juan Pérez",
    "created_at": "2025-10-20T14:30:00Z"
  }
}
```

### Response esperado (error):
```json
{
  "success": false,
  "error": "Email already exists"
}
```

## ✅ Checklist de Verificación

Antes de reportar un problema, verifica:

- [ ] Edge function `register-user` está desplegada
- [ ] Supabase URL es correcta en `supabase_config.dart`
- [ ] Supabase Anon Key es correcta en `supabase_config.dart`
- [ ] App tiene conexión a internet
- [ ] Email cumple con formato @uat.edu.mx
- [ ] Logs de Flutter muestran "📤 Iniciando registro..."
- [ ] Logs de Supabase Edge Functions muestran la invocación

## 🎯 Casos de Prueba

### Test 1: Registro exitoso
- **Input:** email válido, contraseña fuerte, nombre
- **Expected:** Usuario registrado en Supabase + local
- **Verify:** Logs muestran ✅, usuario en DB, redirección a /home

### Test 2: Email duplicado
- **Input:** Registrar mismo email dos veces
- **Expected:** Segundo intento debe fallar
- **Verify:** Error mostrado al usuario

### Test 3: Fallback a local
- **Input:** Desconectar internet, intentar registrar
- **Expected:** Registro local exitoso
- **Verify:** Logs muestran 🔄 fallback, usuario guardado en GetStorage

### Test 4: Email inválido
- **Input:** email sin @uat.edu.mx
- **Expected:** Validación en UI bloquea registro
- **Verify:** No se hace llamada a Supabase

### Test 5: Campos vacíos
- **Input:** Dejar nombre o email vacíos
- **Expected:** Validación en UI muestra error
- **Verify:** No se hace llamada a Supabase

---

**Última actualización:** 20 de Octubre, 2025  
**Versión:** 1.0
