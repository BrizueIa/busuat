# 🗺️ Módulo de Mapa - BusUAT

## 🚌 Sistema de Tracking del Autobús Universitario

Sistema completo de visualización y tracking en tiempo real del autobús universitario, implementado con Flutter, Google Maps y Supabase.

---

## 🎯 ¿Qué hace este módulo?

- ✅ Muestra un mapa interactivo del campus universitario
- ✅ Permite a los usuarios reportar que están en el autobús
- ✅ Detecta automáticamente la ubicación del bus cuando 3+ usuarios están cerca
- ✅ Muestra puntos de interés: entradas, paradas y facultades
- ✅ Sincroniza ubicaciones en tiempo real entre todos los usuarios
- ✅ Respeta la privacidad con ubicación personal opcional

---

## 📚 Documentación

### 🚀 Para Empezar

| Documento | Descripción | Tiempo |
|-----------|-------------|---------|
| **[INICIO_RAPIDO.md](INICIO_RAPIDO.md)** | ⭐ **¡Empieza aquí!** Guía rápida de configuración en 3 pasos | 15 min |

### 📖 Documentación Técnica

| Documento | Descripción | Público |
|-----------|-------------|---------|
| **[MAP_MODULE_README.md](MAP_MODULE_README.md)** | Documentación completa del módulo | Desarrolladores |
| **[SUPABASE_SETUP.md](SUPABASE_SETUP.md)** | Scripts SQL y configuración de base de datos | DevOps/Backend |
| **[RESUMEN_EJECUTIVO.md](RESUMEN_EJECUTIVO.md)** | Métricas, arquitectura y estado del proyecto | Project Managers |
| **[MODULO_MAPA_RESUMEN.md](MODULO_MAPA_RESUMEN.md)** | Resumen de implementación y archivos creados | Todo el equipo |

---

## ⚡ Quick Start (3 pasos)

### 1️⃣ Google Maps API Key

```bash
# Obtén tu API key en: https://console.cloud.google.com/
# Actualiza estos archivos:
# - .env
# - android/app/src/main/AndroidManifest.xml
# - ios/Runner/AppDelegate.swift
```

### 2️⃣ Supabase Database

```bash
# Ejecuta el SQL de SUPABASE_SETUP.md en tu proyecto de Supabase
# Habilita Realtime para las tablas
```

### 3️⃣ Ejecutar

```bash
flutter run
```

**📖 Instrucciones detalladas en:** [INICIO_RAPIDO.md](INICIO_RAPIDO.md)

---

## 🏗️ Arquitectura

```
┌─────────────────────┐
│   MapPage (UI)      │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  MapController      │  ← Estado con GetX
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  LocationService    │  ← GPS
│  BusTrackingService │  ← Lógica del bus
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│    Supabase         │  ← Realtime DB
└─────────────────────┘
```

---

## ✨ Características

### ✅ Implementado

- [x] Mapa interactivo con Google Maps
- [x] Botón "Estoy en el bus" con estado visual
- [x] Detección automática del bus (3+ usuarios, radio 8m)
- [x] Marcadores de puntos de interés (entradas, paradas, facultades)
- [x] Ubicación personal del usuario
- [x] Sincronización en tiempo real vía Supabase
- [x] Gestión de permisos de ubicación
- [x] Controles para mostrar/ocultar elementos
- [x] Centrado automático en campus/bus
- [x] Información en tiempo real del bus

### 🔮 Futuras Mejoras

- [ ] Íconos personalizados para marcadores
- [ ] Notificaciones push
- [ ] Múltiples autobuses
- [ ] Historial de rutas
- [ ] Estimación de tiempos de llegada

---

## 📦 Stack Tecnológico

| Tecnología | Versión | Uso |
|------------|---------|-----|
| Flutter | 3.9.2 | Framework |
| GetX | 4.6.6 | State Management |
| Google Maps | 2.9.0 | Mapas |
| Geolocator | 13.0.2 | GPS |
| Supabase | 2.9.1 | Backend |

---

## 📁 Estructura del Proyecto

```
lib/app/
├── core/
│   └── services/
│       └── location_service.dart       # Servicio de GPS
├── data/
│   ├── models/
│   │   ├── bus_location.dart          # Modelo del bus
│   │   ├── point_of_interest.dart     # Modelo de POI
│   │   ├── poi_type.dart              # Tipos de POI
│   │   └── user_location.dart         # Modelo de usuario
│   └── services/
│       └── bus_tracking_service.dart   # Lógica del bus
└── modules/
    └── map/
        ├── map_binding.dart            # Binding GetX
        ├── map_controller.dart         # Controlador
        └── map_page.dart               # Vista

Documentación:
├── INICIO_RAPIDO.md                    # ⭐ Start here
├── MAP_MODULE_README.md                # Docs técnicas
├── SUPABASE_SETUP.md                   # SQL scripts
├── RESUMEN_EJECUTIVO.md                # Overview
└── MODULO_MAPA_RESUMEN.md             # Resumen de código
```

---

## 🎮 Cómo Usar

### Desde la App:

1. Abre la app BusUAT
2. Ve a la pestaña **"Mapa"** en la navegación inferior
3. Presiona **"Ver Mapa"**
4. ¡Explora el campus!

### Funciones Disponibles:

| Botón | Función |
|-------|---------|
| 🏠 Casa | Centra el mapa en el campus |
| 🚌 Bus | Centra en el autobús (si está activo) |
| 👁️ Marcadores | Muestra/oculta puntos de interés |
| 📍 Mi ubicación | Activa/desactiva tu marcador |
| 🚌 Estoy en el bus | Reporta tu ubicación |

---

## 🎯 Criterios de Aceptación

| # | Criterio | ✅ |
|---|----------|---|
| 1 | Mapa fijo de la universidad | ✅ |
| 2 | Botón "Estoy en el bus" funcional | ✅ |
| 3 | Detección condicional del bus (3+ usuarios, 8m) | ✅ |
| 4 | Marcadores fijos configurables | ✅ |
| 5 | Visualización de ubicación personal | ✅ |

**Cumplimiento:** 100% ✅

---

## ⚙️ Configuración

### Punto Central del Campus

```dart
// lib/app/modules/map/map_controller.dart
static const CENTRAL_POINT = LatLng(22.277125, -97.862299);
```

### Parámetros del Bus

```dart
// lib/app/data/services/bus_tracking_service.dart
static const double BUS_DETECTION_RADIUS = 8.0;     // metros
static const int MIN_USERS_FOR_BUS = 3;             // usuarios mínimos
static const Duration UPDATE_INTERVAL = Duration(seconds: 5);
```

### Puntos de Interés

Edita `lib/app/modules/map/map_controller.dart` líneas 105-143 para personalizar los POIs.

---

## 🐛 Troubleshooting

| Problema | Solución |
|----------|----------|
| El mapa no se muestra | Verifica la API Key de Google Maps |
| No solicita permisos | Reinstala la app |
| El bus no aparece | Necesitas 3+ usuarios reportando |
| Errores de Supabase | Verifica que las tablas existan |

**📖 Más en:** [INICIO_RAPIDO.md](INICIO_RAPIDO.md) sección "Solución de Problemas"

---

## 📊 Estado del Proyecto

| Métrica | Valor |
|---------|-------|
| Estado | ✅ Completado |
| Archivos creados | 13 |
| Líneas de código | ~1,800 |
| Cobertura de criterios | 100% |
| Documentación | 4 archivos |
| Testing | Pendiente |

---

## 🔐 Seguridad

- ✅ Row Level Security (RLS) en Supabase
- ✅ Validación de permisos
- ✅ Timeout automático de datos
- ✅ Autenticación requerida

---

## 📱 Plataformas Soportadas

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- 🔄 Web (compatible, requiere testing)

---

## 💡 Ejemplos de Uso

### Navegar al mapa desde código:

```dart
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

// Abrir el mapa
Get.toNamed(Routes.MAP);
```

### Agregar un nuevo POI:

```dart
const PointOfInterest(
  id: 'biblioteca',
  name: 'Biblioteca Central',
  position: LatLng(22.277000, -97.862000),
  type: PoiType.facultad,
  description: 'Biblioteca principal',
)
```

---

## 🤝 Contribuir

### Áreas de mejora:

1. **UI/UX**
   - Íconos personalizados
   - Animaciones
   - Temas oscuro/claro

2. **Funcionalidad**
   - Múltiples autobuses
   - Notificaciones
   - Horarios

3. **Testing**
   - Unit tests
   - Widget tests
   - Integration tests

---

## 📞 Soporte

### Documentación:

- 📖 [Guía Rápida](INICIO_RAPIDO.md)
- 📖 [Docs Completas](MAP_MODULE_README.md)
- 📖 [Setup de BD](SUPABASE_SETUP.md)

### Links Útiles:

- [Google Maps Flutter Docs](https://pub.dev/packages/google_maps_flutter)
- [Geolocator Docs](https://pub.dev/packages/geolocator)
- [Supabase Flutter Docs](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [GetX Docs](https://pub.dev/packages/get)

---

## 📄 Licencia

Parte del proyecto BusUAT - Universidad Autónoma de Tamaulipas

---

## 🎉 ¡Gracias!

Este módulo fue desarrollado con ❤️ para mejorar la experiencia de movilidad en el campus universitario.

**¿Listo para empezar?** → [INICIO_RAPIDO.md](INICIO_RAPIDO.md)

---

**Última actualización:** 21 de Octubre, 2025
**Versión:** 1.0.0
**Estado:** ✅ Producción Ready (requiere configuración)
