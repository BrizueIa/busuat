-- =========================================
-- HABILITAR REALTIME EN TABLA BUSES
-- =========================================
-- Este script habilita Realtime en la tabla buses
-- para que los cambios se transmitan automáticamente

-- 1. Agregar la tabla buses a la publicación de Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE buses;

-- 2. Verificar que se agregó correctamente
SELECT 
  schemaname,
  tablename,
  pubname
FROM 
  pg_publication_tables
WHERE 
  tablename = 'buses';

-- 3. Otorgar permisos de SELECT para usuarios anónimos (Realtime)
-- Esto permite que los clientes lean los cambios en tiempo real
GRANT SELECT ON buses TO anon;
GRANT SELECT ON buses TO authenticated;

-- 4. Crear política RLS para permitir lectura de buses
-- Si aún no existe una política, créala
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'buses' 
    AND policyname = 'Enable read access for all users'
  ) THEN
    CREATE POLICY "Enable read access for all users" 
    ON buses 
    FOR SELECT 
    USING (true);
  END IF;
END $$;

-- 5. Verificar las políticas existentes
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM 
  pg_policies
WHERE 
  tablename = 'buses';

-- 6. Mostrar estado final
SELECT 
  'Realtime habilitado en tabla buses' AS status,
  COUNT(*) AS policies_count
FROM 
  pg_policies
WHERE 
  tablename = 'buses';
