# 🧪 Snippets y Ejemplos de Código - Módulo de Mapa

## 📝 Índice

1. [Navegación](#navegación)
2. [Uso de Servicios](#uso-de-servicios)
3. [Manejo de Permisos](#manejo-de-permisos)
4. [Testing Manual](#testing-manual)
5. [Personalización](#personalización)
6. [Debugging](#debugging)

---

## 🧭 Navegación

### Abrir el mapa desde cualquier lugar

```dart
import 'package:get/get.dart';
import 'package:busuat/app/routes/app_pages.dart';

// Forma 1: Simple
Get.toNamed(Routes.MAP);

// Forma 2: Con reemplazo de ruta
Get.offNamed(Routes.MAP);

// Forma 3: Limpiar stack y abrir mapa
Get.offAllNamed(Routes.MAP);
```

### Abrir el mapa con parámetros (futuro)

```dart
// Si quieres implementar parámetros en el futuro
Get.toNamed(Routes.MAP, arguments: {
  'centerOn': 'bus',
  'showPOI': true,
});

// En MapController.onInit():
final args = Get.arguments as Map<String, dynamic>?;
if (args?['centerOn'] == 'bus') {
  centerOnBus();
}
```

---

## 🔧 Uso de Servicios

### LocationService - Obtener ubicación actual

```dart
import 'package:busuat/app/core/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final locationService = LocationService();

// Verificar permisos
Future<void> checkAndRequestPermissions() async {
  bool hasPermission = await locationService.checkPermissions();
  
  if (!hasPermission) {
    hasPermission = await locationService.requestPermissions();
    
    if (!hasPermission) {
      print('Permisos denegados');
      return;
    }
  }
  
  print('Permisos otorgados');
}

// Obtener ubicación única
Future<void> getLocation() async {
  final location = await locationService.getCurrentLocation();
  
  if (location != null) {
    print('Lat: ${location.latitude}, Lng: ${location.longitude}');
  } else {
    print('No se pudo obtener la ubicación');
  }
}

// Escuchar stream de ubicación
void listenToLocation() {
  final stream = locationService.getLocationStream();
  
  stream.listen((position) {
    print('Nueva ubicación: ${position.latitude}, ${position.longitude}');
    print('Precisión: ${position.accuracy} metros');
  });
}

// Calcular distancia entre dos puntos
void calculateDistance() {
  final point1 = LatLng(22.277125, -97.862299);
  final point2 = LatLng(22.277500, -97.862500);
  
  final distance = locationService.calculateDistance(point1, point2);
  print('Distancia: ${distance.toStringAsFixed(2)} metros');
}

// Verificar si un punto está dentro de un radio
void checkWithinRadius() {
  final busLocation = LatLng(22.277125, -97.862299);
  final userLocation = LatLng(22.277130, -97.862300);
  const radius = 8.0; // metros
  
  final isNear = locationService.isWithinRadius(
    busLocation, 
    userLocation, 
    radius,
  );
  
  print('¿Está cerca? $isNear');
}
```

### BusTrackingService - Reportar ubicación

```dart
import 'package:busuat/app/data/services/bus_tracking_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final busService = BusTrackingService();

// Reportar que el usuario está en el bus
Future<void> reportInBus() async {
  const userId = 'user-123'; // Obtener del auth
  final position = LatLng(22.277125, -97.862299);
  const accuracy = 5.0; // metros
  
  final success = await busService.reportUserInBus(
    userId,
    position,
    accuracy,
  );
  
  if (success) {
    print('Ubicación reportada');
  } else {
    print('Error al reportar');
  }
}

// Obtener usuarios que reportan estar en el bus
Future<void> getUsersInBus() async {
  final users = await busService.getUsersInBus();
  
  print('Usuarios en el bus: ${users.length}');
  for (var user in users) {
    print('- ${user.userId}: ${user.position}');
  }
}

// Calcular ubicación del bus
Future<void> calculateBus() async {
  final busLocation = await busService.calculateBusLocation();
  
  if (busLocation != null) {
    print('Bus en: ${busLocation.position}');
    print('Usuarios reportando: ${busLocation.userCount}');
  } else {
    print('No hay suficientes usuarios para determinar el bus');
  }
}

// Escuchar stream del bus
void listenToBusUpdates() {
  final stream = busService.getBusLocationStream();
  
  stream.listen((busLocation) {
    if (busLocation != null) {
      print('Bus actualizado: ${busLocation.position}');
      print('${busLocation.userCount} usuarios');
    } else {
      print('Bus inactivo');
    }
  });
}
```

---

## 🔐 Manejo de Permisos

### Verificar estado de permisos

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> checkPermissionStatus() async {
  final status = await Permission.location.status;
  
  if (status.isGranted) {
    print('✅ Permisos otorgados');
  } else if (status.isDenied) {
    print('❌ Permisos denegados');
  } else if (status.isPermanentlyDenied) {
    print('⛔ Permisos permanentemente denegados');
    // Abrir configuración
    await openAppSettings();
  } else if (status.isRestricted) {
    print('🔒 Permisos restringidos (iOS)');
  }
}
```

### Solicitar permisos con UI personalizada

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationWithDialog(BuildContext context) async {
  final status = await Permission.location.status;
  
  if (status.isDenied) {
    // Mostrar diálogo explicativo
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de Ubicación'),
        content: const Text(
          'Esta app necesita acceso a tu ubicación para mostrar el mapa '
          'y detectar cuando estás en el autobús.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
    
    if (shouldRequest == true) {
      await Permission.location.request();
    }
  } else if (status.isPermanentlyDenied) {
    // Mostrar diálogo para ir a configuración
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso Requerido'),
        content: const Text(
          'Los permisos de ubicación están permanentemente denegados. '
          'Por favor, habilítalos en la configuración de la app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Testing Manual

### Simular múltiples usuarios (Development)

```dart
// SOLO PARA DESARROLLO - NO USAR EN PRODUCCIÓN
import 'package:busuat/app/data/services/bus_tracking_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> simulateMultipleUsers() async {
  final busService = BusTrackingService();
  
  // Punto central
  const center = LatLng(22.277125, -97.862299);
  
  // Simular 5 usuarios cerca del centro
  for (int i = 0; i < 5; i++) {
    final offset = 0.00001 * i; // ~1 metro de separación
    final position = LatLng(
      center.latitude + offset,
      center.longitude + offset,
    );
    
    await busService.reportUserInBus(
      'test-user-$i',
      position,
      5.0,
    );
    
    print('Usuario $i reportado en $position');
  }
  
  // Calcular bus
  final busLocation = await busService.calculateBusLocation();
  print('Bus calculado en: ${busLocation?.position}');
}
```

### Test de distancias

```dart
import 'package:busuat/app/core/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void testDistances() {
  final locationService = LocationService();
  
  // Casos de prueba
  final testCases = [
    {
      'name': 'Mismo punto',
      'p1': LatLng(22.277125, -97.862299),
      'p2': LatLng(22.277125, -97.862299),
      'expected': 0.0,
    },
    {
      'name': '5 metros',
      'p1': LatLng(22.277125, -97.862299),
      'p2': LatLng(22.277170, -97.862299),
      'expected': 5.0,
    },
    {
      'name': '10 metros',
      'p1': LatLng(22.277125, -97.862299),
      'p2': LatLng(22.277215, -97.862299),
      'expected': 10.0,
    },
  ];
  
  for (var test in testCases) {
    final distance = locationService.calculateDistance(
      test['p1'] as LatLng,
      test['p2'] as LatLng,
    );
    
    print('${test['name']}: ${distance.toStringAsFixed(2)}m '
          '(esperado: ${test['expected']}m)');
  }
}
```

---

## 🎨 Personalización

### Agregar nuevos POIs

```dart
// En MapController._loadPointsOfInterest()

pointsOfInterest.value = [
  // ... POIs existentes ...
  
  // Nuevo POI - Cafetería
  const PointOfInterest(
    id: 'cafeteria_1',
    name: 'Cafetería Central',
    position: LatLng(22.277300, -97.862100),
    type: PoiType.facultad, // O crea un nuevo tipo
    description: 'Cafetería principal del campus',
  ),
  
  // Nuevo POI - Estacionamiento
  const PointOfInterest(
    id: 'parking_1',
    name: 'Estacionamiento A',
    position: LatLng(22.277600, -97.862400),
    type: PoiType.entrada,
    description: 'Estacionamiento para estudiantes',
  ),
];
```

### Cambiar colores de marcadores

```dart
// En MapController._getMarkerIcon()

BitmapDescriptor _getMarkerIcon(PoiType type) {
  switch (type) {
    case PoiType.entrada:
      return BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed, // Cambiar a rojo
      );
    case PoiType.parada:
      return BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue, // Cambiar a azul
      );
    case PoiType.facultad:
      return BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueCyan, // Cambiar a cyan
      );
  }
}
```

### Usar íconos personalizados

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:ui' as ui;

Future<BitmapDescriptor> createCustomMarker(String assetPath) async {
  final bytes = await rootBundle.load(assetPath);
  final image = await decodeImageFromList(bytes.buffer.asUint8List());
  
  return BitmapDescriptor.fromBytes(
    await getBytesFromImage(image, 100), // 100x100 px
  );
}

Future<Uint8List> getBytesFromImage(ui.Image image, int size) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

// Uso:
final customIcon = await createCustomMarker('assets/images/bus_icon.png');

Marker(
  markerId: MarkerId('bus'),
  position: busPosition,
  icon: customIcon,
)
```

---

## 🐛 Debugging

### Logs útiles

```dart
// En MapController

print('📍 Ubicación actual: ${myLocation.value}');
print('🚌 Bus activo: ${busLocation.value != null}');
print('👥 Usuarios en bus: ${await _busTrackingService.getUsersInBus()}');
print('📌 Marcadores visibles: ${markers.length}');
print('✅ Permisos: ${hasLocationPermission.value}');
print('🎯 Estado "Estoy en el bus": ${isInBus.value}');
```

### Debug del algoritmo de clustering

```dart
// En BusTrackingService.calculateBusLocation()

Future<BusLocation?> calculateBusLocation() async {
  final users = await getUsersInBus();
  print('🔍 Usuarios totales: ${users.length}');
  
  final clusters = _clusterUsers(users, BUS_DETECTION_RADIUS);
  print('📊 Clusters encontrados: ${clusters.length}');
  
  for (int i = 0; i < clusters.length; i++) {
    print('   Cluster $i: ${clusters[i].length} usuarios');
  }
  
  if (clusters.isEmpty) {
    print('❌ No hay clusters');
    return null;
  }
  
  final largest = clusters.reduce((a, b) => a.length > b.length ? a : b);
  print('✅ Cluster más grande: ${largest.length} usuarios');
  
  if (largest.length < MIN_USERS_FOR_BUS) {
    print('❌ Insuficientes usuarios (min: $MIN_USERS_FOR_BUS)');
    return null;
  }
  
  // ... resto del código
}
```

### Verificar conexión con Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testSupabaseConnection() async {
  try {
    final supabase = Supabase.instance.client;
    
    // Test de lectura
    final response = await supabase
        .from('user_locations')
        .select()
        .limit(1);
    
    print('✅ Conexión exitosa con Supabase');
    print('📊 Datos: $response');
  } catch (e) {
    print('❌ Error de conexión: $e');
  }
}
```

### Monitor de performance

```dart
import 'dart:async';

class PerformanceMonitor {
  static final _instance = PerformanceMonitor._();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._();
  
  final _metrics = <String, List<Duration>>{};
  
  Future<T> measure<T>(String name, Future<T> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    final result = await fn();
    stopwatch.stop();
    
    _metrics.putIfAbsent(name, () => []).add(stopwatch.elapsed);
    
    print('⏱️ $name: ${stopwatch.elapsedMilliseconds}ms');
    return result;
  }
  
  void printStats() {
    print('\n📊 Performance Stats:');
    _metrics.forEach((name, durations) {
      final avg = durations.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / durations.length;
      print('   $name: ${avg.toStringAsFixed(2)}ms (${durations.length} calls)');
    });
  }
}

// Uso:
final monitor = PerformanceMonitor();

await monitor.measure('calculateBusLocation', () async {
  return await busService.calculateBusLocation();
});

monitor.printStats();
```

---

## 🔄 Stream Helpers

### Combinar múltiples streams

```dart
import 'package:rxdart/rxdart.dart';

Stream<MapState> getCombinedMapState() {
  return Rx.combineLatest3(
    locationService.getLocationStream(),
    busService.getBusLocationStream(),
    poiStream,
    (location, bus, pois) => MapState(
      userLocation: LatLng(location.latitude, location.longitude),
      busLocation: bus,
      pointsOfInterest: pois,
    ),
  );
}
```

### Throttle de actualizaciones

```dart
import 'package:rxdart/rxdart.dart';

Stream<Position> getThrottledLocationStream() {
  return locationService
      .getLocationStream()
      .throttleTime(Duration(seconds: 5)); // Solo 1 actualización cada 5s
}
```

---

## 💾 Persistencia Local (Opcional)

### Guardar última ubicación conocida

```dart
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCache {
  static final _storage = GetStorage();
  static const _key = 'last_location';
  
  static Future<void> save(LatLng location) async {
    await _storage.write(_key, {
      'lat': location.latitude,
      'lng': location.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static LatLng? get() {
    final data = _storage.read(_key);
    if (data == null) return null;
    
    return LatLng(data['lat'], data['lng']);
  }
  
  static bool isRecent({Duration maxAge = const Duration(hours: 1)}) {
    final data = _storage.read(_key);
    if (data == null) return false;
    
    final timestamp = DateTime.parse(data['timestamp']);
    final age = DateTime.now().difference(timestamp);
    
    return age < maxAge;
  }
}
```

---

## 🎯 Unit Tests (Ejemplo)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:busuat/app/core/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('LocationService', () {
    late LocationService service;
    
    setUp(() {
      service = LocationService();
    });
    
    test('calculateDistance returns 0 for same point', () {
      final point = LatLng(22.277125, -97.862299);
      final distance = service.calculateDistance(point, point);
      expect(distance, 0.0);
    });
    
    test('isWithinRadius works correctly', () {
      final p1 = LatLng(22.277125, -97.862299);
      final p2 = LatLng(22.277130, -97.862299); // ~0.5m
      
      expect(service.isWithinRadius(p1, p2, 1.0), true);
      expect(service.isWithinRadius(p1, p2, 0.1), false);
    });
    
    test('calculateCentroid returns null for empty list', () {
      expect(service.calculateCentroid([]), null);
    });
    
    test('calculateCentroid returns correct center', () {
      final points = [
        LatLng(0, 0),
        LatLng(2, 2),
      ];
      final center = service.calculateCentroid(points);
      
      expect(center?.latitude, 1.0);
      expect(center?.longitude, 1.0);
    });
  });
}
```

---

## 📝 Notas Adicionales

### Coordenadas del Campus

```dart
// Puntos de referencia (ajusta según tu universidad)
static const NORTH_ENTRANCE = LatLng(22.278500, -97.862000);
static const SOUTH_ENTRANCE = LatLng(22.275750, -97.862500);
static const EAST_LIMIT = LatLng(22.277125, -97.860500);
static const WEST_LIMIT = LatLng(22.277125, -97.864000);
```

### Conversiones Útiles

```dart
// Metros a grados (aproximado)
// 1 grado de latitud ≈ 111,000 metros
// 1 grado de longitud ≈ 111,000 * cos(latitud) metros

double metersToDegreesLat(double meters) {
  return meters / 111000;
}

double metersToDegreesLng(double meters, double latitude) {
  return meters / (111000 * cos(latitude * pi / 180));
}
```

---

**¡Estos snippets te ayudarán a trabajar con el módulo de mapa! 🚀**

Para más ejemplos, consulta la documentación completa en `MAP_MODULE_README.md`.
