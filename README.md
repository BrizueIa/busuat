# BUSUAT

Aplicación Flutter con sistema de autenticación usando GetX siguiendo el patrón de arquitectura de kauemurakami/getx_pattern.

---

## 📚 Documentación

### 🚀 Inicio Rápido
- **[INDEX.md](INDEX.md)** - 📚 Índice completo de documentación
- **[SUMMARY.md](SUMMARY.md)** - 📋 Resumen ejecutivo (EMPIEZA AQUÍ)

### 📖 Guías Principales
- **[FLOW.md](FLOW.md)** - 🔄 Flujo detallado de navegación
- **[FILES.md](FILES.md)** - 📁 Estructura del proyecto
- **[TESTING.md](TESTING.md)** - 🧪 Guía de pruebas
- **[COMMANDS.md](COMMANDS.md)** - 🚀 Comandos útiles
- **[CHANGELOG.md](CHANGELOG.md)** - 📝 Historial de cambios
- **[CLOUDFLARE_DEPLOYMENT.md](CLOUDFLARE_DEPLOYMENT.md)** - 🌐 Guía de deployment

---

## Características

### 🔐 Sistema de Login
- **Pantalla de login** con logo y dos opciones de acceso
- **Modo Invitado**: Acceso directo sin registro
- **Modo Estudiante**: Lleva a opciones de autenticación

### 🎓 Autenticación de Estudiante
- **Vista intermedia** con dos opciones:
  - **Iniciar Sesión**: Para usuarios registrados
  - **Registrarse**: Para nuevos usuarios
- Validación de correo electrónico
- Validación de contraseña (mínimo 6 caracteres)
- Confirmación de contraseña en registro

### 👤 Modo Invitado
- Acceso limitado a una sola vista
- Vista de Mapa (funcionalidad próximamente)
- Opción de cerrar sesión

### 🎓 Modo Estudiante
- Registro con validación de correo y contraseña
- Acceso completo con Bottom Navigation
- 3 vistas disponibles:
  - **Marketplace** (izquierda)
  - **Mapa** (centro) - misma vista que invitado
  - **Perfil** (derecha)
- Visualización de información del usuario
- Opción de cerrar sesión

### 🛡️ Middleware de Autenticación
- Control de acceso basado en tipo de usuario
- Redirección automática según permisos
- Persistencia de sesión con GetStorage

## Estructura del Proyecto

Siguiendo el patrón GetX de kauemurakami/getx_pattern:

```
lib/
├── main.dart
└── app/
    ├── core/
    │   └── middlewares/
    │       └── auth_middleware.dart
    ├── data/
    │   ├── models/
    │   │   └── user_model.dart
    │   └── repositories/
    │       └── auth_repository.dart
    ├── modules/
    │   ├── login/
    │   │   ├── login_page.dart
    │   │   ├── login_controller.dart
    │   │   └── login_binding.dart
    │   ├── auth_options/
    │   │   ├── auth_options_page.dart
    │   │   ├── auth_options_controller.dart
    │   │   └── auth_options_binding.dart
    │   ├── student_login/
    │   │   ├── student_login_page.dart
    │   │   ├── student_login_controller.dart
    │   │   └── student_login_binding.dart
    │   ├── register/
    │   │   ├── register_page.dart
    │   │   ├── register_controller.dart
    │   │   └── register_binding.dart
    │   ├── guest/
    │   │   ├── guest_page.dart
    │   │   ├── guest_controller.dart
    │   │   └── guest_binding.dart
    │   └── home/
    │       ├── home_page.dart
    │       ├── home_controller.dart
    │       ├── home_binding.dart
    │       └── views/
    │           ├── map_view.dart
    │           ├── marketplace_view.dart
    │           └── profile_view.dart
    └── routes/
        ├── app_pages.dart
        └── app_routes.dart
```

## Dependencias

- **get**: ^4.6.6 - Gestión de estado, navegación y dependencias
- **get_storage**: ^2.1.1 - Persistencia de datos local

## Flujo de Navegación

```
                        ┌─────────────┐
                        │   LOGIN     │
                        │  (Inicio)   │
                        └──────┬──────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ▼                             ▼
         ┌─────────────┐            ┌──────────────────┐
         │   INVITADO  │            │   ESTUDIANTE     │
         │   /guest    │            │  /auth-options   │
         └─────────────┘            └────────┬─────────┘
                │                             │
                │                  ┌──────────┴──────────┐
                │                  │                     │
                │                  ▼                     ▼
                │          ┌──────────────┐      ┌─────────────┐
                │          │ INICIAR      │      │  REGISTRO   │
                │          │ SESIÓN       │◄────►│  /register  │
                │          │ /student-    │      │             │
                │          │ login        │      │             │
                │          └──────┬───────┘      └──────┬──────┘
                │                 │                     │
                │                 └──────────┬──────────┘
                ▼                            ▼
         ┌─────────────┐            ┌──────────────────┐
         │   MAPA      │            │   HOME           │
         │  (Vista     │            │  (Bottom Nav)    │
         │  Simple)    │            │  - Marketplace   │
         │             │            │  - Mapa          │
         │  [Logout]   │            │  - Perfil        │
         └─────────────┘            │                  │
                                    │  [Logout]        │
                                    └──────────────────┘
```

1. **Login** (`/login`)
   - Botón "Invitado" → `/guest`
   - Botón "Estudiante" → `/auth-options`

2. **Opciones de Autenticación** (`/auth-options`)
   - Botón "Iniciar Sesión" → `/student-login`
   - Botón "Registrarse" → `/register`

3. **Iniciar Sesión Estudiante** (`/student-login`)
   - Validación de credenciales
   - Login exitoso → `/home`
   - Link a "Registrarse" → `/register`

4. **Registro** (`/register`)
   - Validación de email y contraseña
   - Registro exitoso → `/home`
   - Link a "Iniciar Sesión" → `/student-login`

5. **Invitado** (`/guest`)
   - Vista única de mapa
   - Logout → `/login`

6. **Home Estudiante** (`/home`)
   - Bottom Navigation con 3 vistas
   - Logout → `/login`

## Middlewares

### AuthMiddleware
- Previene acceso a `/login` si hay sesión activa
- Redirige según tipo de usuario

### GuestMiddleware
- Protege rutas de invitado
- Redirige a login si no hay sesión

### StudentMiddleware
- Protege rutas de estudiante
- Redirige invitados a su vista
- Redirige a login si no hay sesión

## Cómo usar

### Instalación
```bash
flutter pub get
```

### Ejecutar
```bash
flutter run
```

### Modo Invitado
1. En la pantalla de login, presiona "Entrar como Invitado"
2. Accederás directamente a la vista de mapa
3. Funcionalidad limitada

### Modo Estudiante
1. En la pantalla de login, presiona "Entrar como Estudiante"
2. Elige entre "Iniciar Sesión" o "Registrarse"

#### Si te registras (primera vez):
3. Ingresa email y contraseña
4. Confirma la contraseña
5. Presiona "Registrarse"
6. Accederás al home con bottom navigation

#### Si inicias sesión (ya registrado):
3. Ingresa tu email y contraseña
4. Presiona "Iniciar Sesión"
5. Accederás al home con bottom navigation

6. Navega entre Marketplace, Mapa y Perfil

## Próximas Funcionalidades
- [ ] Implementación del mapa real
- [ ] Funcionalidad de Marketplace
- [ ] Edición de perfil
- [ ] Recuperación de contraseña
- [ ] Integración con backend

## Tecnologías
- Flutter
- GetX (State Management)
- GetStorage (Local Persistence)
- Material Design 3

## 🌐 Deployment

### Cloudflare Pages

La aplicación está configurada para desplegarse automáticamente en Cloudflare Pages.

**Build Output**: `build/web`

#### Despliegue rápido:

```bash
# Opción 1: Usar script automatizado
./deploy_web.sh

# Opción 2: Manual
flutter build web --release
git add build/web
git commit -m "Update web build"
git push
```

Ver **[CLOUDFLARE_DEPLOYMENT.md](CLOUDFLARE_DEPLOYMENT.md)** para más detalles.

### Configuración en Cloudflare Pages:
- **Build command**: `flutter build web --release`
- **Build output directory**: `build/web`
- **Framework preset**: None

# busuat
