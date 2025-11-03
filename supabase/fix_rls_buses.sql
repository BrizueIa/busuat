-- =========================================
-- FIX: Crear política RLS para tabla buses
-- =========================================
-- RLS está habilitado pero sin políticas, bloqueando Realtime
-- Esta política permite que TODOS puedan leer la tabla buses

-- 1. Crear política para permitir SELECT (lectura) a todos
CREATE POLICY "Enable read access for all users" 
ON public.buses 
FOR SELECT 
USING (true);

-- 2. Verificar que la política se creó correctamente
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

-- 3. Verificar que RLS sigue habilitado
SELECT 
  tablename,
  rowsecurity AS rls_enabled
FROM 
  pg_tables
WHERE 
  tablename = 'buses'
  AND schemaname = 'public';
