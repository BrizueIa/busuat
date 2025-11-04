# 🔍 Diagnóstico Final: Realtime NO recibe updates

## ✅ Lo que SÍ funciona:

1. ✅ Stream se suscribe correctamente
2. ✅ Recibe el evento inicial (array vacío)
3. ✅ Edge Function actualiza la tabla correctamente  
4. ✅ Supabase Dashboard muestra el update en Realtime
5. ✅ CORS está configurado
6. ✅ Anonymous Auth funciona

## ❌ El Problema:

**Flutter NO recibe los updates DESPUÉS de la suscripción inicial**

### Logs actuales:
```
📡 Iniciando stream de Realtime para tabla buses...
✅ Suscripción a Realtime completada
📥 REALTIME UPDATE RECIBIDO  <-- Solo al inicio
📏 Data length: 0
📦 Raw data: []

[Usuario activa botón]
🔵 Edge Function actualiza tabla buses
✅ Ubicación reportada. Usuarios cercanos: 1

[NO HAY MÁS LOGS DE REALTIME] ❌
```

### Dashboard Supabase muestra:
```json
{
  "eventType": "UPDATE",
  "new": {
    "id": 12,
    "bus_number": 1,
    "lat": 22.2776382,
    "lng": -97.865274
  }
}
```

**Pero Flutter NO recibe este evento.**

---

## 🔧 Posibles Causas:

### 1️⃣ Filtro `.eq()` bloqueando updates

El filtro podría estar aplicándose **incorrectamente** en Supabase Realtime.

**Test:** Quitar temporalmente el filtro:

```dart
return _supabase
    .from('buses')
    .stream(primaryKey: ['id'])
    // .eq('bus_number', BUS_NUMBER)  // ❌ Comentar esta línea
    .map((data) {
      print('📥 TODOS LOS BUSES: $data');
      // ...
    });
```

### 2️⃣ Primary Key incorrecta

La tabla usa `id` como PK pero tal vez el stream necesita `bus_number`.

**Test:** Probar con `bus_number` como primary key:

```dart
.stream(primaryKey: ['bus_number'])
```

### 3️⃣ Realtime Policies

Puede que la policy de RLS esté bloqueando los updates en Realtime.

**Verificar en SQL:**
```sql
SELECT * FROM pg_policies WHERE tablename = 'buses';
```

**Crear policy para Realtime:**
```sql
-- Policy para SELECT (necesaria para Realtime)
CREATE POLICY "Allow realtime select on buses"
ON buses FOR SELECT
TO authenticated, anon
USING (true);
```

### 4️⃣ Supabase Realtime no habilitado correctamente

**Verificar:**
- Dashboard → Database → Replication
- Tabla `buses` debe tener el toggle ON
- Debe estar en la publicación `supabase_realtime`

```sql
-- Verificar publicación
SELECT * FROM pg_publication_tables 
WHERE tablename = 'buses' AND pubname = 'supabase_realtime';
```

---

## 🎯 Plan de Acción:

### Paso 1: Quitar filtro temporalmente

```dart
// En bus_tracking_service.dart
return _supabase
    .from('buses')
    .stream(primaryKey: ['id'])
    // ❌ COMENTAR ESTA LÍNEA TEMPORALMENTE
    // .eq('bus_number', BUS_NUMBER)
    .map((data) {
      print('📥 RECIBIDO (SIN FILTRO): $data');
      // ...
    });
```

**Resultado esperado:** Deberías ver updates con TODOS los buses (incluso si hay otros).

---

### Paso 2: Verificar policies

```sql
-- Ver policies actuales
SELECT * FROM pg_policies WHERE tablename = 'buses';

-- Crear policy de SELECT si no existe
CREATE POLICY "realtime_select_buses"
ON buses FOR SELECT
TO authenticated, anon
USING (true);
```

---

### Paso 3: Verificar Realtime habilitado

```sql
SELECT schemaname, tablename, rowfilter
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime' AND tablename = 'buses';
```

Debe retornar 1 fila. Si está vacío, habilita Realtime en el Dashboard.

---

### Paso 4: Test simple con SQL

```sql
-- Insertar un bus manualmente
INSERT INTO buses (bus_number, lat, lng)
VALUES (99, 22.277, -97.865)
ON CONFLICT (bus_number) DO UPDATE
SET lat = 22.277, lng = -97.865;
```

**Observa** si Flutter recibe el update después de ejecutar esto.

---

## 📋 Checklist de Verificación:

- [ ] Realtime habilitado en Dashboard (Database → Replication)
- [ ] Policy de SELECT existe para `authenticated` y `anon`
- [ ] Primary key `['id']` es correcta
- [ ] Sin filtros, el stream recibe todos los updates
- [ ] Con filtro `.eq('bus_number', 1)` recibe solo bus #1

---

## 🚨 Solución Temporal:

Mientras debugueamos, puedes **forzar un fetch manual** después de reportar ubicación:

```dart
// En map_controller.dart, después de reportUserInBus:
if (success) {
  isInBus.value = true;
  
  // ✅ FETCH MANUAL del bus
  final busData = await _supabase
      .from('buses')
      .select()
      .eq('bus_number', 1)
      .single();
  
  if (busData != null) {
    busLocation.value = BusLocation(
      position: LatLng(busData['lat'], busData['lng']),
      timestamp: DateTime.now(),
      userCount: 1,
      isActive: true,
    );
    _updateMarkers();
  }
  
  // Luego continúa con el stream...
}
```

Esto al menos dibujará el bus inmediatamente aunque Realtime no funcione.
