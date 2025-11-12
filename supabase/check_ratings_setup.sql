-- Verificar que la función get_post_average_rating existe y funciona correctamente

-- 1. Ver la definición de la función
SELECT 
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'get_post_average_rating';

-- 2. Probar la función con un post existente (reemplaza 1 con un ID real de tu tabla posts)
-- SELECT public.get_post_average_rating(1);

-- 3. Ver todos los ratings de la tabla posts_ratings
SELECT * FROM public.posts_ratings ORDER BY created_at DESC LIMIT 10;

-- 4. Ver la distribución de ratings por post
SELECT 
    post_id,
    COUNT(*) as total_ratings,
    AVG(rating)::numeric(10,2) as average_rating,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating
FROM public.posts_ratings
GROUP BY post_id
ORDER BY total_ratings DESC;

-- 5. Si la función no existe, créala:
/*
CREATE OR REPLACE FUNCTION public.get_post_average_rating(
  given_post_id int
) RETURNS float
LANGUAGE sql
AS $$
  SELECT COALESCE(AVG(COALESCE(rating, 0)), 0) FROM public.posts_ratings WHERE post_id = given_post_id
$$;
*/

-- 6. Asegúrate de que RLS esté configurado correctamente para posts_ratings
-- Ver políticas actuales
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'posts_ratings';

-- 7. Si necesitas crear políticas RLS básicas:
/*
-- Permitir que usuarios autenticados lean todos los ratings
DROP POLICY IF EXISTS "Anyone can read ratings" ON public.posts_ratings;
CREATE POLICY "Anyone can read ratings"
  ON public.posts_ratings
  FOR SELECT
  USING (true);

-- Permitir que usuarios autenticados creen ratings
DROP POLICY IF EXISTS "Authenticated users can create ratings" ON public.posts_ratings;
CREATE POLICY "Authenticated users can create ratings"
  ON public.posts_ratings
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Permitir que usuarios actualicen sus propios ratings (necesitarías agregar user_id a la tabla)
-- DROP POLICY IF EXISTS "Users can update their own ratings" ON public.posts_ratings;
-- CREATE POLICY "Users can update their own ratings"
--   ON public.posts_ratings
--   FOR UPDATE
--   TO authenticated
--   USING (auth.uid() = user_id)
--   WITH CHECK (auth.uid() = user_id);
*/
