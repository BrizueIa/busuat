-- ================================================
-- CONFIGURACIÓN DE SEGURIDAD PARA LA TABLA AGENDA
-- ================================================
-- Este script configura Row Level Security (RLS) para la tabla agenda
-- garantizando que cada usuario solo pueda acceder a sus propios datos.

-- Verificar que la tabla existe
SELECT 'Verificando tabla agenda...' as step;

-- ================================================
-- HABILITAR ROW LEVEL SECURITY
-- ================================================
ALTER TABLE public.agenda ENABLE ROW LEVEL SECURITY;

-- ================================================
-- ELIMINAR POLÍTICAS EXISTENTES (si existen)
-- ================================================
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias agendas" ON public.agenda;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propias agendas" ON public.agenda;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propias agendas" ON public.agenda;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias agendas" ON public.agenda;

-- ================================================
-- CREAR POLÍTICAS DE SEGURIDAD
-- ================================================

-- Política SELECT: Los usuarios solo pueden ver sus propios items
CREATE POLICY "Los usuarios pueden ver sus propias agendas"
ON public.agenda
FOR SELECT
USING (auth.uid() = user_id);

-- Política INSERT: Los usuarios solo pueden crear items para sí mismos
CREATE POLICY "Los usuarios pueden insertar sus propias agendas"
ON public.agenda
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Política UPDATE: Los usuarios solo pueden actualizar sus propios items
CREATE POLICY "Los usuarios pueden actualizar sus propias agendas"
ON public.agenda
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Política DELETE: Los usuarios solo pueden eliminar sus propios items
CREATE POLICY "Los usuarios pueden eliminar sus propias agendas"
ON public.agenda
FOR DELETE
USING (auth.uid() = user_id);

-- ================================================
-- AGREGAR COLUMNA user_id SI NO EXISTE
-- ================================================
-- Esto es necesario para vincular cada item con un usuario
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'agenda'
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE public.agenda ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
        ALTER TABLE public.agenda ALTER COLUMN user_id SET DEFAULT auth.uid();
        
        -- Crear índice para mejorar rendimiento
        CREATE INDEX IF NOT EXISTS agenda_user_id_idx ON public.agenda(user_id);
        
        RAISE NOTICE 'Columna user_id agregada exitosamente';
    ELSE
        RAISE NOTICE 'Columna user_id ya existe';
    END IF;
END $$;

-- ================================================
-- FUNCIÓN PARA AUTO-ASIGNAR user_id
-- ================================================
-- Esta función se ejecuta automáticamente antes de insertar un nuevo item
CREATE OR REPLACE FUNCTION public.set_agenda_user_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id := auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger si no existe
DROP TRIGGER IF EXISTS set_agenda_user_id_trigger ON public.agenda;
CREATE TRIGGER set_agenda_user_id_trigger
    BEFORE INSERT ON public.agenda
    FOR EACH ROW
    EXECUTE FUNCTION public.set_agenda_user_id();

-- ================================================
-- VERIFICACIÓN
-- ================================================
SELECT 'Verificando configuración RLS...' as step;

-- Verificar que RLS está habilitado
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'agenda';

-- Listar todas las políticas activas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'agenda';

-- ================================================
-- RESUMEN
-- ================================================
SELECT 
    '✅ Row Level Security configurado correctamente' as status,
    'Los usuarios solo pueden acceder a sus propios items de agenda' as descripcion;

-- ================================================
-- NOTAS DE USO
-- ================================================
/*
1. Para ejecutar este script en Supabase:
   - Ve al SQL Editor en el dashboard de Supabase
   - Copia y pega todo este script
   - Ejecuta el script

2. Después de ejecutar este script:
   - Cada usuario solo verá sus propios items de agenda
   - Los items se vinculan automáticamente al usuario que los crea
   - No es necesario especificar user_id manualmente en la app

3. Para probar:
   - Crea un item de agenda desde la app
   - Verifica en la base de datos que user_id se asignó correctamente
   - Intenta acceder con otro usuario y verifica que no ve items ajenos
*/
