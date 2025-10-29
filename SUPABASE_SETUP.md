# Configuración de Supabase para el Módulo de Mapa

Este archivo contiene las instrucciones SQL necesarias para crear las tablas en Supabase que soportan el módulo de mapa del autobús universitario.

## Tablas a crear:

### 1. Tabla `user_locations`
Almacena las ubicaciones de los usuarios que reportan estar en el autobús.

```sql
-- Crear tabla user_locations
CREATE TABLE IF NOT EXISTS public.user_locations (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_in_bus BOOLEAN DEFAULT FALSE,
    accuracy DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_user_locations_timestamp ON public.user_locations(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_user_locations_is_in_bus ON public.user_locations(is_in_bus) WHERE is_in_bus = TRUE;

-- Habilitar Row Level Security (RLS)
ALTER TABLE public.user_locations ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
-- Los usuarios pueden insertar/actualizar su propia ubicación
CREATE POLICY "Users can insert their own location"
    ON public.user_locations
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own location"
    ON public.user_locations
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Todos pueden leer las ubicaciones (para calcular posición del bus)
CREATE POLICY "Anyone can read locations"
    ON public.user_locations
    FOR SELECT
    USING (TRUE);

-- Los usuarios pueden eliminar su propia ubicación
CREATE POLICY "Users can delete their own location"
    ON public.user_locations
    FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_locations_updated_at
    BEFORE UPDATE ON public.user_locations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### 2. Tabla `bus_locations`
Almacena la ubicación calculada del autobús basándose en los usuarios reportados.

```sql
-- Crear tabla bus_locations
CREATE TABLE IF NOT EXISTS public.bus_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_count INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_bus_locations_timestamp ON public.bus_locations(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_bus_locations_is_active ON public.bus_locations(is_active) WHERE is_active = TRUE;

-- Habilitar Row Level Security
ALTER TABLE public.bus_locations ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
-- Todos pueden leer las ubicaciones del bus
CREATE POLICY "Anyone can read bus locations"
    ON public.bus_locations
    FOR SELECT
    USING (TRUE);

-- Solo usuarios autenticados pueden insertar ubicaciones del bus
CREATE POLICY "Authenticated users can insert bus locations"
    ON public.bus_locations
    FOR INSERT
    TO authenticated
    WITH CHECK (TRUE);
```

### 3. Tabla `points_of_interest` (opcional)
Si deseas almacenar los puntos de interés en la base de datos en lugar de tenerlos hardcodeados.

```sql
-- Crear tabla points_of_interest
CREATE TABLE IF NOT EXISTS public.points_of_interest (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'entrada', 'parada', 'facultad'
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_poi_type ON public.points_of_interest(type);
CREATE INDEX IF NOT EXISTS idx_poi_is_active ON public.points_of_interest(is_active) WHERE is_active = TRUE;

-- Habilitar Row Level Security
ALTER TABLE public.points_of_interest ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
-- Todos pueden leer los puntos de interés
CREATE POLICY "Anyone can read POIs"
    ON public.points_of_interest
    FOR SELECT
    USING (TRUE);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_poi_updated_at
    BEFORE UPDATE ON public.points_of_interest
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insertar datos de ejemplo
INSERT INTO public.points_of_interest (name, latitude, longitude, type, description) VALUES
    ('Entrada Principal', 22.277500, -97.862500, 'entrada', 'Entrada principal del campus'),
    ('Entrada Norte', 22.278500, -97.862000, 'entrada', 'Entrada norte'),
    ('Parada Central', 22.277125, -97.862299, 'parada', 'Parada central del autobús'),
    ('Parada Facultades', 22.276800, -97.862500, 'parada', 'Parada cerca de las facultades'),
    ('Facultad de Ingeniería', 22.276500, -97.861800, 'facultad', 'Facultad de Ingeniería'),
    ('Facultad de Medicina', 22.277800, -97.863000, 'facultad', 'Facultad de Medicina');
```

### 4. Función para limpiar ubicaciones antiguas (opcional)
Esta función puede ejecutarse periódicamente para eliminar ubicaciones antiguas.

```sql
-- Función para limpiar ubicaciones antiguas
CREATE OR REPLACE FUNCTION clean_old_locations()
RETURNS void AS $$
BEGIN
    -- Eliminar ubicaciones de usuarios con más de 2 minutos
    DELETE FROM public.user_locations
    WHERE timestamp < NOW() - INTERVAL '2 minutes';
    
    -- Desactivar ubicaciones de bus con más de 2 minutos
    UPDATE public.bus_locations
    SET is_active = FALSE
    WHERE timestamp < NOW() - INTERVAL '2 minutes' AND is_active = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 5. Configurar Realtime (importante para actualizaciones en tiempo real)

En el dashboard de Supabase, ve a **Database > Replication** y habilita Realtime para las tablas:
- `user_locations`
- `bus_locations`
- `points_of_interest` (si la usas)

O ejecuta estos comandos SQL:

```sql
-- Habilitar realtime para las tablas
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.bus_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.points_of_interest;
```

## Notas importantes:

1. **Seguridad**: Las políticas RLS están configuradas para que los usuarios solo puedan modificar su propia ubicación, pero todos pueden leer las ubicaciones (necesario para calcular la posición del bus).

2. **Rendimiento**: Los índices están optimizados para consultas frecuentes como buscar ubicaciones recientes y activas.

3. **Limpieza automática**: Considera configurar un cron job de Supabase o un Edge Function para ejecutar `clean_old_locations()` periódicamente.

4. **Realtime**: Es crucial habilitar Realtime para que las actualizaciones se reflejen inmediatamente en todos los dispositivos.

5. **Privacidad**: Las ubicaciones de usuarios individuales son visibles para calcular el bus, pero en producción podrías considerar agregar más capas de privacidad.
