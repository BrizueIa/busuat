# Configuración del Bearing (Orientación) del Mapa

## 📐 ¿Qué es el Bearing?

El **bearing** (orientación o rotación) del mapa es el ángulo en grados en sentido horario desde el Norte. 

- **0°** = Norte arriba (orientación por defecto)
- **90°** = Este arriba
- **180°** = Sur arriba
- **270°** = Oeste arriba

## 🎯 Configuración Actual

En tu proyecto, el bearing está configurado en:

```dart
static const double BEARING = 270.0;
```

Esto significa que el mapa está **rotado 270 grados**, colocando el **Oeste en la parte superior**.

### Ubicación de la Constante

La constante se encuentra en: `lib/app/modules/map/map_controller.dart`

## 🔧 Cómo Cambiar el Bearing

### Opción 1: Cambiar el Bearing Global

Edita la constante en `map_controller.dart`:

```dart
// Norte arriba (orientación normal)
static const double BEARING = 0.0;

// Este arriba
static const double BEARING = 90.0;

// Sur arriba
static const double BEARING = 180.0;

// Oeste arriba (configuración actual)
static const double BEARING = 270.0;
```

### Opción 2: Bearing Personalizado

Si necesitas un ángulo específico (por ejemplo, para alinear el mapa con una calle):

```dart
// Ejemplo: 45 grados
static const double BEARING = 45.0;

// Ejemplo: 315 grados (noroeste)
static const double BEARING = 315.0;
```

## 🚀 Mejoras Implementadas

Para asegurar que el bearing se aplique correctamente **tanto en móvil como en web**, se implementó un sistema de aplicación múltiple:

```dart
void _applyInitialCameraPosition(GoogleMapController controller) {
  const targetPosition = CameraPosition(
    target: CENTRAL_POINT,
    zoom: DEFAULT_ZOOM,
    bearing: BEARING,
  );

  // Primera aplicación inmediata
  controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));

  // Segunda aplicación después de 300ms (para móvil)
  Future.delayed(const Duration(milliseconds: 300), () {
    controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  });

  // Tercera aplicación después de 800ms (para web)
  Future.delayed(const Duration(milliseconds: 800), () {
    controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  });
}
```

### ¿Por Qué Tres Veces?

1. **Inmediata**: Intenta aplicar el bearing tan pronto como se crea el mapa
2. **300ms**: Asegura que funcione en móvil (Android/iOS)
3. **800ms**: Asegura que funcione en web, donde la carga puede ser más lenta

## 📱 Diferencias entre Plataformas

### Android/iOS
- ✅ El bearing se aplica consistentemente
- ✅ La rotación es suave
- ✅ Funciona desde la primera aplicación

### Web
- ⚠️ Puede necesitar más tiempo para cargar
- ✅ Se aplica correctamente con los delays implementados
- ✅ La rotación es suave después de cargar

## 🎨 Ejemplos de Uso

### Campus Universitario (Vista Oeste)
```dart
// Ideal para mostrar el campus con orientación oeste
static const double BEARING = 270.0;
static const CENTRAL_POINT = LatLng(22.277125, -97.862299);
```

### Vista Norte (Mapa Normal)
```dart
// Vista tradicional de mapa
static const double BEARING = 0.0;
static const CENTRAL_POINT = LatLng(22.277125, -97.862299);
```

### Alineado con Avenida Principal
```dart
// Si tu campus tiene una avenida principal en ángulo
static const double BEARING = 45.0; // Ajusta según necesites
```

## 🔄 Función centerOnCampus

La función `centerOnCampus()` ahora también aplica el bearing:

```dart
Future<void> centerOnCampus() async {
  await _moveCamera(CENTRAL_POINT, bearing: BEARING);
}
```

Esto asegura que cuando el usuario centre el mapa, siempre vuelva a la orientación correcta.

## 🧪 Pruebas

Para verificar que el bearing funciona correctamente:

### En Android
```bash
flutter run
```

### En Web
```bash
flutter run -d chrome
```

### Verificación Visual
1. El mapa debería aparecer con la orientación configurada
2. Si cambias el bearing, la orientación cambia
3. La función "Centrar en Campus" respeta el bearing

## 💡 Consejos

1. **Para decidir el mejor bearing**:
   - Abre Google Maps en el navegador
   - Navega a tu ubicación
   - Rota el mapa hasta que se vea mejor
   - Usa las herramientas de desarrollador para ver el bearing actual
   - Copia ese valor a tu app

2. **Para deshabilitar la rotación del usuario**:
   Ya está configurado en `platform_map_widget.dart`:
   ```dart
   rotateGesturesEnabled: false,
   ```

3. **Para permitir la rotación del usuario**:
   Cambia a `true` si quieres que el usuario pueda rotar el mapa:
   ```dart
   rotateGesturesEnabled: true,
   ```

## 📝 Resumen de Archivos Modificados

1. **`map_controller.dart`**:
   - Mejorado el método `onMapCreated` con aplicación múltiple
   - Agregado método `_applyInitialCameraPosition`
   - Actualizado método `_moveCamera` para incluir bearing opcional

2. **`platform_map_widget.dart`**:
   - Ya incluye `bearing: MapController.BEARING` en `initialCameraPosition`
   - Gestos de rotación deshabilitados por defecto

## 🎯 Próximos Pasos

Si necesitas cambiar el bearing:
1. Abre `lib/app/modules/map/map_controller.dart`
2. Busca `static const double BEARING = 270.0;`
3. Cambia el valor al ángulo deseado
4. Guarda y ejecuta hot reload (`r` en la terminal)

---

**Última actualización**: Octubre 2025
