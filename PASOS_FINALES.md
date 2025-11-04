# 🚀 Pasos Finales para Activar el Botón "Estoy en el Bus"

## ✅ Implementación Completada

¡La funcionalidad ya está 100% implementada en el código! Solo necesitas completar la configuración en Supabase.

---

## 📋 Checklist de Configuración

### 1. ✅ Credenciales de Supabase (Ya Configurado)

Tu archivo `.env` ya contiene las credenciales:
```properties
SUPABASE_URL=https://tzvyirisalzyaapkbwyw.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2. ⚠️ Tabla `buses` en Supabase (REQUERIDO)

Necesitas crear la tabla que almacenará la posición del bus:

#### a) Ve a Supabase Dashboard
1. Abre: https://supabase.com/dashboard
2. Selecciona tu proyecto: `tzvyirisalzyaapkbwyw`
3. Ve a **SQL Editor**

#### b) Ejecuta este SQL:

```sql
-- Crear tabla buses
CREATE TABLE IF NOT EXISTS buses (
  bus_number INT PRIMARY KEY,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  user_count INT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crear trigger para updated_at
CREATE OR REPLACE FUNCTION update_buses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER buses_updated_at
    BEFORE UPDATE ON buses
    FOR EACH ROW
    EXECUTE FUNCTION update_buses_updated_at();

-- IMPORTANTE: Habilitar Realtime para actualizaciones en vivo
ALTER PUBLICATION supabase_realtime ADD TABLE buses;
```

#### c) Verificar que se creó:
1. Ve a **Table Editor**
2. Deberías ver la tabla `buses`

### 3. ⚠️ Habilitar Autenticación Anónima (REQUERIDO)

La app crea usuarios anónimos automáticamente, pero necesitas habilitarlo:

#### a) Ve a Authentication Settings
1. En Supabase Dashboard: **Authentication** → **Settings**
2. Busca **Auth Providers**
3. Encuentra **Anonymous sign-ins**
4. ✅ **Actívalo** (toggle a ON)
5. Guarda los cambios

### 4. ⚠️ Edge Functions Desplegadas (REQUERIDO)

Tus Edge Functions `user-location-change` y `disconnect-user` deben estar desplegadas:

#### Verificar:
1. Ve a **Edge Functions** en Supabase Dashboard
2. Deberías ver:
   - ✅ `user-location-change`
   - ✅ `disconnect-user`

#### Si NO están desplegadas:

```bash
# Instalar Supabase CLI (si no lo tienes)
npm install -g supabase

# Login a Supabase
supabase login

# Desplegar las funciones
supabase functions deploy user-location-change
supabase functions deploy disconnect-user
```

### 5. ✅ Permisos de Ubicación (Ya Configurado)

Ya están configurados en `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

---

## 🧪 Cómo Probar

### Prueba Rápida (1 Dispositivo)

1. **Ejecutar la app:**
   ```bash
   flutter run
   ```

2. **Ir al mapa:**
   - Navega a la vista del mapa

3. **Activar el botón:**
   - Toca el switch "Estoy en el bus"
   - Deberías ver: ✅ "Estás reportando tu ubicación en el autobús"

4. **Verificar en logs:**
   ```
   ✅ Usuario anónimo creado: [uuid]
   ✅ Ubicación reportada. Usuarios cercanos: 1
   ```

5. **Verificar en Supabase:**
   - Ve a **Table Editor** → `user_locations`
   - Deberías ver tu usuario con su ubicación

⚠️ **NOTA:** Con 1 solo usuario NO verás el marcador del bus (necesita mínimo 2 usuarios cercanos)

### Prueba Completa (2+ Dispositivos)

1. **Instalar en varios dispositivos:**
   ```bash
   # Android
   flutter install

   # O generar APK
   flutter build apk
   ```

2. **En cada dispositivo:**
   - Abre la app
   - Ve al mapa
   - Activa "Estoy en el bus"

3. **Acercar los dispositivos:**
   - Deben estar a menos de 5 metros
   - Espera 2-3 segundos

4. **Ver el resultado:**
   - 🚌 Debería aparecer el marcador del bus en el mapa
   - 📋 Tarjeta informativa: "Bus en servicio - X usuarios reportados"

---

## 🔍 Debugging

### Ver Logs en Tiempo Real

```bash
flutter run --verbose
```

### Logs Esperados

✅ **Correcto:**
```
✅ Usuario anónimo creado: 12345678-abcd-...
✅ Ubicación reportada. Usuarios cercanos: 3
🚌 Bus actualizado: LatLng(22.277125, -97.862299)
🟢 Iniciando tracking para usuario: 12345678...
```

❌ **Error - No hay Edge Functions:**
```
❌ Error reportando ubicación del usuario: FunctionsException: ...
```
**Solución:** Desplegar Edge Functions

❌ **Error - Tabla no existe:**
```
❌ Error en Edge Function: 500
```
**Solución:** Crear tabla `buses`

❌ **Error - Realtime no habilitado:**
```
ℹ️ No hay datos del bus en este momento
```
**Solución:** Ejecutar `ALTER PUBLICATION supabase_realtime ADD TABLE buses;`

### Verificar en Supabase Dashboard

#### 1. Ver Usuarios Activos
- **Table Editor** → `user_locations`
- Deberías ver filas con `is_active = true`

#### 2. Ver Posición del Bus
- **Table Editor** → `buses`
- Debería tener una fila con `bus_number = 1`

#### 3. Ver Llamadas a Edge Functions
- **Edge Functions** → Logs
- Deberías ver requests a `user-location-change`

#### 4. Ver Mensajes Realtime
- **Database** → **Replication**
- Verifica que `buses` esté en la lista

---

## 🎯 Estructura de la Base de Datos

### Tabla `user_locations` (De tus Edge Functions)
```
user_id (UUID) - PK
lat (DOUBLE)
lng (DOUBLE)
is_active (BOOLEAN)
updated_at (TIMESTAMP)
```

### Tabla `buses` (Nueva - A crear)
```
bus_number (INT) - PK
lat (DOUBLE)
lng (DOUBLE)
user_count (INT)
updated_at (TIMESTAMP)
```

---

## 📱 Flujo de Datos

```
1. Usuario activa switch
   ↓
2. App crea usuario anónimo en Supabase
   ↓
3. App obtiene ubicación GPS
   ↓
4. App llama Edge Function "user-location-change"
   ↓
5. Edge Function:
   - Guarda ubicación en user_locations
   - Cuenta usuarios cercanos
   - Si hay ≥2: actualiza tabla buses
   ↓
6. Realtime detecta cambio en tabla buses
   ↓
7. App recibe actualización
   ↓
8. App dibuja marcador del bus en el mapa
```

---

## 🎨 Assets del Bus

Los íconos del bus están en:
```
assets/buses/
  ├── 1.png   ← Usado actualmente (60x60 px)
  ├── 2.png
  ├── 3.png
  └── 4.png
```

Para cambiar el ícono del bus, modifica en `map_controller.dart`:
```dart
_customIcons['bus'] = await _getBitmapDescriptorFromAsset(
  'assets/buses/1.png',  // ← Cambia aquí
  60,
  60,
);
```

---

## ⚙️ Configuraciones Avanzadas

### Cambiar Distancia de Detección

En tu Edge Function `user-location-change`:
```javascript
p_radius_m: 5  // ← Cambiar aquí (metros)
```

### Cambiar Mínimo de Usuarios

En tu Edge Function `user-location-change`:
```javascript
if (nearbyCount >= 2) {  // ← Cambiar aquí
```

### Cambiar Intervalo de Actualización

En `location_service.dart`:
```dart
distanceFilter: 5,  // ← Actualiza cada 5 metros
```

---

## 🚨 Solución de Problemas Comunes

### Problema: "Error creating user"
**Causa:** Autenticación anónima no habilitada  
**Solución:** Activar en Authentication → Settings → Anonymous sign-ins

### Problema: Bus no aparece
**Causa:** Menos de 2 usuarios o muy separados  
**Solución:** Probar con 2+ dispositivos a menos de 5 metros

### Problema: "Functions error"
**Causa:** Edge Functions no desplegadas  
**Solución:** `supabase functions deploy user-location-change`

### Problema: No se actualiza en tiempo real
**Causa:** Realtime no habilitado en tabla buses  
**Solución:** `ALTER PUBLICATION supabase_realtime ADD TABLE buses;`

---

## ✅ Checklist Final

Antes de probar, verifica:

- [ ] Tabla `buses` creada en Supabase
- [ ] Realtime habilitado para tabla `buses`
- [ ] Autenticación anónima activada
- [ ] Edge Functions desplegadas:
  - [ ] `user-location-change`
  - [ ] `disconnect-user`
- [ ] Permisos de ubicación aceptados en el dispositivo
- [ ] GPS activado en el dispositivo

---

## 🎉 ¡Listo para Probar!

Una vez completada la checklist:

```bash
# Ejecutar en modo debug
flutter run

# O generar APK para múltiples dispositivos
flutter build apk --release
```

**¡Disfruta del tracking en tiempo real del autobús universitario!** 🚌📍

---

## 📚 Documentación Adicional

- `FUNCIONALIDAD_BUS.md` - Documentación técnica detallada
- `IMPLEMENTACION_COMPLETADA.md` - Resumen de cambios realizados
- `SUPABASE_SETUP.md` - Configuración completa de tablas
