# Configuración del Mapa para Web y Android

## 📱 Resumen

El mapa ahora funciona tanto en **Android** como en **Web** sin conflictos entre plataformas.

## 🔧 Cambios Realizados

### 1. Dependencias Actualizadas

Se agregó `google_maps_flutter_web` en `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.9.0
  google_maps_flutter_web: ^0.5.10
```

### 2. Widget Multiplataforma

Se creó `PlatformMapWidget` en `lib/app/modules/map/widgets/platform_map_widget.dart` que:
- Usa `google_maps_flutter` para Android/iOS
- Usa `google_maps_flutter_web` para navegadores web
- Detecta automáticamente la plataforma con `kIsWeb`
- Desactiva `myLocationEnabled` en web para evitar problemas de permisos del navegador

### 3. Vista Actualizada

`guest_map_view.dart` ahora usa `PlatformMapWidget` en lugar de `GoogleMap` directamente.

### 4. Configuración Web

El archivo `web/index.html` incluye el script de Google Maps API.

## 🚀 Cómo Usar

### Para Android

Funciona exactamente igual que antes. Simplemente ejecuta:

```bash
flutter run
```

### Para Web

**IMPORTANTE**: Debes configurar tu API key de Google Maps primero.

#### Paso 1: Obtener API Key

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un proyecto o selecciona uno existente
3. Habilita "Maps JavaScript API"
4. Crea credenciales → API Key
5. Configura restricciones (opcional pero recomendado):
   - Restricciones de aplicación: HTTP referrers
   - Agrega tu dominio (ej: `localhost:*` para desarrollo)

#### Paso 2: Configurar la API Key

Abre `web/index.html` y reemplaza `TU_API_KEY` con tu API key real:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=TU_API_KEY_AQUI"></script>
```

#### Paso 3: Ejecutar en Web

```bash
flutter run -d chrome
```

O para compilar para producción:

```bash
flutter build web
```

## ⚠️ Diferencias entre Plataformas

### Android
- ✅ `myLocationEnabled` funciona (muestra punto azul del usuario)
- ✅ Todos los gestos funcionan correctamente
- ✅ Mejor rendimiento

### Web
- ⚠️ `myLocationEnabled` está desactivado (puede requerir permisos del navegador)
- ✅ Marcadores funcionan igual
- ✅ Restricciones de cámara funcionan
- ⚠️ Puede tener rendimiento ligeramente inferior

## 🔐 Seguridad de la API Key

### Desarrollo
Para desarrollo local, puedes usar la API key directamente en `index.html`.

### Producción
**IMPORTANTE**: Para producción, debes:

1. **Restringir la API key** en Google Cloud Console:
   - Solo dominios permitidos
   - Solo APIs necesarias habilitadas

2. **Variables de entorno** (opcional):
   Puedes usar variables de entorno durante el build:
   
   ```bash
   # En tu script de build
   sed -i "s/TU_API_KEY/$GOOGLE_MAPS_API_KEY/" web/index.html
   flutter build web
   ```

3. **Diferentes keys para desarrollo y producción**:
   - Key de desarrollo: con `localhost` permitido
   - Key de producción: solo tu dominio real

## 🧪 Probar

### Android
```bash
flutter run
```

### Web (Chrome)
```bash
flutter run -d chrome
```

### Web (Edge)
```bash
flutter run -d edge
```

### Compilar para producción web
```bash
flutter build web --release
```

## 📝 Notas Adicionales

- El widget `PlatformMapWidget` centraliza toda la lógica del mapa
- Los marcadores y puntos de interés funcionan igual en ambas plataformas
- El estilo del mapa se aplica correctamente en ambas plataformas
- Las restricciones de zoom y límites geográficos funcionan en ambas plataformas

## 🐛 Solución de Problemas

### El mapa no se muestra en web
1. Verifica que hayas configurado la API key correctamente en `web/index.html`
2. Abre la consola del navegador (F12) y busca errores
3. Verifica que "Maps JavaScript API" esté habilitada en Google Cloud Console

### Error de API key inválida
1. Verifica que la API key esté correctamente copiada
2. Asegúrate de que "Maps JavaScript API" esté habilitada
3. Revisa las restricciones de la API key

### El mapa funciona en Android pero no en web
1. La API key de Android es diferente a la de Web
2. Asegúrate de configurar `web/index.html` con una API key válida para JavaScript API

## 🔄 Próximos Pasos

Si quieres agregar más funcionalidades específicas para web:

1. **Geolocalización en web**: Puedes usar el paquete `geolocator_web` que ya viene incluido
2. **Diferentes estilos por plataforma**: Modifica `PlatformMapWidget` para aplicar diferentes estilos
3. **Optimizaciones**: Ajusta el rendimiento según la plataforma

---

**Autor**: Configuración multiplataforma para BusUAT
**Fecha**: Octubre 2025
