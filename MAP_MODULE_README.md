# Módulo de Mapa - Autobús Universitario

## Descripción

Módulo que permite a los usuarios visualizar la ubicación del autobús universitario dentro del campus y conocer los puntos de interés (entradas, paradas y facultades) mediante un mapa interactivo.

## Características Implementadas

✅ **Mapa interactivo** de la universidad con Google Maps
✅ **Botón "Estoy en el bus"** para compartir ubicación en tiempo real
✅ **Detección automática del autobús** basada en:
   - Mínimo de 3 usuarios reportando
   - Radio de proximidad de 8 metros
   - Cálculo de posición promedio (centroide)
✅ **Marcadores fijos** (entradas, paradas, facultades) que pueden ocultarse
✅ **Visualización de ubicación personal** del usuario
✅ **Actualización en tiempo real** usando Supabase Realtime
✅ **Gestión de permisos** de ubicación

## Estructura del Módulo

```
lib/app/
├── core/
│   ├── config/
│   │   └── supabase_config.dart
│   └── services/
│       └── location_service.dart         # Servicio de geolocalización
├── data/
│   ├── models/
│   │   ├── bus_location.dart            # Modelo de ubicación del bus
│   │   ├── point_of_interest.dart       # Modelo de POI
│   │   ├── poi_type.dart                # Enum de tipos de POI
│   │   └── user_location.dart           # Modelo de ubicación de usuario
│   └── services/
│       └── bus_tracking_service.dart     # Servicio de tracking del bus
└── modules/
    └── map/
        ├── map_binding.dart              # Binding de GetX
        ├── map_controller.dart           # Controlador con lógica del mapa
        └── map_page.dart                 # UI del mapa
```

## Configuración

### 1. Dependencias

Las siguientes dependencias ya han sido agregadas a `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.9.0
  geolocator: ^13.0.2
  permission_handler: ^11.3.1
```

### 2. Google Maps API Key

#### Obtener API Key:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita las siguientes APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Ve a **Credentials** y crea una API Key
5. Restringe la API Key por aplicación (recomendado para producción)

#### Configurar la API Key:

**Android:**
- Ya configurado en `android/app/src/main/AndroidManifest.xml`
- Reemplaza `YOUR_GOOGLE_MAPS_API_KEY` con tu API key real

**iOS:**
- Agrega en `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps  // Agregar esta línea

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")  // Agregar esta línea
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Archivo .env:**
- Ya configurado en `.env`
- Reemplaza `YOUR_GOOGLE_MAPS_API_KEY` con tu API key real

### 3. Supabase

Sigue las instrucciones en `SUPABASE_SETUP.md` para crear las tablas necesarias:
- `user_locations` - Ubicaciones de usuarios en el bus
- `bus_locations` - Ubicación calculada del bus
- `points_of_interest` - Puntos de interés (opcional)

### 4. Permisos de Ubicación

Ya configurados en:
- `android/app/src/main/AndroidManifest.xml` (Android)
- `ios/Runner/Info.plist` (iOS)

### 5. Instalación

Ejecuta los siguientes comandos:

```bash
# Instalar dependencias
flutter pub get

# Para iOS, instalar pods
cd ios && pod install && cd ..

# Ejecutar la app
flutter run
```

## Uso

### Navegación al Mapa

Desde cualquier parte de la app:

```dart
Get.toNamed(Routes.MAP);
```

### Configuración de Puntos de Interés

Los POIs están actualmente hardcodeados en `map_controller.dart`. Puedes:

1. **Modificarlos directamente** en el código (líneas 105-143)
2. **Cargarlos desde Supabase** (descomenta las líneas 145-148)
3. **Agregar más puntos** siguiendo el mismo patrón

Ejemplo de POI:

```dart
const PointOfInterest(
  id: 'unique_id',
  name: 'Nombre del lugar',
  position: LatLng(latitude, longitude),
  type: PoiType.entrada, // entrada, parada, o facultad
  description: 'Descripción',
)
```

### Personalización del Punto Central

El punto central del campus está definido en `map_controller.dart`:

```dart
static const CENTRAL_POINT = LatLng(22.277125, -97.862299);
```

Modifícalo según las coordenadas de tu universidad.

### Parámetros Configurables

En `bus_tracking_service.dart`:

```dart
static const double BUS_DETECTION_RADIUS = 8.0;        // Radio en metros
static const int MIN_USERS_FOR_BUS = 3;                // Usuarios mínimos
static const Duration UPDATE_INTERVAL = Duration(seconds: 5);
static const Duration USER_TIMEOUT = Duration(minutes: 2);
```

## Funcionalidades del Mapa

### Controles Disponibles

1. **Botón de Casa** (AppBar) - Centra el mapa en el campus
2. **Botón de Bus** (AppBar) - Centra el mapa en el autobús (si está activo)
3. **Marcadores** (botón lateral) - Muestra/oculta puntos de interés
4. **Mi ubicación** (botón lateral) - Muestra tu ubicación actual
5. **Estoy en el bus** (botón central) - Reporta tu ubicación al sistema

### Cómo Funciona "Estoy en el bus"

1. Usuario presiona el botón "Estoy en el bus"
2. La app solicita permisos de ubicación (si no están otorgados)
3. Se obtiene la ubicación GPS del usuario
4. La ubicación se reporta a Supabase cada 5 segundos
5. El servicio agrupa usuarios cercanos (dentro de 8 metros)
6. Si hay 3+ usuarios en el mismo grupo, se calcula el centroide
7. La posición del bus se muestra en el mapa para todos los usuarios
8. El usuario puede presionar nuevamente para dejar de reportar

### Estados del Sistema

- **Sin bus activo**: No hay suficientes usuarios reportando
- **Bus detectado**: 3+ usuarios cercanos → se muestra el marcador del bus
- **Usuario reportando**: El botón cambia a "Dejar de reportar" (rojo)

## Criterios de Aceptación (Cumplidos)

✅ **1. Mapa fijo de la universidad** - Implementado con Google Maps centrado en el campus

✅ **2. Botón "Estoy en el bus" funcional** - Botón con diseño atractivo que reporta ubicación en tiempo real

✅ **3. Detección condicional del bus** - El bus solo se dibuja si:
   - Hay mínimo 3 usuarios reportando
   - Están dentro de un radio de 8 metros
   - Sus ubicaciones son recientes (< 2 minutos)

✅ **4. Marcadores fijos configurables** - Puntos de interés (entradas, paradas, facultades) que pueden ocultarse con un botón

✅ **5. Ubicación personal del usuario** - Marcador privado que muestra la ubicación actual del usuario

## Mejoras Futuras Sugeridas

- [ ] Íconos personalizados para marcadores (actualmente usa colores)
- [ ] Historial de rutas del autobús
- [ ] Notificaciones push cuando el bus se acerca a una parada
- [ ] Horarios estimados de llegada
- [ ] Múltiples autobuses
- [ ] Modo offline con caché
- [ ] Analytics de uso del autobús
- [ ] Reporte de incidencias

## Troubleshooting

### El mapa no se muestra

- Verifica que la API key de Google Maps esté correctamente configurada
- Asegúrate de tener internet
- Revisa los logs para errores de autenticación

### Los permisos de ubicación no funcionan

- Verifica que los permisos estén declarados en AndroidManifest.xml y Info.plist
- En iOS, asegúrate de tener las descripciones de uso
- Prueba reinstalando la app

### El bus no aparece

- Verifica que haya al menos 3 usuarios reportando
- Confirma que estén dentro del radio de 8 metros
- Revisa que Realtime esté habilitado en Supabase
- Checa los logs del servicio

### Errores de Supabase

- Verifica las credenciales en `.env`
- Confirma que las tablas existan
- Revisa que RLS esté correctamente configurado
- Asegúrate de que Realtime esté habilitado

## Soporte

Para más información o problemas, revisa:
- Documentación de [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- Documentación de [Geolocator](https://pub.dev/packages/geolocator)
- Documentación de [Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)

## Licencia

Este módulo es parte del proyecto BusUAT.
