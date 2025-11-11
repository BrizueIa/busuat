-- Desactivar RLS temporalmente para verificar (SOLO PARA DESARROLLO)
-- Opción 1: Desactivar RLS completamente (más simple, menos seguro)
ALTER TABLE public.verified_users DISABLE ROW LEVEL SECURITY;

-- Opción 2: Crear políticas RLS adecuadas (recomendado para producción)
-- Primero asegúrate de que RLS esté activado
-- ALTER TABLE public.verified_users ENABLE ROW LEVEL SECURITY;

-- Política para permitir que los usuarios lean su propio estado de verificación
-- DROP POLICY IF EXISTS "Users can read their own verification status" ON public.verified_users;
-- CREATE POLICY "Users can read their own verification status"
--   ON public.verified_users
--   FOR SELECT
--   USING (auth.uid() = user_id);

-- Política para permitir que usuarios autenticados lean cualquier verificación
-- (necesario si quieres que otros vean si un vendedor está verificado)
-- DROP POLICY IF EXISTS "Authenticated users can read verifications" ON public.verified_users;
-- CREATE POLICY "Authenticated users can read verifications"
--   ON public.verified_users
--   FOR SELECT
--   TO authenticated
--   USING (true);

-- Política para insertar solo por admin (o service role)
-- DROP POLICY IF EXISTS "Only admins can insert verifications" ON public.verified_users;
-- CREATE POLICY "Only admins can insert verifications"
--   ON public.verified_users
--   FOR INSERT
--   TO authenticated
--   WITH CHECK (false); -- Solo service_role puede insertar desde el dashboard
