# 🔧 Cómo Habilitar Autenticación Anónima en Supabase

## ❌ Problema Detectado

La app está mostrando este error:
```
AuthApiException(message: Anonymous sign-ins are disabled, statusCode: 422, code: anonymous_provider_disabled)
```

Esto significa que **la autenticación anónima está deshabilitada** en tu proyecto de Supabase.

## ✅ Solución: Habilitar Anonymous Auth

### Paso 1: Ir al Dashboard de Supabase

1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto

### Paso 2: Habilitar el Provider Anónimo

1. En el menú lateral, ve a **Authentication** → **Providers**
2. Busca **Anonymous** en la lista de providers
3. Haz clic en el toggle para **HABILITARLO** (debe quedar en verde/activo)
4. Guarda los cambios si es necesario

### Paso 3: Verificar la Configuración

Una vez habilitado, deberías ver:
- ✅ Anonymous: **Enabled** (o similar)

### Paso 4: Probar la App

1. Reinicia tu app Flutter (`r` en la consola o hot reload)
2. Ve al modo invitado o presiona "Estoy en el bus"
3. Ahora deberías ver en la consola:

```
🚀 Iniciando reporte de ubicación...
⚠️ No hay usuario actual, creando sesión anónima...
✅ Usuario anónimo creado: [user-id]
📍 Ubicación obtenida: lat, lng
📥 Llamando a user-location-change...
✅ Respuesta exitosa de Edge Function
```

## 🎯 ¿Por Qué Necesitamos Anonymous Auth?

La funcionalidad del botón "Estoy en el bus" permite que **cualquier usuario sin cuenta** pueda reportar su ubicación. Para esto:

1. Se crea un **usuario anónimo temporal** en Supabase
2. Este usuario puede:
   - Enviar su ubicación GPS
   - Llamar a las Edge Functions
   - Aparecer en tiempo real en el mapa
3. No requiere registro ni login

## 📋 Checklist Completo de Configuración

Para que la funcionalidad completa funcione, verifica también:

- [x] **Anonymous Auth habilitado** ← **ESTO ES LO QUE NECESITAS AHORA**
- [ ] Edge Functions desplegadas:
  - [ ] `user-location-change`
  - [ ] `disconnect-user`
- [ ] Tablas creadas:
  - [ ] `user_locations` (con columnas: id, user_id, lat, lng, is_active, created_at, updated_at)
  - [ ] `buses` (con columnas: id, bus_number, lat, lng, user_count, updated_at)
- [ ] Realtime habilitado en ambas tablas
- [ ] RLS (Row Level Security) configurado apropiadamente

## 🔍 Verificar que Funcionó

Después de habilitar Anonymous Auth, cuando presiones el botón verás:

1. ✅ No más errores de `anonymous_provider_disabled`
2. ✅ Usuario anónimo creado exitosamente
3. ✅ Ubicación GPS obtenida
4. ✅ Llamadas a Edge Functions exitosas
5. ✅ Datos en tiempo real funcionando

---

**¿Tienes problemas?** Revisa que:
- El anonymous provider está realmente habilitado (toggle en verde)
- Has guardado los cambios en Supabase
- Has reiniciado la app después de habilitar el auth
