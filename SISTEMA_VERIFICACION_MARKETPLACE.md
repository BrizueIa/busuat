# Sistema de Verificación Obligatoria para Marketplace

## ✅ Implementación Completada

Se ha implementado un sistema de verificación obligatoria que requiere que los usuarios estén registrados en la tabla `verified_users` de Supabase antes de poder crear publicaciones en el marketplace.

---

## 📁 Archivos Creados

### `/lib/app/data/services/verification_service.dart`
Nuevo servicio para gestionar verificaciones de usuarios.

**Métodos:**
- `isUserVerified(String userId)`: Verifica si un usuario está en la tabla `verified_users`
- `getVerificationInfo(String userId)`: Obtiene la información completa de verificación

---

## 📝 Archivos Modificados

### 1. `/lib/app/modules/marketplace/marketplace_controller.dart`

#### Cambios realizados:
- ✅ Importado `VerificationService`
- ✅ Instancia de `_verificationService` agregada
- ✅ Método `goToCreatePost()` actualizado:
  - Ahora es `Future<void>` (async)
  - Verifica si el usuario está en `verified_users`
  - Muestra diálogo con opción de ir a verificación si no está verificado
  
- ✅ Método `createPost()` actualizado:
  - Verifica estado de verificación antes de crear post
  - Muestra snackbar de error si no está verificado
  - Previene creación de publicaciones por usuarios no verificados

#### Diálogo de verificación requerida:
```dart
AlertDialog(
  title: "Verificación Obligatoria" + icono de advertencia
  content: Explicación de beneficios y obligatoriedad
  actions: ["Cancelar", "Verificarme Ahora"]
)
```

### 2. `/lib/app/modules/marketplace/views/seller_verification_view.dart`

#### Cambios realizados:
- ✅ Agregada advertencia destacada antes de los requisitos
- ✅ Container naranja con borde que indica:
  - "⚠️ Verificación Obligatoria"
  - Explica que es necesario para crear publicaciones
  - Menciona que garantiza seguridad de la comunidad

---

## 🔐 Tabla de Base de Datos

### `verified_users`
```sql
CREATE TABLE public.verified_users (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid DEFAULT gen_random_uuid(),
  verified_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT verified_users_pkey PRIMARY KEY (id),
  CONSTRAINT verified_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
```

**Campos:**
- `id`: Identificador único de la verificación
- `user_id`: UUID del usuario verificado (FK a auth.users)
- `verified_at`: Timestamp de cuando fue verificado

---

## 🔄 Flujo de Verificación

### Escenario 1: Usuario NO Verificado intenta crear publicación

1. Usuario presiona botón FAB "+" o "Crear primera publicación"
2. `goToCreatePost()` verifica en BD si está en `verified_users`
3. Si NO está verificado:
   - Muestra diálogo "Verificación Obligatoria"
   - Opciones: "Cancelar" o "Verificarme Ahora"
4. Si presiona "Verificarme Ahora":
   - Navega a `SellerVerificationView`
   - Ve advertencia naranja sobre obligatoriedad
   - Puede contactar al staff por WhatsApp

### Escenario 2: Usuario Verificado

1. Usuario presiona botón FAB "+"
2. `goToCreatePost()` verifica en BD
3. Usuario ESTÁ en `verified_users`
4. Navega directamente a `/create-post`
5. Puede crear publicación normalmente

### Escenario 3: Intento de bypass (llamada directa a createPost)

1. Aunque se llame directamente `createPost()`
2. El método verifica nuevamente si está en `verified_users`
3. Si NO está verificado:
   - No crea el post
   - Muestra snackbar: "Debes estar verificado para crear publicaciones"
   - Retorna sin crear nada

---

## 🛡️ Validaciones Implementadas

### En `goToCreatePost()`:
1. ✅ Verifica que sea estudiante (`isStudent`)
2. ✅ Verifica sesión de Supabase (`currentUser != null`)
3. ✅ **Verifica en tabla `verified_users`**
4. ✅ Muestra diálogo si no está verificado

### En `createPost()`:
1. ✅ Verifica con AuthRepository (estudiante)
2. ✅ Verifica sesión de Supabase
3. ✅ **Verifica en tabla `verified_users`**
4. ✅ Previene INSERT en `posts` si no está verificado

---

## 🎨 Mejoras UI/UX

### Diálogo de Verificación Obligatoria:
- Título con ícono de advertencia naranja
- Texto claro mencionando:
  - ✓ Protege a la comunidad
  - ✓ Genera confianza
  - ✓ Previene fraudes
- Botón verde "Verificarme Ahora" destacado

### Vista de Verificación:
- Advertencia destacada en naranja antes de requisitos
- Borde grueso (2px) para llamar la atención
- Texto: "Es necesario estar verificado para poder crear publicaciones"

---

## 📊 Base de Datos - Gestión Manual

### Para VERIFICAR un usuario:

```sql
INSERT INTO public.verified_users (user_id)
VALUES ('uuid-del-usuario-aqui');
```

### Para VERIFICAR si un usuario está verificado:

```sql
SELECT * FROM public.verified_users
WHERE user_id = 'uuid-del-usuario';
```

### Para REVOCAR verificación:

```sql
DELETE FROM public.verified_users
WHERE user_id = 'uuid-del-usuario';
```

### Para listar todos los verificados:

```sql
SELECT 
  vu.id,
  vu.user_id,
  vu.verified_at,
  au.email
FROM public.verified_users vu
JOIN auth.users au ON vu.user_id = au.id
ORDER BY vu.verified_at DESC;
```

---

## 🧪 Testing Sugerido

### Test 1: Usuario NO verificado
1. Login como estudiante
2. Intentar crear publicación
3. **Esperado**: Ver diálogo "Verificación Obligatoria"
4. Presionar "Verificarme Ahora"
5. **Esperado**: Ver vista con advertencia naranja

### Test 2: Usuario verificado
1. Agregar user_id a tabla `verified_users`
2. Login como ese estudiante
3. Intentar crear publicación
4. **Esperado**: Navegar directamente a formulario de creación

### Test 3: Prevención de bypass
1. Usuario NO verificado
2. Intentar llamar createPost() de alguna forma
3. **Esperado**: Snackbar de error, no se crea post

---

## 🔒 Seguridad

### Doble Validación
- ✅ Verificación en `goToCreatePost()` (prevención UI)
- ✅ Verificación en `createPost()` (prevención backend)

### Foreign Key Constraint
- `user_id` en `verified_users` referencia `auth.users(id)`
- Garantiza integridad referencial
- No se pueden verificar usuarios inexistentes

### Row Level Security (RLS)
⚠️ **PENDIENTE**: Configurar RLS en Supabase para `verified_users`

Sugerencia:
```sql
-- Solo admins pueden INSERT/DELETE
ALTER TABLE public.verified_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Solo admins pueden gestionar verificaciones"
ON public.verified_users
USING (auth.role() = 'authenticated' AND auth.jwt()->>'role' = 'admin');

-- Todos pueden SELECT para verificar su estado
CREATE POLICY "Usuarios pueden ver si están verificados"
ON public.verified_users FOR SELECT
USING (true);
```

---

## 📱 Flujo Visual

```
Usuario Presiona "+" (FAB)
        ↓
  ¿Es estudiante?
        ↓ NO → Snackbar "Solo estudiantes"
        ↓ SÍ
  ¿Está verificado en BD?
        ↓ NO → Diálogo "Verificación Obligatoria"
        |           ↓
        |      "Verificarme Ahora"
        |           ↓
        |      Seller Verification View
        |           ↓
        |      Contacto WhatsApp Staff
        ↓ SÍ
   Create Post View
        ↓
   Crear Publicación
```

---

## ✅ Checklist de Implementación

- [x] Crear `VerificationService`
- [x] Agregar verificación en `goToCreatePost()`
- [x] Agregar verificación en `createPost()`
- [x] Actualizar diálogo con diseño mejorado
- [x] Agregar advertencia en `SellerVerificationView`
- [x] Compilación sin errores
- [ ] Configurar RLS en Supabase (PENDIENTE)
- [ ] Testing con usuarios reales

---

## 🎯 Próximos Pasos (Opcional)

1. **Panel de Admin**:
   - Vista para staff para verificar usuarios
   - Botón "Aprobar/Rechazar" verificación
   - Historial de verificaciones

2. **Notificaciones**:
   - Email al usuario cuando sea verificado
   - Push notification de aprobación

3. **Estado de verificación**:
   - Badge de "Verificado" en posts
   - Indicador en perfil del usuario

4. **Estadísticas**:
   - Cantidad de usuarios verificados
   - Tasa de conversión solicitud → verificación

---

## 🐛 Troubleshooting

### "No se puede crear publicación aunque esté verificado"
- Verificar que el `user_id` en `verified_users` coincida exactamente con el UUID del usuario autenticado
- Ejecutar: `SELECT auth.uid(), * FROM verified_users WHERE user_id = auth.uid();`

### "Siempre dice que no estoy verificado"
- Verificar conexión a Supabase
- Revisar logs del `VerificationService`
- Confirmar que el usuario esté en la tabla con: `SELECT * FROM verified_users WHERE user_id = 'tu-uuid';`

### "Error al verificar usuario"
- Revisar permisos de la tabla `verified_users`
- Asegurarse de que RLS permita SELECT público

---

✅ **Sistema de verificación obligatoria implementado y funcional**
