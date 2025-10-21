# 🚀 Inicio Rápido - Módulo de Mapa

## ⚡ Configuración en 3 Pasos

### 1️⃣ Google Maps API Key (5 minutos)

1. Ve a https://console.cloud.google.com/
2. Crea un proyecto nuevo
3. Habilita estas APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Ve a **Credentials** → **Create Credentials** → **API Key**
5. Copia tu API Key

**Actualiza estos archivos con tu API Key:**

```bash
# .env
GOOGLE_MAPS_API_KEY=TU_API_KEY_AQUI

# android/app/src/main/AndroidManifest.xml (línea ~33)
android:value="TU_API_KEY_AQUI"
```

**Para iOS, agrega en `ios/Runner/AppDelegate.swift`:**
```swift
import GoogleMaps  // Al inicio del archivo

// Dentro de application(_ application:, didFinishLaunchingWithOptions:)
GMSServices.provideAPIKey("TU_API_KEY_AQUI")
```

### 2️⃣ Configurar Supabase (10 minutos)

1. Abre tu proyecto en https://supabase.com
2. Ve a **SQL Editor**
3. Copia y pega el contenido de `SUPABASE_SETUP.md`
4. Ejecuta el SQL
5. Ve a **Database** → **Replication**
6. Habilita Realtime para estas tablas:
   - ✅ `user_locations`
   - ✅ `bus_locations`
   - ✅ `points_of_interest`

### 3️⃣ Ejecutar la App

```bash
# Android
flutter run

# iOS (requiere pod install primero)
cd ios && pod install && cd ..
flutter run
```

---

## 📱 Probar el Módulo

### Opción A: Con múltiples dispositivos (ideal)

1. Instala la app en 3+ dispositivos
2. En cada uno:
   - Abre la app
   - Ve a la pestaña "Mapa"
   - Presiona "Ver Mapa"
   - Presiona "Estoy en el bus"
3. ¡El marcador del bus debería aparecer! 🎉

### Opción B: Con un solo dispositivo (testing básico)

1. Abre la app
2. Ve a la pestaña "Mapa"
3. Presiona "Ver Mapa"
4. Verás:
   - ✅ Mapa del campus
   - ✅ Marcadores de puntos de interés
   - ✅ Controles funcionando
5. Presiona "Estoy en el bus"
   - Tu ubicación se reportará
   - No verás el bus (necesitas 3+ usuarios)

---

## 🐛 Solución de Problemas

### Problema: "El mapa no se muestra"

**Solución:**
- Verifica que agregaste la API Key correctamente
- Revisa los logs: `flutter run` y busca errores de Google Maps
- Asegúrate de tener conexión a internet

### Problema: "No solicita permisos de ubicación"

**Solución Android:**
- Verifica que `AndroidManifest.xml` tenga los permisos
- Desinstala y reinstala la app

**Solución iOS:**
- Verifica que `Info.plist` tenga las descripciones
- Desinstala y reinstala la app

### Problema: "El bus no aparece"

**Solución:**
- Necesitas 3+ usuarios presionando "Estoy en el bus"
- Los usuarios deben estar a menos de 8 metros entre sí
- Verifica que Realtime esté habilitado en Supabase
- Revisa que las tablas existan en Supabase

### Problema: "Errores de compilación"

**Solución:**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # Solo iOS
flutter run
```

---

## 📍 Punto Central del Campus

Actualmente configurado en:
- **Latitud:** 22.277125
- **Longitud:** -97.862299

**Para cambiar:**
Edita `lib/app/modules/map/map_controller.dart` línea 13:
```dart
static const CENTRAL_POINT = LatLng(TU_LAT, TU_LNG);
```

---

## 🎨 Personalizar Puntos de Interés

Edita `lib/app/modules/map/map_controller.dart` líneas 105-143:

```dart
pointsOfInterest.value = [
  const PointOfInterest(
    id: 'mi_poi',
    name: 'Mi Lugar',
    position: LatLng(22.277000, -97.862000),
    type: PoiType.facultad,  // entrada, parada, o facultad
    description: 'Descripción',
  ),
  // ... más POIs
];
```

---

## ⚙️ Ajustar Parámetros del Bus

Edita `lib/app/data/services/bus_tracking_service.dart` líneas 20-23:

```dart
static const double BUS_DETECTION_RADIUS = 8.0;    // metros
static const int MIN_USERS_FOR_BUS = 3;            // usuarios
static const Duration UPDATE_INTERVAL = Duration(seconds: 5);
static const Duration USER_TIMEOUT = Duration(minutes: 2);
```

---

## 📚 Más Información

- 📖 **Documentación completa:** `MAP_MODULE_README.md`
- 🗄️ **SQL de Supabase:** `SUPABASE_SETUP.md`
- ✅ **Resumen del proyecto:** `MODULO_MAPA_RESUMEN.md`

---

## ✅ Checklist de Configuración

Antes de usar en producción:

- [ ] Google Maps API Key configurada
- [ ] API Key restringida por app (recomendado)
- [ ] Tablas de Supabase creadas
- [ ] Realtime habilitado en Supabase
- [ ] Permisos en Android configurados
- [ ] Permisos en iOS configurados
- [ ] Testeado en dispositivos reales
- [ ] Punto central actualizado (si es diferente)
- [ ] POIs personalizados (opcional)

---

## 🆘 Soporte

Si tienes problemas:

1. Revisa la documentación en `MAP_MODULE_README.md`
2. Verifica los logs con `flutter run`
3. Consulta la consola de Supabase
4. Revisa la consola de Google Cloud

---

**¡Listo para empezar! 🎉**

Sigue los 3 pasos arriba y tendrás el mapa funcionando en menos de 15 minutos.
