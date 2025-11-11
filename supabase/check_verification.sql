-- Script de diagnóstico para verificar la tabla verified_users

-- 1. Ver la estructura de la tabla
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'verified_users';

-- 2. Ver todos los registros de verified_users
SELECT * FROM public.verified_users;

-- 3. Ver el UID del usuario actual (ejecuta esto en el SQL Editor con tu sesión activa)
-- SELECT auth.uid();

-- 4. Verificar si un UID específico está verificado (reemplaza 'TU_UID_AQUI' con el UID real)
-- SELECT * FROM public.verified_users WHERE user_id = 'TU_UID_AQUI';
