# Pasos para Activar la Funcionalidad "Estoy en el Bus"

## ✅ Lo que ya está hecho:

1. ✅ Credenciales de Supabase configuradas en `.env`
2. ✅ Código de MapController actualizado con funcionalidad en tiempo real
3. ✅ Interfaz del botón "Estoy en el bus" conectada
4. ✅ Widget de información del bus implementado
5. ✅ Suscripción a ubicación del bus en tiempo real activada

## 📋 Pasos pendientes:

### 1. Crear las tablas en Supabase

Necesitas ejecutar el SQL que está en el archivo `SUPABASE_SETUP.md` en tu proyecto de Supabase:

1. Ve a tu proyecto de Supabase: https://tzvyirisalzyaapkbwyw.supabase.co
2. Ve a **SQL Editor** en el menú lateral
3. Crea una nueva query
4. Copia y pega el SQL del archivo `SUPABASE_SETUP.md` (todas las secciones)
5. Ejecuta el SQL

Las tablas que se crearán son:
- `user_locations` - Para almacenar las ubicaciones de usuarios en el bus
- `bus_locations` - Para almacenar la ubicación calculada del bus
- `points_of_interest` - Para los puntos de interés (opcional)

### 2. Habilitar Realtime en Supabase

**MUY IMPORTANTE**: Debes habilitar Realtime para las tablas:

1. Ve a **Database > Replication** en Supabase
2. Busca la tabla `user_locations` y marca el checkbox de "Enable Realtime"
3. Busca la tabla `bus_locations` y marca el checkbox de "Enable Realtime"

O ejecuta este SQL:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.bus_locations;
```

### 3. Configurar autenticación (si es necesario)

El código actual intenta obtener el usuario autenticado de Supabase:
```dart
final userId = _supabase.auth.currentUser?.id;
```

Tienes dos opciones:

**Opción A: Autenticación anónima (más simple para pruebas)**
```dart
// En main.dart o al iniciar la app
await Supabase.instance.client.auth.signInAnonymously();
```

**Opción B: Implementar autenticación completa**
- Configurar Supabase Auth con email/password o proveedores sociales
- Crear pantalla de login
- Guardar sesión del usuario

### 4. Probar la funcionalidad

1. **Ejecuta la app**: 
   ```bash
   flutter run
   ```

2. **Verifica permisos de ubicación**: 
   - La app solicitará permisos de ubicación
   - Acepta los permisos

3. **Activa "Estoy en el bus"**:
   - Toca el switch "Estoy en el bus"
   - Deberías ver el mensaje "Estás reportando tu ubicación en el autobús"

4. **Verifica en Supabase**:
   - Ve a **Table Editor** en Supabase
   - Abre la tabla `user_locations`
   - Deberías ver tu ubicación reportándose

5. **Prueba con múltiples usuarios**:
   - Necesitas al menos 3 usuarios reportando ubicación para que aparezca el marcador del bus
   - Puedes usar múltiples dispositivos o emuladores

## 🔍 Troubleshooting

### Error: "No se pudo identificar el usuario"
- Necesitas implementar autenticación en Supabase
- Prueba con autenticación anónima primero (ver Opción A arriba)

### No aparece el marcador del bus
- Asegúrate de tener al menos 3 usuarios reportando ubicación
- Verifica que Realtime esté habilitado en las tablas
- Revisa la consola de Flutter para errores

### Errores de permisos en Supabase
- Verifica que las políticas RLS estén creadas correctamente
- Asegúrate de que las tablas tengan RLS habilitado

## 📱 Cómo funciona:

1. **Usuario activa el switch**: 
   - Se obtiene la ubicación actual
   - Se reporta a Supabase en `user_locations`
   - Se inicia un stream que actualiza la ubicación cada vez que el usuario se mueve

2. **Cálculo de ubicación del bus**:
   - Cada 5 segundos se calculan clusters de usuarios cercanos
   - Si hay 3+ usuarios dentro de 8 metros, se considera que están en el bus
   - Se calcula el centroide de ese cluster
   - Se guarda en `bus_locations`

3. **Visualización en tiempo real**:
   - Todos los usuarios suscritos escuchan cambios en `bus_locations`
   - El marcador del bus se actualiza automáticamente en el mapa
   - Se muestra la tarjeta de información con el número de usuarios

## 🎯 Próximos pasos recomendados:

1. Implementar autenticación de usuarios
2. Agregar iconos personalizados para el marcador del bus
3. Agregar funcionalidad para centrar el mapa en el bus
4. Implementar notificaciones cuando el bus esté cerca
5. Agregar historial de rutas del bus
