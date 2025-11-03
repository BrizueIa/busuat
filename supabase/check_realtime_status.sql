-- =========================================
-- VERIFICAR ESTADO DE REALTIME
-- =========================================

-- 1. Verificar si la tabla buses está en la publicación de Realtime
SELECT 
  'Publicación Realtime' AS check_type,
  schemaname,
  tablename,
  pubname
FROM 
  pg_publication_tables
WHERE 
  tablename = 'buses'
ORDER BY pubname;

-- 2. Verificar permisos de la tabla buses
SELECT 
  'Permisos' AS check_type,
  grantee,
  privilege_type
FROM 
  information_schema.role_table_grants
WHERE 
  table_name = 'buses'
  AND table_schema = 'public';

-- 3. Verificar políticas RLS (Row Level Security)
SELECT 
  'Políticas RLS' AS check_type,
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

-- 4. Verificar si RLS está habilitado
SELECT 
  'RLS Habilitado' AS check_type,
  tablename,
  rowsecurity AS rls_enabled
FROM 
  pg_tables
WHERE 
  tablename = 'buses'
  AND schemaname = 'public';

-- 5. Ver todas las publicaciones disponibles
SELECT 
  'Publicaciones Disponibles' AS check_type,
  pubname,
  puballtables,
  pubinsert,
  pubupdate,
  pubdelete
FROM 
  pg_publication
ORDER BY pubname;
