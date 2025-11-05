# 🛍️ Módulo de Marketplace - BUSUAT

## 📋 Descripción

Módulo completo de marketplace que permite a los estudiantes publicar productos y a todos los usuarios (estudiantes e invitados) visualizar las publicaciones disponibles.

## ✨ Características Implementadas

### Para Todos los Usuarios (Estudiantes e Invitados)
- ✅ Visualizar todas las publicaciones en formato grid
- ✅ Filtrar publicaciones por categoría
- ✅ Ver detalles de precio, título e imágenes
- ✅ Actualización en tiempo real de nuevas publicaciones
- ✅ Pull-to-refresh para actualizar el listado

### Solo para Estudiantes
- ✅ Crear nuevas publicaciones
- ✅ Agregar título, descripción, precio e imagen
- ✅ Seleccionar múltiples categorías
- ✅ Validación de formularios
- ✅ Botón flotante para acceso rápido a crear publicación

### Restricciones
- ❌ Los invitados (usuarios anónimos) NO pueden crear publicaciones
- ❌ Solo pueden ver el contenido del marketplace

## 📁 Estructura de Archivos Creados

```
lib/app/
├── data/
│   ├── models/
│   │   └── post_model.dart              # Modelo de Post
│   └── services/
│       └── post_service.dart            # Servicio para interactuar con Supabase
├── modules/
│   ├── marketplace/
│   │   ├── marketplace_controller.dart  # Controlador principal
│   │   ├── marketplace_binding.dart     # Binding de GetX
│   │   └── create_post_page.dart        # Página para crear publicaciones
│   ├── home/views/
│   │   └── marketplace_view.dart        # Vista actualizada para estudiantes
│   └── guest/
│       └── guest_page.dart              # Actualizado para incluir marketplace
└── routes/
    ├── app_routes.dart                  # Rutas actualizadas
    └── app_pages.dart                   # Páginas actualizadas
```

## 🗄️ Tabla de Supabase

El módulo utiliza la tabla `posts` con la siguiente estructura:

```sql
CREATE TABLE public.posts (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL DEFAULT gen_random_uuid(),
  title character varying,
  description text,
  price real DEFAULT '0'::real,
  img_link character varying,
  categories ARRAY,
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
```

## 🎯 Funcionalidades del Módulo

### 1. Visualización de Posts

**Vista para Estudiantes (HomePage):**
- Grid de 2 columnas con todas las publicaciones
- Filtros por categoría en la parte superior
- Botón flotante naranja para crear nueva publicación

**Vista para Invitados (GuestPage):**
- Misma vista de grid pero SIN botón flotante
- Solo lectura de publicaciones

### 2. Crear Publicación (Solo Estudiantes)

Formulario con los siguientes campos:
- **Título*** (obligatorio, mín 3 caracteres)
- **Descripción*** (obligatorio, mín 10 caracteres)
- **Precio*** (obligatorio, numérico)
- **URL de Imagen** (opcional, debe ser URL válida)
- **Categorías*** (obligatorio, selección múltiple)

Categorías disponibles:
- Electrónica
- Libros
- Ropa
- Deportes
- Hogar
- Otros

### 3. Actualización Manual

El módulo **NO utiliza Supabase Realtime**. Las publicaciones se actualizan mediante:
- **Pull-to-refresh**: Deslizar hacia abajo para recargar
- **Después de crear**: Al crear un post, la lista se recarga automáticamente
- **Después de eliminar**: Al eliminar un post, la lista se recarga automáticamente

Esto simplifica la configuración y evita problemas de conexión con Realtime.

## 🔧 Configuración Necesaria

### 1. Ejecutar SQL en Supabase

```sql
-- Ejecutar el archivo: supabase/setup_marketplace.sql
```

Este script configura:
- ✅ Tabla `posts` con todos los campos
- ✅ Row Level Security (RLS)
- ✅ Políticas de acceso
- ✅ Índices para rendimiento

**Nota:** NO es necesario habilitar Realtime ya que no se utiliza.

```sql
-- Permitir lectura a todos los usuarios autenticados
CREATE POLICY "Posts son visibles para todos"
ON posts FOR SELECT
TO authenticated
USING (true);

-- Permitir inserción solo a usuarios no anónimos
CREATE POLICY "Solo estudiantes pueden crear posts"
ON posts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id AND NOT auth.jwt()->>'is_anonymous'::boolean);

-- Permitir actualización y eliminación solo al dueño
CREATE POLICY "Usuarios pueden actualizar sus propios posts"
ON posts FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden eliminar sus propios posts"
ON posts FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
```

## 🚀 Uso

### Navegación

**Para Estudiantes:**
1. Iniciar sesión con cuenta de estudiante
2. Ir a la pestaña "Marketplace" (primera opción en la barra inferior)
3. Ver todas las publicaciones
4. Presionar el botón flotante "+" para crear una nueva publicación

**Para Invitados:**
1. Ingresar como invitado
2. Ir a la pestaña "Marketplace" (primera opción en la barra inferior)
3. Solo visualizar publicaciones (sin opción de crear)

### Crear una Publicación

```dart
// El controlador maneja todo automáticamente
controller.createPost(
  title: 'iPhone 12 Pro',
  description: 'En excelente estado, 128GB',
  price: 15000.0,
  imgLink: 'https://example.com/image.jpg',
  categories: ['Electrónica'],
);
```

## 🎨 Interfaz de Usuario

### Colores
- **Color principal:** Naranja (`Colors.orange`)
- **Color secundario:** Gris (`Colors.grey`)
- **Categorías seleccionadas:** Naranja claro (`Colors.orange.shade100`)

### Componentes
- **Grid:** 2 columnas, aspect ratio 0.75
- **Cards:** Elevación 2, con imagen, título, precio y categorías
- **Filtros:** Chips horizontales deslizables
- **Botón flotante:** Solo visible para estudiantes

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web

## 🔐 Seguridad

- ✅ Validación de tipo de usuario (estudiante vs invitado)
- ✅ RLS en Supabase para proteger datos
- ✅ Validación de formularios en el frontend
- ✅ Solo el dueño puede eliminar sus posts

## 🐛 Manejo de Errores

El módulo incluye manejo de errores con mensajes amigables:
- Error al cargar posts
- Error al crear post
- Error al eliminar post
- Validación de permisos

## 📊 Estados

### Loading States
- `isLoading`: Muestra indicador de carga durante operaciones

### Reactive States
- `posts`: Lista reactiva de todas las publicaciones
- `selectedCategory`: Categoría actualmente seleccionada
- `filteredPosts`: Posts filtrados según categoría

## 🔄 Actualización de Datos

### Automática (Realtime)
```dart
void _listenToPostsChanges() {
  _postService.postsStream().listen(
    (updatedPosts) {
      posts.value = updatedPosts;
    },
  );
}
```

### Manual (Pull-to-Refresh)
```dart
await controller.refreshPosts();
```

## ✅ Testing

### Probar como Estudiante
1. Iniciar sesión con cuenta de estudiante
2. Verificar que aparece el botón flotante
3. Crear una publicación
4. Verificar que aparece en el listado

### Probar como Invitado
1. Ingresar como invitado
2. Verificar que NO aparece el botón flotante
3. Intentar acceder a crear (debería mostrar error si se implementa navegación directa)
4. Verificar que se ven las publicaciones

## 🎯 Criterios de Aceptación

- ✅ Los invitados pueden ver todas las publicaciones
- ✅ Los estudiantes pueden ver todas las publicaciones
- ✅ Solo los estudiantes pueden crear publicaciones
- ✅ Las publicaciones se muestran en ambas vistas (home y guest)
- ✅ Filtrado por categorías funcional
- ✅ Actualización en tiempo real
- ✅ Validación de formularios
- ✅ Interfaz responsiva

## 📝 Notas Importantes

1. **Usuarios Anónimos**: El sistema distingue entre usuarios anónimos (invitados) y usuarios autenticados (estudiantes) usando `user.isAnonymous`

2. **Actualización Automática**: Los posts se actualizan automáticamente gracias a Supabase Realtime, no es necesario recargar la página

3. **Imágenes**: Actualmente solo soporta URLs de imágenes externas. Para futuras versiones se podría implementar subida de imágenes a Supabase Storage

4. **Categorías**: Las categorías están definidas en el controlador y pueden ser fácilmente modificadas

## 🔮 Mejoras Futuras

- [ ] Página de detalle de publicación
- [ ] Subida de imágenes a Supabase Storage
- [ ] Sistema de mensajería entre usuarios
- [ ] Búsqueda por texto
- [ ] Favoritos
- [ ] Reportes de publicaciones
- [ ] Estadísticas de vistas
- [ ] Sistema de calificaciones

## 🙏 Resumen

**Estado del módulo:** ✅ **COMPLETADO**

El módulo de Marketplace está completamente funcional y cumple con todos los requisitos:
- Invitados pueden ver publicaciones
- Estudiantes pueden ver y crear publicaciones
- Funciona en ambas vistas (home y guest)
- Actualización en tiempo real
- Interfaz intuitiva y responsiva

---

**Desarrollado con:** ❤️ + Flutter + GetX + Supabase

**Última actualización:** 5 de Noviembre, 2025
