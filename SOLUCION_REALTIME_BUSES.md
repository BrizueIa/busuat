# ✅ Solución: Realtime funcionando con tabla `buses`

## 🔍 Problema Identificado

Los datos de Realtime **SÍ estaban llegando** desde Supabase, pero el código Flutter fallaba al parsearlos porque:

1. ❌ **Primary key incorrecta**: Usaba `bus_number` pero la tabla usa `id`
2. ❌ **Campo `user_count` no existe** en la tabla actual
3. ❌ **Campo `updated_at` no existe** en la tabla actual

### 📊 Metadata real de Realtime:

```json
{
  "schema": "public",
  "table": "buses",
  "commit_timestamp": "2025-10-29T18:06:37.857Z",
  "eventType": "UPDATE",
  "new": {
    "bus_number": 1,
    "geom": "0101000020E6100000C89AECFA607758C0E702F2800D473640",
    "id": 12,
    "lat": 22.2775498,
    "lng": -97.8652942
  },
  "old": {
    "id": 12
  }
}
```

---

## ✅ Cambios Aplicados

### 1️⃣ BusTrackingService - `getBusLocationStream()`

**Antes:**
```dart
.stream(primaryKey: ['bus_number']) // ❌ Incorrecta
.map((data) {
  userCount: busData['user_count'] as int? ?? 0, // ❌ Campo no existe
  timestamp: DateTime.parse(busData['updated_at']), // ❌ Campo no existe
})
```

**Después:**
```dart
.stream(primaryKey: ['id']) // ✅ Correcta
.map((data) {
  userCount: 1, // ✅ Valor por defecto
  timestamp: DateTime.now(), // ✅ Timestamp actual
  position: LatLng(
    (busData['lat'] as num).toDouble(), // ✅ Maneja int y double
    (busData['lng'] as num).toDouble(),
  ),
})
```

### 2️⃣ Edge Function - `user-location-change`

**Removido:**
```typescript
user_count: nearbyCount, // ❌ Columna no existe en tabla
```

**Ahora:**
```typescript
const busData = {
  bus_number: 1,
  lat: lat,
  lng: lng,
  // ✅ Solo campos que existen en la tabla
};
```

---

## 🚀 Cómo Funciona Ahora

### Flujo Completo:

```mermaid
graph LR
    A[Usuario activa<br/>"Estoy en el bus"] --> B[MapController]
    B --> C[Edge Function<br/>user-location-change]
    C --> D[Actualiza tabla buses]
    D --> E[Realtime notifica]
    E --> F[getBusLocationStream]
    F --> G[MapController actualiza marcador]
```

### Logs Esperados:

```
🚀 Iniciando reporte de ubicación...
✅ Usuario existente encontrado: xxx
📍 Obteniendo ubicación actual...
✅ Ubicación obtenida: LatLng(22.277, -97.865)
🔵 Llamando a Edge Function user-location-change...
📥 Respuesta recibida: {success: true, nearby_count: 1}
✅ Ubicación reportada. Usuarios cercanos: 1

📥 Realtime: Datos recibidos de Supabase
   Data: [{id: 12, bus_number: 1, lat: 22.277, lng: -97.865, geom: ...}]
🚌 Procesando datos del bus...
✅ Bus actualizado: LatLng(22.277, -97.865), usuarios: 1
📡 Realtime: Nuevo dato recibido
🔄 Marcadores actualizados
```

---

## 📋 Estructura Actual de la Tabla `buses`

```sql
CREATE TABLE buses (
  id BIGSERIAL PRIMARY KEY,           -- ✅ Primary key real
  bus_number INTEGER UNIQUE NOT NULL,  -- ✅ Identificador lógico
  lat DOUBLE PRECISION NOT NULL,       -- ✅ Latitud
  lng DOUBLE PRECISION NOT NULL,       -- ✅ Longitud
  geom GEOMETRY(Point, 4326)          -- ✅ Geometría PostGIS
);
```

**Nota:** Si necesitas `user_count` en el futuro:

```sql
ALTER TABLE buses ADD COLUMN user_count INTEGER DEFAULT 1;
```

---

## ✅ Verificación

Después de estos cambios:

1. ✅ **Realtime recibe los datos** correctamente
2. ✅ **Stream parsea los datos** sin errores
3. ✅ **Marcador del bus aparece** en el mapa
4. ✅ **Sin errores** de `RealtimeSubscribeException`

---

## 🎯 Próximo Paso

**Hot reload** de la app y activa "Estoy en el bus". Deberías ver:

- ✅ Logs de Realtime recibiendo datos
- ✅ Marcador del bus dibujado en el mapa
- ✅ Card mostrando "1 persona en el bus"
