-- =====================================================
-- Configuración de Row Level Security (RLS)
-- para las tablas de Agenda y Horario
-- =====================================================

-- Habilitar RLS en las tablas
ALTER TABLE public.agenda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA LA TABLA AGENDA
-- =====================================================

-- La tabla agenda ahora tiene user_id, por lo que las políticas son específicas por usuario

-- Política de SELECT: Los usuarios solo pueden ver sus propios items de agenda
CREATE POLICY "Usuarios pueden ver su propia agenda"
ON public.agenda
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Política de INSERT: Los usuarios solo pueden crear sus propios items de agenda
CREATE POLICY "Usuarios pueden crear su propia agenda"
ON public.agenda
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Política de UPDATE: Los usuarios solo pueden actualizar sus propios items de agenda
CREATE POLICY "Usuarios pueden actualizar su propia agenda"
ON public.agenda
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Política de DELETE: Los usuarios solo pueden eliminar sus propios items de agenda
CREATE POLICY "Usuarios pueden eliminar su propia agenda"
ON public.agenda
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- =====================================================
-- POLÍTICAS PARA LA TABLA SCHEDULE
-- =====================================================

-- La tabla schedule tiene user_id, por lo que las políticas son específicas por usuario

-- Política de SELECT: Los usuarios solo pueden ver sus propios horarios
CREATE POLICY "Usuarios pueden ver su propio horario"
ON public.schedule
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Política de INSERT: Los usuarios solo pueden crear sus propios horarios
CREATE POLICY "Usuarios pueden crear su propio horario"
ON public.schedule
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Política de UPDATE: Los usuarios solo pueden actualizar sus propios horarios
CREATE POLICY "Usuarios pueden actualizar su propio horario"
ON public.schedule
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Política de DELETE: Los usuarios solo pueden eliminar sus propios horarios
CREATE POLICY "Usuarios pueden eliminar su propio horario"
ON public.schedule
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- =====================================================
-- VERIFICACIÓN DE POLÍTICAS
-- =====================================================

-- Para verificar que las políticas se crearon correctamente:
-- SELECT schemaname, tablename, policyname, roles, cmd, qual, with_check
-- FROM pg_policies
-- WHERE schemaname = 'public' AND tablename IN ('agenda', 'schedule');

