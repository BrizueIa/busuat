# Flujo de Autenticación - BUSUAT

## Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────────────┐
│                        PANTALLA INICIAL                         │
│                         (Login Page)                            │
│                                                                 │
│  ┌─────────────┐                    ┌────────────────────────┐│
│  │   INVITADO  │                    │     ESTUDIANTE         ││
│  └──────┬──────┘                    └──────────┬─────────────┘│
└─────────┼────────────────────────────────────────┼─────────────┘
          │                                        │
          │                                        ▼
          │                          ┌──────────────────────────┐
          │                          │   Opciones Auth          │
          │                          │  (Auth Options Page)     │
          │                          │                          │
          │                          │  ┌──────────────────┐   │
          │                          │  │ Iniciar Sesión   │   │
          │                          │  └────────┬─────────┘   │
          │                          │                          │
          │                          │  ┌──────────────────┐   │
          │                          │  │   Registrarse    │   │
          │                          │  └────────┬─────────┘   │
          │                          └───────────┼──────────────┘
          │                                      │
          │                      ┌───────────────┴───────────────┐
          │                      │                               │
          │                      ▼                               ▼
          │          ┌────────────────────┐        ┌──────────────────────┐
          │          │  Login Estudiante  │        │      Registro        │
          │          │(Student Login Page)│        │   (Register Page)    │
          │          │                    │        │                      │
          │          │  - Email           │        │  - Email             │
          │          │  - Password        │        │  - Password          │
          │          │                    │◄───────┤  - Confirm Password  │
          │          │  [Iniciar Sesión]  │        │                      │
          │          │                    │        │  [Registrarse]       │
          │          │  Link: Regístrate ─┼───────►│                      │
          │          └────────┬───────────┘        │  Link: Inicia Sesión │
          │                   │                    └──────────┬───────────┘
          │                   │                               │
          │                   │      ┌────────────────────────┘
          │                   │      │
          ▼                   ▼      ▼
    ┌──────────┐        ┌─────────────────────────────┐
    │  Guest   │        │      Home Estudiante        │
    │  Page    │        │     (Home Page)             │
    │          │        │                             │
    │  - Mapa  │        │  Bottom Navigation:         │
    │          │        │  ┌────────┬──────┬────────┐│
    │ [Logout] │        │  │Market..│ Mapa │ Perfil ││
    └──────────┘        │  └────────┴──────┴────────┘│
                        │                             │
                        │         [Logout]            │
                        └─────────────────────────────┘
```

## Rutas de la Aplicación

| Ruta | Página | Middleware | Descripción |
|------|--------|-----------|-------------|
| `/login` | LoginPage | AuthMiddleware | Pantalla principal con 2 opciones |
| `/auth-options` | AuthOptionsPage | - | Elegir entre Login o Registro |
| `/student-login` | StudentLoginPage | - | Inicio de sesión para estudiantes |
| `/register` | RegisterPage | - | Registro de nuevos estudiantes |
| `/guest` | GuestPage | GuestMiddleware | Vista limitada para invitados |
| `/home` | HomePage | StudentMiddleware | Home con bottom nav para estudiantes |

## Middlewares

### 1. AuthMiddleware
**Propósito**: Controlar acceso a la pantalla de login

**Lógica**:
```
SI hay sesión activa:
  SI es invitado → Redirigir a /guest
  SI es estudiante → Redirigir a /home
SINO:
  Permitir acceso a /login
```

### 2. GuestMiddleware
**Propósito**: Proteger rutas de invitado

**Lógica**:
```
SI NO hay sesión activa:
  Redirigir a /login
SINO:
  Permitir acceso
```

### 3. StudentMiddleware
**Propósito**: Proteger rutas de estudiante

**Lógica**:
```
SI NO hay sesión activa:
  Redirigir a /login
SI es invitado:
  Redirigir a /guest
SINO:
  Permitir acceso
```

## Casos de Uso

### Caso 1: Usuario Nuevo - Invitado
1. Abre la app → `/login`
2. Click en "Entrar como Invitado"
3. Se guarda sesión como invitado
4. Redirige a `/guest`
5. Ve vista de Mapa

### Caso 2: Usuario Nuevo - Estudiante (Registro)
1. Abre la app → `/login`
2. Click en "Entrar como Estudiante" → `/auth-options`
3. Click en "Registrarse" → `/register`
4. Llena formulario (email, password, confirm password)
5. Click en "Registrarse"
6. Se valida y guarda usuario
7. Se guarda sesión como estudiante
8. Redirige a `/home`
9. Ve Bottom Navigation con 3 vistas

### Caso 3: Usuario Registrado - Estudiante (Login)
1. Abre la app → `/login`
2. Click en "Entrar como Estudiante" → `/auth-options`
3. Click en "Iniciar Sesión" → `/student-login`
4. Ingresa email y password
5. Click en "Iniciar Sesión"
6. Se valida credenciales
7. Se guarda sesión como estudiante
8. Redirige a `/home`
9. Ve Bottom Navigation con 3 vistas

### Caso 4: Usuario con Sesión Activa
1. Abre la app → `/login`
2. AuthMiddleware detecta sesión activa
3. SI es invitado → Redirige a `/guest`
4. SI es estudiante → Redirige a `/home`

### Caso 5: Navegación entre Login y Registro
**Desde Registro a Login**:
1. Está en `/register`
2. Click en "Inicia Sesión"
3. Navega a `/student-login`

**Desde Login a Registro**:
1. Está en `/student-login`
2. Click en "Regístrate"
3. Navega a `/register`

## Validaciones

### Registro
- ✅ Email no vacío
- ✅ Email válido (formato)
- ✅ Password no vacío
- ✅ Password mínimo 6 caracteres
- ✅ Confirm password no vacío
- ✅ Passwords coinciden
- ✅ Email no registrado previamente

### Login Estudiante
- ✅ Email no vacío
- ✅ Email válido (formato)
- ✅ Password no vacío
- ✅ Credenciales correctas (email + password match)

## Persistencia de Datos

### GetStorage
**Claves utilizadas**:
- `current_user`: Usuario actualmente logueado
- `users`: Array de todos los usuarios registrados

**Estructura de Usuario**:
```dart
{
  'id': 'unique_id',
  'email': 'user@example.com',
  'password': 'hashed_password', // En producción usar hash
  'userType': 'guest' | 'student'
}
```

## Estados de Sesión

| Estado | Tipo Usuario | Rutas Permitidas | Rutas Bloqueadas |
|--------|-------------|------------------|------------------|
| Sin sesión | - | `/login`, `/auth-options`, `/student-login`, `/register` | `/guest`, `/home` |
| Invitado | guest | `/guest` | `/home` |
| Estudiante | student | `/home` | `/guest` |

## Logout

### Desde Vista Invitado
1. Click en icono logout (AppBar)
2. Confirma en diálogo
3. Se elimina sesión
4. Redirige a `/login`

### Desde Vista Estudiante (Perfil)
1. Click en icono logout (AppBar en ProfileView)
2. Confirma en diálogo
3. Se elimina sesión
4. Redirige a `/login`
