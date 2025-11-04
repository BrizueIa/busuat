# ✅ Verificar y Actualizar Tabla `buses`

## 🔍 Problema Detectado

La Edge Function ahora devuelve las coordenadas del bus **directamente en la respuesta**, pero también intenta guardar `user_count` en la tabla `buses`.

---

## 📋 SQL para Verificar/Actualizar la Tabla

Ve a **Supabase Dashboard → SQL Editor** y ejecuta:

```sql
-- 1️⃣ Verificar estructura actual de la tabla buses
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'buses'
ORDER BY ordinal_position;
```

---

## 🔧 Si falta la columna `user_count`, agrégala:

```sql
-- 2️⃣ Agregar columna user_count si no existe
ALTER TABLE buses
ADD COLUMN IF NOT EXISTS user_count INTEGER DEFAULT 0;
```

---

## ✅ Habilitar Realtime en la tabla `buses`

**IMPORTANTE:** El error `RealtimeSubscribeException(channelError)` indica que Realtime **NO está habilitado** en la tabla `buses`.

### Pasos en Supabase Dashboard:

1. **Database → Replication**
2. Busca la tabla **`buses`**
3. **Activa el toggle** para habilitar Realtime
4. Click en **Save**

---

## 🧪 Verificar que Realtime esté funcionando

Después de habilitar Realtime, ejecuta en SQL Editor:

```sql
-- Verificar que Realtime esté habilitado
SELECT * FROM pg_publication_tables
WHERE tablename = 'buses';
```

Debe retornar **al menos 1 fila** indicando que la tabla está en la publicación de Realtime.

---

## 📊 Estructura Completa Recomendada

Si necesitas recrear la tabla desde cero:

```sql
-- Crear tabla buses (solo si no existe)
CREATE TABLE IF NOT EXISTS buses (
  id BIGSERIAL PRIMARY KEY,
  bus_number INTEGER UNIQUE NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  user_count INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_buses_number ON buses(bus_number);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para updated_at
DROP TRIGGER IF EXISTS update_buses_updated_at ON buses;
CREATE TRIGGER update_buses_updated_at
BEFORE UPDATE ON buses
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Habilitar RLS (Row Level Security)
ALTER TABLE buses ENABLE ROW LEVEL SECURITY;

-- Policy para permitir lectura a todos
DROP POLICY IF EXISTS "Permitir lectura pública de buses" ON buses;
CREATE POLICY "Permitir lectura pública de buses"
ON buses FOR SELECT
TO public
USING (true);

-- Policy para permitir escritura solo al Service Role
DROP POLICY IF EXISTS "Permitir escritura a service_role" ON buses;
CREATE POLICY "Permitir escritura a service_role"
ON buses FOR ALL
TO service_role
USING (true)
WITH CHECK (true);
```

---

## 🎯 Siguiente Paso

Después de:
1. ✅ Agregar columna `user_count` (si falta)
2. ✅ Habilitar Realtime en la tabla `buses`
3. ✅ Desplegar la Edge Function actualizada:

```bash
supabase functions deploy user-location-change
```

El mapa debería:
- ✅ Dibujar el marcador del bus en la posición correcta
- ✅ Mostrar el `user_count` en el InfoCard
- ✅ No más errores de `channelError` en Realtime
