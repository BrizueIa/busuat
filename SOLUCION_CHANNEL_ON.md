# 🔧 SOLUCIÓN DEFINITIVA: Cambiar de .stream() a .channel().on()

## ❌ Problema actual

Tu código USA `.stream()` que **no escucha eventos en tiempo real**, solo hace un fetch inicial.

Logs actuales:
```
📡 Iniciando stream de Realtime para tabla buses...
✅ Suscripción a Realtime completada
📥 REALTIME UPDATE RECIBIDO
📏 Data length: 0          <-- SOLO RECIBE DATOS INICIALES (vacío)
📦 Raw data: []

[Después activas botón, Edge Function crea el bus]
✅ Ubicación reportada. Usuarios cercanos: 1

[PERO NUNCA LLEGA OTRO UPDATE DE REALTIME] ❌❌❌
```

---

## ✅ SOLUCIÓN

Cambiar el método `getBusLocationStream()` en `bus_tracking_service.dart`

###  Código ACTUAL (INCORRECTO):

```dart
Stream<BusLocation?> getBusLocationStream() {
  return _supabase
      .from('buses')
      .stream(primaryKey: ['id'])  // ❌ ESTE ES EL PROBLEMA
      .eq('bus_number', BUS_NUMBER)
      .map((data) {
        // ... resto del código
      });
}
```

###  Código CORRECTO (usar .channel().on()):

```dart
Stream<BusLocation?> getBusLocationStream() {
  final controller = StreamController<BusLocation?>.broadcast();
  
  // ✅ USAR .channel().on() en lugar de .stream()
  _supabase.channel('public:buses')
    ..on(
      RealtimeListenTypes.postgresChanges,  // ✅ Escucha cambios de Postgres
      ChannelFilter(
        event: '*',          // INSERT, UPDATE, DELETE
        schema: 'public',
        table: 'buses',
        filter: 'bus_number=eq.1',  // ✅ Filtro correcto
      ),
      (payload, [ref]) {
        // ✅ Este callback se ejecuta cada vez que hay un cambio
        final busData = payload['new'] as Map<String, dynamic>?;
        
        if (busData != null) {
          final lat = busData['lat'];
          final lng = busData['lng'];
          
          final busLocation = BusLocation(
            position: LatLng(lat, lng),
            timestamp: DateTime.now(),
            userCount: 1,
            isActive: true,
          );
          
          controller.add(busLocation);  // ✅ Envía al stream
        }
      },
    )
    ..subscribe();  // ✅ Importante: suscribirse al channel
  
  return controller.stream;
}
```

---

## 📋 Cambios a realizar en `bus_tracking_service.dart`

### 1️⃣ Agregar variable de instancia al inicio de la clase:

Después de la línea `StreamSubscription? _busLocationSubscription;`, agrega:

```dart
RealtimeChannel? _realtimeChannel;
```

### 2️⃣ Reemplazar TODO el método `getBusLocationStream()`

Busca desde la línea ~100 hasta ~210 (donde termina el método).

Borra TODO ese bloque y reemplázalo con el código correcto de arriba.

### 3️⃣ Actualizar el método `dispose()`

Cambia:
```dart
void dispose() {
  _updateTimer?.cancel();
  _busLocationSubscription?.cancel();
}
```

Por:
```dart
void dispose() {
  _updateTimer?.cancel();
  
  if (_realtimeChannel != null) {
    _supabase.removeChannel(_realtimeChannel!);
    _realtimeChannel = null;
  }
}
```

---

## 🔍 Diferencias clave

| Característica | `.stream()` ❌ | `.channel().on()` ✅ |
|----------------|---------------|---------------------|
| **Fetch inicial** | ✅ Sí | ❌ No (solo cambios) |
| **Escucha INSERT** | ❌ No | ✅ Sí |
| **Escucha UPDATE** | ❌ No | ✅ Sí |
| **Escucha DELETE** | ❌ No | ✅ Sí |
| **Filtros** | `.eq()` | `filter: 'column=eq.value'` |
| **Estructura payload** | `List<Map>` | `Map` con `'new'`, `'old'`, `'eventType'` |

---

## 📦 Estructura del payload con .channel().on()

Cuando hay un cambio, recibes:

```dart
{
  'eventType': 'INSERT',  // o 'UPDATE' o 'DELETE'
  'schema': 'public',
  'table': 'buses',
  'new': {              // ✅ Datos nuevos de la fila
    'id': 12,
    'bus_number': 1,
    'lat': 22.2776382,
    'lng': -97.865274
  },
  'old': null           // Para UPDATE tiene los valores antiguos
}
```

---

## ✅ Resultado esperado después del cambio

```
📡 Iniciando Realtime Channel...
✅ Channel suscrito

[Usuario activa botón]
🔵 Edge Function actualiza tabla buses
✅ Ubicación reportada

📥 REALTIME POSTGRES CHANGE RECIBIDO ✅✅✅  <-- ✅ AHORA SÍ LLEGA
📊 Event type: INSERT
📦 Full payload: {...}
🧩 Datos del bus: {id: 12, bus_number: 1, lat: 22.277, lng: -97.865}
✅ BusLocation creado: LatLng(22.277, -97.865)

[MapController recibe el update]
📡 MAPCONTROLLER: Realtime update recibido
✅ BUS LOCATION VÁLIDO
🖼️ AGREGANDO MARCADOR DEL BUS  <-- ✅ FUNCIONA
```

---

## 🚨 IMPORTANTE

Después de hacer el cambio, ejecuta:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

Esto asegura que se recompile todo con el código nuevo.

---

¿Necesitas que te prepare un archivo completo con todos los cambios ya hechos? Dímelo y lo genero.
