-- ================================================
-- CONFIGURACIÓN DE TABLA POSTS PARA MARKETPLACE
-- ================================================
-- Este script configura la tabla posts y sus políticas RLS
-- Ejecutar en el SQL Editor de Supabase

-- 1. Crear la tabla posts (si no existe)
CREATE TABLE IF NOT EXISTS public.posts (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL DEFAULT gen_random_uuid(),
  title character varying NOT NULL,
  description text NOT NULL,
  price real NOT NULL DEFAULT 0,
  img_link character varying,
  categories text[] NOT NULL DEFAULT '{}',
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- 2. Habilitar Row Level Security
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- 3. Eliminar políticas existentes (si existen)
DROP POLICY IF EXISTS "Posts son visibles para todos" ON public.posts;
DROP POLICY IF EXISTS "Solo estudiantes pueden crear posts" ON public.posts;
DROP POLICY IF EXISTS "Usuarios pueden actualizar sus propios posts" ON public.posts;
DROP POLICY IF EXISTS "Usuarios pueden eliminar sus propios posts" ON public.posts;

-- 4. Crear políticas RLS

-- Permitir lectura a todos los usuarios autenticados (incluidos anónimos)
CREATE POLICY "Posts son visibles para todos"
ON public.posts FOR SELECT
TO authenticated
USING (true);

-- Permitir inserción solo a usuarios NO anónimos (estudiantes)
CREATE POLICY "Solo estudiantes pueden crear posts"
ON public.posts FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id 
  AND auth.jwt()->>'is_anonymous' IS DISTINCT FROM 'true'
);

-- Permitir actualización solo al dueño del post
CREATE POLICY "Usuarios pueden actualizar sus propios posts"
ON public.posts FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Permitir eliminación solo al dueño del post
CREATE POLICY "Usuarios pueden eliminar sus propios posts"
ON public.posts FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- 5. Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON public.posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON public.posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_categories ON public.posts USING GIN(categories);

-- Nota: NO se habilita Realtime ya que la app usa refresh manual

-- ================================================
-- VERIFICACIÓN
-- ================================================

-- Verificar que la tabla existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'posts'
) as tabla_existe;

-- Verificar políticas RLS
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'posts';

-- ================================================
-- DATOS DE PRUEBA (Opcional)
-- ================================================

-- Descomentar para insertar datos de prueba
-- IMPORTANTE: Reemplazar 'TU_USER_ID' con un user_id real de auth.users

/*
INSERT INTO public.posts (user_id, title, description, price, img_link, categories) VALUES
  ('TU_USER_ID', 'iPhone 12 Pro Max', 'En excelente estado, 128GB, color azul pacífico', 15000.00, 'https://picsum.photos/400/400?random=1', ARRAY['Electrónica']),
  ('TU_USER_ID', 'Cálculo Diferencial - Stewart', 'Libro en perfecto estado, 8va edición', 350.00, 'https://picsum.photos/400/400?random=2', ARRAY['Libros']),
  ('TU_USER_ID', 'Bicicleta de Montaña', 'Rodada 29, 21 velocidades, frenos de disco', 3500.00, 'https://picsum.photos/400/400?random=3', ARRAY['Deportes']),
  ('TU_USER_ID', 'Calculadora Científica Casio', 'Modelo FX-991EX, como nueva', 450.00, 'https://picsum.photos/400/400?random=4', ARRAY['Electrónica', 'Otros']),
  ('TU_USER_ID', 'Chamarra Universitaria', 'Talla M, poco uso, color negro', 250.00, 'https://picsum.photos/400/400?random=5', ARRAY['Ropa']);
*/

-- ================================================
-- FUNCIONES ÚTILES
-- ================================================

-- Función para obtener posts de un usuario
CREATE OR REPLACE FUNCTION get_user_posts(p_user_id uuid)
RETURNS TABLE (
  id bigint,
  title varchar,
  description text,
  price real,
  img_link varchar,
  categories text[],
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.title, p.description, p.price, p.img_link, p.categories, p.created_at
  FROM public.posts p
  WHERE p.user_id = p_user_id
  ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para buscar posts por categoría
CREATE OR REPLACE FUNCTION search_posts_by_category(p_category text)
RETURNS TABLE (
  id bigint,
  title varchar,
  description text,
  price real,
  img_link varchar,
  categories text[],
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.title, p.description, p.price, p.img_link, p.categories, p.created_at
  FROM public.posts p
  WHERE p_category = ANY(p.categories)
  ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================
-- LIMPIEZA (Solo si necesitas reiniciar)
-- ================================================

/*
-- ADVERTENCIA: Esto eliminará TODOS los datos de posts
-- Descomentar solo si realmente quieres eliminar todo

DROP TABLE IF EXISTS public.posts CASCADE;
DROP FUNCTION IF EXISTS get_user_posts(uuid);
DROP FUNCTION IF EXISTS search_posts_by_category(text);
*/

-- ================================================
-- FIN DEL SCRIPT
-- ================================================

COMMENT ON TABLE public.posts IS 'Tabla de publicaciones del marketplace';
COMMENT ON COLUMN public.posts.user_id IS 'ID del usuario que creó el post';
COMMENT ON COLUMN public.posts.title IS 'Título de la publicación';
COMMENT ON COLUMN public.posts.description IS 'Descripción detallada del producto';
COMMENT ON COLUMN public.posts.price IS 'Precio del producto en MXN';
COMMENT ON COLUMN public.posts.img_link IS 'URL de la imagen del producto';
COMMENT ON COLUMN public.posts.categories IS 'Array de categorías del producto';
COMMENT ON COLUMN public.posts.created_at IS 'Fecha de creación del post';

-- ✅ Script completado exitosamente
