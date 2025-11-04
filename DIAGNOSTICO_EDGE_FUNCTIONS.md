# 🔍 Diagnóstico: Edge Functions No Se Ejecutan

## Problema
Las Edge Functions de Supabase no se están ejecutando cuando se presiona el botón "Estoy en el bus".

## ✅ Cambios Realizados

He agregado **logging extensivo** para identificar exactamente dónde está el problema:

### Logs Agregados:

1. **En MapController:**
   - 🚀 Inicio del proceso
   - ⚠️ Estado de autenticación
   - 📍 Obtención de ubicación
   - 🔄 Llamada al servicio
   - 📊 Resultado de la operación

2. **En BusTrackingService:**
   - 🔵 Inicio de llamada a Edge Function
   - 📥 Respuesta recibida (status y data)
   - ✅ Éxito o ❌ Error con detalles

## 🧪 Cómo Diagnosticar

### Paso 1: Ejecutar la App en Debug

```bash
flutter run --verbose
```

### Paso 2: Activar el Botón

1. Abre la app
2. Ve al mapa
3. Activa el switch "Estoy en el bus"
4. **Observa los logs en la consola**

### Paso 3: Analizar los Logs

Busca estos mensajes en orden:

```
🚀 Iniciando reporte de ubicación...
⚠️ No hay usuario actual, creando sesión anónima...
✅ Usuario anónimo creado: [uuid]
📍 Obteniendo ubicación actual...
✅ Ubicación obtenida: LatLng(22.xxx, -97.xxx)
🔄 Llamando a BusTrackingService...
🔵 Llamando a Edge Function user-location-change...
   User ID: [uuid]
   Lat: 22.xxx, Lng: -97.xxx
📥 Respuesta recibida:
   Status: 200
   Data: {nearby_count: 1}
✅ Ubicación reportada. Usuarios cercanos: 1
```

## 🚨 Posibles Problemas y Soluciones

### Error 1: No se crea usuario anónimo

**Síntoma:**
```
❌ Error: No se pudo crear sesión anónima
```

**Causa:** Autenticación anónima no habilitada en Supabase

**Solución:**
1. Ve a Supabase Dashboard
2. **Authentication** → **Settings**
3. **Auth Providers** → **Anonymous sign-ins**
4. ✅ **Activar**

---

### Error 2: Edge Function no existe

**Síntoma:**
```
❌ Error reportando ubicación del usuario: FunctionsException: Function not found
```

**Causa:** Las Edge Functions no están desplegadas

**Solución:**

```bash
# Ver funciones desplegadas
supabase functions list

# Desplegar si no existen
supabase functions deploy user-location-change
supabase functions deploy disconnect-user
```

**Verificar en Dashboard:**
- Supabase → **Edge Functions**
- Deberías ver: `user-location-change` y `disconnect-user`

---

### Error 3: Error 401 Unauthorized

**Síntoma:**
```
📥 Respuesta recibida:
   Status: 401
```

**Causa:** Problema con las credenciales de Supabase

**Solución:**
1. Verifica que el archivo `.env` tenga las credenciales correctas
2. Verifica que `SUPABASE_ANON_KEY` sea válido
3. Recarga el proyecto: `flutter clean && flutter pub get`

---

### Error 4: Error 500 Internal Server Error

**Síntoma:**
```
📥 Respuesta recibida:
   Status: 500
   Data: Internal error
```

**Causa:** Error en la Edge Function o tabla no existe

**Solución:**

1. **Verificar logs de Edge Function:**
   - Supabase Dashboard → **Edge Functions** → **user-location-change** → **Logs**
   - Busca el error específico

2. **Verificar tabla user_locations existe:**
   ```sql
   -- En SQL Editor de Supabase
   SELECT * FROM user_locations LIMIT 1;
   ```

3. **Verificar función RPC existe:**
   ```sql
   -- En SQL Editor de Supabase
   SELECT * FROM pg_proc WHERE proname = 'nearby_count_for';
   ```

---

### Error 5: No se obtiene ubicación

**Síntoma:**
```
❌ Error: No se pudo obtener ubicación
```

**Causa:** Permisos de ubicación no otorgados o GPS desactivado

**Solución:**
1. En el dispositivo: **Configuración** → **Ubicación** → **Activar**
2. En la app: Aceptar permisos cuando los solicite
3. En Android: Verificar que `AndroidManifest.xml` tenga los permisos

---

### Error 6: Timeout al llamar Edge Function

**Síntoma:**
```
❌ Error reportando ubicación del usuario: TimeoutException
```

**Causa:** Edge Function tarda mucho o red lenta

**Solución:**
1. Verificar conexión a Internet
2. Verificar que la Edge Function no tenga bucles infinitos
3. Aumentar timeout (opcional):
   ```dart
   final response = await _supabase.functions.invoke(
     'user-location-change',
     body: {...},
     headers: {'timeout': '30000'}, // 30 segundos
   );
   ```

---

## 📝 Checklist de Verificación

Antes de ejecutar, verifica:

- [ ] Autenticación anónima habilitada en Supabase
- [ ] Edge Functions desplegadas:
  - [ ] `user-location-change`
  - [ ] `disconnect-user`
- [ ] Tabla `user_locations` existe en Supabase
- [ ] Función RPC `nearby_count_for` existe
- [ ] Tabla `buses` existe en Supabase
- [ ] Archivo `.env` tiene credenciales correctas
- [ ] Permisos de ubicación aceptados en el dispositivo
- [ ] GPS activado en el dispositivo
- [ ] Conexión a Internet activa

---

## 🔬 Test Manual en Supabase

Puedes probar las Edge Functions directamente desde el Dashboard:

### Test de user-location-change:

1. Ve a **Edge Functions** → **user-location-change**
2. Click en **Invoke Function**
3. Body:
   ```json
   {
     "user_id": "test-user-123",
     "lat": 22.277125,
     "lng": -97.862299
   }
   ```
4. Click **Invoke**
5. Deberías ver respuesta:
   ```json
   {
     "nearby_count": 1
   }
   ```

### Verificar en tabla user_locations:

```sql
SELECT * FROM user_locations WHERE user_id = 'test-user-123';
```

---

## 📊 Logs Esperados (Flujo Completo)

### Logs Correctos:
```
🚀 Iniciando reporte de ubicación...
⚠️ No hay usuario actual, creando sesión anónima...
✅ Usuario anónimo creado: 12345678-abcd-1234-5678-123456789abc
📍 Obteniendo ubicación actual...
✅ Ubicación obtenida: LatLng(22.277125, -97.862299)
🔄 Llamando a BusTrackingService...
🔵 Llamando a Edge Function user-location-change...
   User ID: 12345678-abcd-1234-5678-123456789abc
   Lat: 22.277125, Lng: -97.862299
📥 Respuesta recibida:
   Status: 200
   Data: {nearby_count: 1}
✅ Ubicación reportada. Usuarios cercanos: 1
📊 Resultado de reportUserInBus: true
🎧 Iniciando stream de ubicación...
🟢 Iniciando tracking para usuario: 12345678-abcd-1234-5678-123456789abc
```

### En Supabase Logs (Edge Functions):
```
2025-10-29 11:30:15 INFO user-location-change invoked
2025-10-29 11:30:15 INFO User: 12345678-abcd-1234-5678-123456789abc
2025-10-29 11:30:15 INFO Location: (22.277125, -97.862299)
2025-10-29 11:30:15 INFO Nearby count: 1
2025-10-29 11:30:15 INFO Response: 200
```

---

## 🛠️ Comandos Útiles

### Ver logs en tiempo real:
```bash
flutter run --verbose 2>&1 | grep -E "🚀|🔵|📥|✅|❌"
```

### Limpiar y reconstruir:
```bash
flutter clean
flutter pub get
flutter run
```

### Ver funciones de Supabase:
```bash
supabase functions list
```

### Ver logs de Edge Function:
```bash
supabase functions logs user-location-change
```

---

## 📞 Próximos Pasos

1. **Ejecuta la app** con `flutter run --verbose`
2. **Activa el botón** "Estoy en el bus"
3. **Copia los logs** de la consola
4. **Compártelos** para identificar exactamente qué está fallando

Los logs detallados ahora mostrarán:
- ✅ Qué funciona
- ❌ Qué falla
- 📊 Respuestas exactas del servidor

Esto nos permitirá identificar el problema específico y solucionarlo.
