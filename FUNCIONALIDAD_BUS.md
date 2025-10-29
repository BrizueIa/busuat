# Funcionalidad "Estoy en el Bus" 🚌

## Descripción General

Esta funcionalidad permite a los usuarios reportar que están en el autobús universitario. Cuando varios usuarios reportan su ubicación desde posiciones cercanas, el sistema automáticamente calcula y muestra la posición del bus en el mapa en tiempo real.

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App (Cliente)                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  MapView → MapController → BusTrackingService          │ │
│  │                                                         │ │
│  │  • Botón "Estoy en el bus" (Switch)                   │ │
│  │  • Stream de ubicación GPS                            │ │
│  │  • Marcador del bus en mapa                           │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓ ↑
                    (Edge Functions)
                            ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Backend                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Edge Functions:                                        │ │
│  │  • user-location-change (reportar ubicación)           │ │
│  │  • disconnect-user (desconectar usuario)               │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Tablas PostgreSQL:                                     │ │
│  │  • user_locations (ubicaciones de usuarios)            │ │
│  │  • buses (ubicación calculada del bus)                 │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Realtime Subscriptions:                                │ │
│  │  • Stream de tabla 'buses' → Flutter App               │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Flujo de Funcionamiento

### 1. Activar "Estoy en el bus"

Cuando el usuario activa el switch:

1. **Autenticación Anónima**: Se crea automáticamente un usuario anónimo en Supabase
2. **Permisos de Ubicación**: Se solicitan permisos de ubicación en tiempo real
3. **Primera Ubicación**: Se envía la ubicación actual a la Edge Function `user-location-change`
4. **Stream GPS**: Se inicia un stream que envía actualizaciones cada vez que el usuario se mueve

```dart
// En MapController
await _startReportingLocation();
```

### 2. Reporte de Ubicación (Edge Function)

La Edge Function `user-location-change` hace lo siguiente:

1. **Guarda** la ubicación del usuario en `user_locations`
2. **Cuenta** usuarios cercanos (dentro de 5 metros) usando la función RPC `nearby_count_for`
3. **Actualiza el bus** si hay 2 o más usuarios cercanos:
   - Calcula la posición del bus
   - Actualiza la tabla `buses` con la nueva ubicación

```javascript
// Edge Function user-location-change
{
  user_id: "uuid",
  lat: 22.277125,
  lng: -97.862299
}
// Respuesta
{
  nearby_count: 3
}
```

### 3. Visualización en Tiempo Real

El cliente escucha cambios en la tabla `buses`:

```dart
// BusTrackingService
Stream<BusLocation?> getBusLocationStream() {
  return _supabase
      .from('buses')
      .stream(primaryKey: ['bus_number'])
      .eq('bus_number', 1)
      .map((data) => BusLocation.fromJson(data.first));
}
```

Cuando la ubicación del bus cambia:
- Se actualiza el marcador en el mapa con el ícono del bus
- Se muestra una tarjeta informativa con el número de usuarios reportados

### 4. Desactivar "Estoy en el bus"

Cuando el usuario desactiva el switch:

1. **Detener Stream**: Se cancela el stream de ubicación GPS
2. **Disconnect**: Se llama a la Edge Function `disconnect-user`
3. **Limpieza**: Se elimina el usuario de `user_locations`
4. **Recalcular**: Se recalcula si aún hay suficientes usuarios para mostrar el bus

```dart
await _stopReportingLocation();
```

## Componentes del Código

### 1. MapView (`lib/app/modules/home/views/map_view.dart`)

UI principal con:
- Switch "Estoy en el bus"
- Tarjeta de información del bus (`_BuildBusInfoCard`)
- Marcadores en el mapa

### 2. MapController (`lib/app/modules/map/map_controller.dart`)

Controlador principal que:
- Gestiona el estado del switch (`isInBus`)
- Inicia/detiene el reporte de ubicación
- Se suscribe al stream del bus
- Actualiza los marcadores en el mapa

### 3. BusTrackingService (`lib/app/data/services/bus_tracking_service.dart`)

Servicio que:
- Llama a las Edge Functions de Supabase
- Proporciona el stream de ubicación del bus
- Maneja errores y logging

### 4. BusLocation Model (`lib/app/data/models/bus_location.dart`)

Modelo de datos:
```dart
class BusLocation {
  final LatLng position;      // Posición en el mapa
  final DateTime timestamp;    // Última actualización
  final int userCount;         // Usuarios reportados
  final bool isActive;         // Bus activo o no
}
```

## Configuración Necesaria

### 1. Archivo `.env`

```properties
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui
```

### 2. Edge Functions Desplegadas

Asegúrate de que las siguientes funciones estén desplegadas en Supabase:
- `user-location-change`
- `disconnect-user`

### 3. Tabla `buses` en Supabase

```sql
CREATE TABLE buses (
  bus_number INT PRIMARY KEY,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  user_count INT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE buses;
```

### 4. Permisos de Ubicación

En `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## Características Especiales

### ✅ Autenticación Anónima Automática

No requiere que el usuario inicie sesión. Se crea automáticamente un ID único.

### ✅ Actualización en Tiempo Real

El mapa se actualiza instantáneamente cuando el bus se mueve.

### ✅ Ícono Personalizado del Bus

El bus se muestra con el ícono de `assets/buses/1.png` (60x60px).

### ✅ Detección Inteligente

Solo muestra el bus cuando hay 2 o más usuarios cercanos (dentro de 5 metros).

### ✅ Feedback Visual

- Switch con colores verde/gris según el estado
- Tarjeta informativa mostrando usuarios reportados
- Snackbars informativos

## Testing

Para probar la funcionalidad:

1. **Un dispositivo**: No se mostrará el bus (necesita mínimo 2 usuarios)
2. **Dos dispositivos**: 
   - Activa el switch en ambos
   - Acércalos (menos de 5 metros)
   - El bus debería aparecer en el mapa de ambos
3. **Desactivar**: Al desactivar en uno, el bus debería desaparecer

## Debugging

Logs importantes a revisar:

```dart
✅ Usuario anónimo creado: [uuid]
✅ Ubicación reportada. Usuarios cercanos: 3
🚌 Bus actualizado: LatLng(22.277125, -97.862299)
🟢 Iniciando tracking para usuario: [uuid]
🔴 Deteniendo tracking
```

## Posibles Mejoras Futuras

- [ ] Múltiples buses (bus_number 1, 2, 3, etc.)
- [ ] Historial de rutas del bus
- [ ] Predicción de llegada a paradas
- [ ] Notificaciones cuando el bus está cerca
- [ ] Modo conductor (reportar como conductor oficial)
- [ ] Estadísticas de uso

## Solución de Problemas

### El bus no aparece

1. Verifica que las Edge Functions estén desplegadas
2. Confirma que la tabla `buses` tenga Realtime habilitado
3. Revisa que haya al menos 2 usuarios activos cercanos
4. Verifica los logs en Supabase Dashboard

### Error de permisos

1. Asegúrate de aceptar permisos de ubicación
2. Verifica que GPS esté activado en el dispositivo
3. En iOS, verifica `Info.plist` con los permisos necesarios

### El marcador no se actualiza

1. Revisa que el stream esté activo en `_subscribeToBusLocation()`
2. Verifica que `busLocation.value` se esté actualizando
3. Confirma que `_updateMarkers()` se llama cuando cambia `busLocation`

---

**¡Listo para usar!** 🎉

Activa el switch "Estoy en el bus" y disfruta de la funcionalidad en tiempo real.
