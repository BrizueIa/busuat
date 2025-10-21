# 🚌 BUSUAT

Aplicación móvil y web de la Universidad Autónoma de Tamaulipas para gestión de transporte universitario, marketplace estudiantil y agenda académica.

---

## � Características

## 📱 Características

### 🔐 Sistema de Autenticación Completo

**Dos Modos de Acceso:**

1. **👤 Modo Invitado**
   - Acceso inmediato sin registro
   - Solo visualización del mapa de rutas
   - Opción de verificar cuenta para acceso completo

2. **🎓 Modo Estudiante** (requiere email @uat.edu.mx)
   - Registro con validación institucional
   - Login con Supabase Authentication
   - Acceso a todas las funcionalidades

### 🛠️ Funcionalidades por Modo

| Funcionalidad | Invitado | Estudiante |
|--------------|----------|------------|
| 🗺️ Ver Mapa de Rutas | ✅ | ✅ |
| 🛒 Marketplace | ❌ | ✅ |
| 📅 Agenda Académica | ❌ | ✅ |
| 👤 Perfil Completo | ❌ | ✅ |

---

## � Inicio Rápido

### Prerrequisitos
- Flutter SDK 3.9.2+
- Dart SDK
- Cuenta de Supabase (para backend)

### Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/BrizueIa/busuat.git
cd busuat

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de Supabase

# 3. Instalar dependencias
flutter pub get

# 4. Ejecutar
flutter run
```

### Configuración de Supabase

1. Crear proyecto en [Supabase](https://supabase.com)
2. Obtener URL y Anon Key del proyecto
3. Crear archivo `.env` en la raíz:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
```

4. Crear Edge Function `register-user` en Supabase (ver sección Backend)

---

## 🏗️ Arquitectura

### Stack Tecnológico

- **Framework:** Flutter 3.9.2
- **Estado:** GetX ^4.6.6 (Pattern: kauemurakami/getx_pattern)
- **Backend:** Supabase (Auth + Edge Functions + PostgreSQL)
- **Storage Local:** GetStorage ^2.1.1
- **HTTP:** http ^1.2.2
- **Config:** flutter_dotenv ^5.2.1

### Estructura del Proyecto

```
lib/
├── main.dart                           # Entry point
└── app/
    ├── core/
    │   ├── config/
    │   │   └── supabase_config.dart    # Variables de entorno
    │   └── middlewares/
    │       └── auth_middleware.dart     # Control de acceso
    ├── data/
    │   ├── models/
    │   │   └── user_model.dart         # Modelo de usuario
    │   ├── repositories/
    │   │   └── auth_repository.dart     # Lógica de auth
    │   └── services/
    │       └── api_service.dart         # Conexión con backend
    ├── modules/                         # Pantallas (MVC con GetX)
    │   ├── login/                       # Pantalla inicial
    │   ├── student_login/               # Login estudiante
    │   ├── register/                    # Registro
    │   ├── guest/                       # Vista invitado
    │   │   └── views/
    │   │       ├── guest_map_view.dart
    │   │       └── guest_profile_view.dart
    │   └── home/                        # Vista estudiante
    │       └── views/
    │           ├── map_view.dart        # Mapa completo
    │           ├── marketplace_view.dart
    │           ├── agenda_view.dart
    │           └── profile_view.dart
    └── routes/
        ├── app_pages.dart               # Definición de rutas
        └── app_routes.dart              # Nombres de rutas
```

### Patrón de Arquitectura

Siguiendo **GetX Pattern** (MVC):
- **Model:** Clases de datos (`user_model.dart`)
- **View:** UI en Flutter (`*_page.dart`, `*_view.dart`)
- **Controller:** Lógica de negocio (`*_controller.dart`)
- **Binding:** Inyección de dependencias (`*_binding.dart`)
- **Repository:** Acceso a datos (`auth_repository.dart`)

---

## 🔄 Flujo de Navegación

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
     │  INVITADO   │            │  STUDENT LOGIN   │
     │  /guest     │            │  /student-login  │
     └─────┬───────┘            └────────┬─────────┘
           │                             │
           │                             ├─► Registro (/register)
           │                             │
           ▼                             ▼
     ┌─────────────┐            ┌──────────────────┐
     │   MAPA      │            │   HOME           │
     │  (Solo ver) │            │  (Bottom Nav)    │
     │             │            │  • Marketplace   │
     │  [Logout]   │            │  • Mapa          │
     └─────────────┘            │  • Agenda        │
                                │  • Perfil        │
                                │                  │
                                │  [Logout]        │
                                └──────────────────┘
```

### Rutas Principales

| Ruta | Vista | Acceso |
|------|-------|--------|
| `/login` | Pantalla inicial | Público |
| `/student-login` | Login estudiante | Público |
| `/register` | Registro | Público |
| `/guest` | Vista invitado | Solo invitados |
| `/home` | Home estudiante | Solo estudiantes |

---

## 🔐 Sistema de Autenticación

### Registro de Estudiante

1. **Validaciones:**
   - Email debe terminar en `.uat.edu.mx`
   - Contraseña mínimo 6 caracteres
   - Contraseñas deben coincidir

2. **Proceso:**
   ```
   Usuario llena formulario
   → Validación en cliente
   → Llamada a Edge Function "register-user"
   → Supabase Auth crea usuario
   → Datos guardados localmente
   → Sesión iniciada automáticamente
   → Redirección a /home
   ```

### Login de Estudiante

1. **Autenticación con Supabase:**
   ```dart
   await supabase.auth.signInWithPassword(
     email: email,
     password: password,
   );
   ```

2. **Tipos de Error:**
   - `INVALID_CREDENTIALS`: Email o contraseña incorrectos
   - `EMAIL_NOT_CONFIRMED`: Email no verificado
   - `NETWORK_ERROR`: Sin conexión
   - `UNKNOWN_ERROR`: Otro error

### Modo Invitado

- Sin registro necesario
- Sesión local sin backend
- Acceso solo al mapa
- Puede verificar cuenta (redirige a registro)

---

## 🔧 Backend (Supabase)

### Edge Function: register-user

**Endpoint:** `/functions/v1/register-user`  
**Método:** POST

**Request Body:**
```json
{
  "email": "estudiante@alumnos.uat.edu.mx",
  "password": "password123",
  "name": "Nombre Completo"
}
```

**Response (200):**
```json
{
  "message": "Usuario creado exitosamente",
  "user": {
    "id": "uuid...",
    "email": "estudiante@alumnos.uat.edu.mx",
    "created_at": "2025-10-21T..."
  }
}
```

**IMPORTANTE:** La Edge Function debe tener configuración CORS:
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
```

### Base de Datos

**Tabla: users** (gestionada por Supabase Auth)
- `id` (uuid, primary key)
- `email` (text, unique)
- `encrypted_password` (text)
- `created_at` (timestamp)
- `updated_at` (timestamp)

---

## 🚀 Deployment

### Web (Cloudflare Pages)

```bash
# Build para producción
flutter build web --release

# Deploy automático con Git
git add build/web
git commit -m "Update web build"
git push
```

**Configuración en Cloudflare:**
- Build command: `flutter build web --release`
- Build output: `build/web`
- Framework preset: None

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

---

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Test con cobertura
flutter test --coverage

# Analizar código
flutter analyze
```

---

## 📋 Comandos Útiles

```bash
# Desarrollo
flutter run                      # Ejecutar en modo debug
flutter run --release            # Ejecutar en modo release
flutter run -d chrome            # Ejecutar en navegador

# Build
flutter build web --release      # Build web
flutter build apk --release      # Build Android
flutter build ios --release      # Build iOS

# Mantenimiento
flutter pub get                  # Instalar dependencias
flutter pub upgrade              # Actualizar dependencias
flutter clean                    # Limpiar build
flutter doctor                   # Verificar instalación

# Supabase
supabase start                   # Iniciar local
supabase functions deploy        # Deploy edge functions
```

---

## 🔒 Seguridad

### Variables de Entorno

**Archivo `.env` (NO subir a Git):**
```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
```

**Protegido por `.gitignore`:**
```gitignore
.env
```

**Plantilla `.env.example` (SÍ subir a Git):**
```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### Mejores Prácticas

- ✅ Credenciales en `.env`
- ✅ `.env` en `.gitignore`
- ✅ Validación de email institucional
- ✅ Contraseñas hasheadas por Supabase
- ✅ Tokens JWT seguros
- ✅ Middlewares de protección de rutas

---

## 🐛 Troubleshooting

### Error 405 al Registrar

**Problema:** Method Not Allowed  
**Causa:** Edge Function sin CORS  
**Solución:** Agregar headers CORS a la función en Supabase Dashboard

### No Puede Hacer Login

**Problema:** Invalid credentials  
**Posibles Causas:**
- Email/contraseña incorrectos
- Usuario no registrado en Supabase
- Usuario antiguo (solo local)

**Solución:** Registrarse nuevamente con la integración actual

### Variables de Entorno Vacías

**Problema:** Supabase no inicializa  
**Causa:** `.env` mal configurado o no cargado  
**Solución:**
1. Verificar formato de `.env` (sin comillas)
2. Confirmar que está en `pubspec.yaml` assets
3. Verificar `dotenv.load()` en `main.dart`

---

## 📝 Changelog

### v2.0.0 - Integración Supabase (21 Oct 2025)
- ✅ Integración completa con Supabase Auth
- ✅ Edge Function para registro
- ✅ Variables de entorno con flutter_dotenv
- ✅ Manejo de errores mejorado
- ✅ Perfiles unificados (estudiante/invitado)

### v1.0.0 - MVP Inicial
- ✅ Sistema de autenticación local
- ✅ Modo estudiante y invitado
- ✅ Navegación con GetX
- ✅ Storage local con GetStorage

---

## 👥 Equipo

**Universidad Autónoma de Tamaulipas**  
Proyecto BUSUAT - Sistema de Transporte Universitario

---

## 📄 Licencia

Este proyecto es propiedad de la Universidad Autónoma de Tamaulipas.

---

## 📞 Contacto

Para soporte o preguntas sobre el proyecto, contactar al equipo de desarrollo de la UAT.

---

**Hecho con ❤️ para la comunidad UAT** 🐯

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
