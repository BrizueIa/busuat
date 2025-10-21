# 🚀 Quick Start - Integración Supabase

## ⚡ Inicio Rápido (5 minutos)

### 1. Verificar Edge Function (2 min)

Opción A - Desde Dashboard:
```
1. Ir a: https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions
2. Buscar: "register-user"
3. Si NO existe → Ir al paso 2
4. Si existe → Ir al paso 3
```

Opción B - Desde terminal:
```bash
# Instalar CLI
npm install -g supabase

# Login
supabase login

# Listar funciones
supabase functions list --project-ref tzvyirisalzyaapkbwyw
```

### 2. Crear Edge Function (1 min)

```bash
# En el directorio del proyecto
cd /home/brizuela/development/flutterProjects/busuat

# Crear función
supabase functions new register-user
```

**Copiar código:**
- Abrir: `EDGE_FUNCTION_EXAMPLE.md`
- Copiar código completo de la función
- Pegar en: `supabase/functions/register-user/index.ts`

**Desplegar:**
```bash
supabase functions deploy register-user --project-ref tzvyirisalzyaapkbwyw
```

### 3. Probar Registro (2 min)

La app ya está corriendo. En el navegador:

```
1. Click en "Entrar como Estudiante"
2. Click en "Registrarse"
3. Llenar formulario:
   - Nombre: Test User
   - Email: test@uat.edu.mx
   - Contraseña: password123
4. Click "Registrarse"
5. Ver logs en terminal
```

### 4. Verificar Logs

**En terminal Flutter:**
```
Buscar líneas que empiecen con:
📤 Iniciando registro en Supabase...
📥 Respuesta de Supabase: ...
✅ Usuario registrado exitosamente en Supabase
```

**En Supabase Dashboard:**
```
1. Ir a: https://app.supabase.com/project/tzvyirisalzyaapkbwyw/functions/register-user/logs
2. Ver invocaciones recientes
3. Status debe ser 200
```

---

## 🎯 TL;DR - ¿Qué se hizo?

```dart
// ANTES (solo local):
Future<bool> registerStudent() {
  // Guardar en GetStorage
}

// AHORA (Supabase + fallback):
Future<bool> registerStudent() {
  try {
    // 1. Intentar guardar en Supabase
    await _supabase.functions.invoke('register-user');
    // 2. Guardar también en local
  } catch (e) {
    // 3. Si falla, usar solo local
  }
}
```

---

## 📊 Estado Actual

| Item | Estado |
|------|--------|
| ✅ Código Flutter | Implementado |
| ✅ Supabase Config | Configurado |
| ✅ Logs de debug | Implementados |
| ✅ Sistema fallback | Implementado |
| ⏳ Edge Function | Pendiente deploy |
| ⏳ Pruebas | Listo para probar |

---

## 🔥 Si algo falla

### Escenario 1: "Function not found"
**Causa:** Edge function no desplegada  
**Solución:** Seguir paso 2 arriba  
**Impacto:** ❌ Usa fallback local (app sigue funcionando)

### Escenario 2: "Network error"
**Causa:** Sin internet  
**Solución:** N/A  
**Impacto:** ❌ Usa fallback local (app sigue funcionando)

### Escenario 3: "Success = false"
**Causa:** Error en edge function (ej: email duplicado)  
**Solución:** Revisar logs de Supabase  
**Impacto:** ⚠️ Registro no completado (normal si email existe)

---

## 📖 Documentación Completa

- **INTEGRACION_SUPABASE.md** - Explicación detallada
- **PRUEBAS_SUPABASE.md** - Guía de pruebas paso a paso
- **EDGE_FUNCTION_EXAMPLE.md** - Código de la función
- **RESUMEN_SUPABASE.md** - Resumen ejecutivo

---

**Última actualización:** 20 Oct 2025  
**Tiempo estimado:** 5 minutos  
**Dificultad:** ⭐⭐☆☆☆
