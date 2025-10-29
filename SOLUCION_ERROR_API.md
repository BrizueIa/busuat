# Solución al Error: ApiTargetBlockedMapError

## 🔴 Error

```
Google Maps JavaScript API error: ApiTargetBlockedMapError
```

Este error ocurre cuando tu API key de Google Maps tiene **restricciones de dominio** configuradas que bloquean el acceso desde `localhost`.

## ✅ Solución

### Opción 1: Permitir localhost en la API key existente (Recomendado para desarrollo)

1. **Ve a Google Cloud Console**:
   - https://console.cloud.google.com/

2. **Navega a APIs & Services > Credentials**:
   - En el menú lateral: APIs y servicios > Credenciales

3. **Encuentra tu API key**:
   - Busca la API key que estás usando: `AIzaSyBEvUjbuOEHTJABF3_pBvg5h72UUMvtBYw`
   - Haz clic en ella para editarla

4. **Configura las restricciones de aplicación**:
   - Ve a la sección "Application restrictions" (Restricciones de aplicación)
   - Selecciona **"HTTP referrers (web sites)"**
   - Agrega los siguientes referrers:
     ```
     http://localhost:*
     https://localhost:*
     http://127.0.0.1:*
     https://127.0.0.1:*
     ```
   - Si ya tienes otros dominios configurados, **NO los borres**, solo agrega estos

5. **Guarda los cambios**:
   - Haz clic en "Save" (Guardar)
   - Espera 1-2 minutos para que los cambios se propaguen

6. **Recarga la aplicación**:
   - En el navegador, presiona `Ctrl + Shift + R` (o `Cmd + Shift + R` en Mac) para hacer hard reload
   - O detén la app (`q` en la terminal) y vuelve a ejecutar `flutter run -d chrome`

### Opción 2: Crear una API key separada para desarrollo

Si prefieres mantener tu API key de producción con restricciones estrictas:

1. **Crea una nueva API key** en Google Cloud Console
2. **Nómbrala**: "Google Maps - Desarrollo Local"
3. **Configura restricciones**:
   - HTTP referrers: `http://localhost:*` y `https://localhost:*`
4. **Usa esta key en desarrollo**:
   - Reemplaza la key en `web/index.html` con esta nueva
5. **Para producción**:
   - Usa el script `build-web.fish` con la API key de producción

### Opción 3: Remover temporalmente las restricciones (NO recomendado)

⚠️ **Solo para pruebas rápidas, NUNCA en producción**:

1. En la configuración de tu API key
2. Selecciona **"None"** en Application restrictions
3. Guarda
4. **IMPORTANTE**: Vuelve a poner restricciones después de probar

## 🔧 Bonus: Arreglar el Warning de Performance

Para eliminar el warning sobre `loading=async`, actualiza el script en `web/index.html`:

### Antes:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=TU_API_KEY"></script>
```

### Después:
```html
<script async src="https://maps.googleapis.com/maps/api/js?key=TU_API_KEY&loading=async"></script>
```

## 📋 Checklist de Verificación

- [ ] API key configurada con referrers de localhost
- [ ] Esperé 1-2 minutos después de guardar cambios
- [ ] Hice hard reload en el navegador (Ctrl + Shift + R)
- [ ] La consola ya no muestra `ApiTargetBlockedMapError`
- [ ] El mapa se muestra correctamente

## 🔐 Configuración Recomendada para Producción

Cuando despliegues a producción:

1. **Crea una API key separada** para cada ambiente:
   - `Google Maps - Development` → localhost
   - `Google Maps - Production` → tu-dominio.com

2. **Configura restricciones estrictas**:
   ```
   Development:
   - http://localhost:*
   - https://localhost:*
   
   Production:
   - https://tudominio.com/*
   - https://www.tudominio.com/*
   ```

3. **Restringe las APIs habilitadas**:
   - Solo habilita: Maps JavaScript API
   - Desactiva las que no uses

4. **Configura cuotas**:
   - Establece límites de uso diario
   - Configura alertas de facturación

## 🐛 Si Sigue Sin Funcionar

1. **Verifica que Maps JavaScript API esté habilitada**:
   - APIs & Services > Library
   - Busca "Maps JavaScript API"
   - Debe estar "Enabled"

2. **Revisa la consola del navegador**:
   - Abre DevTools (F12)
   - Ve a la pestaña Console
   - Busca otros errores relacionados con Google Maps

3. **Verifica el billing**:
   - Asegúrate de que tu proyecto tenga facturación habilitada
   - Google Maps requiere una cuenta de facturación activa

4. **Prueba con una API key nueva**:
   - Crea una API key completamente nueva
   - Sin restricciones temporalmente
   - Si funciona, el problema era la configuración de la key original

---

**Última actualización**: Octubre 2025
