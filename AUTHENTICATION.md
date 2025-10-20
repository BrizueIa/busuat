# Módulo de Autenticación - BUSUAT

## Descripción General

Sistema de autenticación que permite diferenciar entre usuarios **estudiantes** e **invitados**, garantizando acceso exclusivo a ciertas funcionalidades solo para alumnos de la UAT.

---

## 📋 Requisitos Cumplidos

### ✅ Criterio 1: Opciones de Inicio de Sesión
La aplicación ofrece dos modos de acceso desde la pantalla inicial:
- **Modo Invitado**: Acceso limitado
- **Modo Estudiante**: Acceso completo con autenticación

### ✅ Criterio 2: Restricciones para Invitados
Los usuarios invitados tienen acceso **únicamente** a:
- ✅ Mapa de la UAT

Los usuarios invitados **NO tienen acceso** a:
- ❌ Marketplace
- ❌ Agendas

### ✅ Criterio 3: Registro de Estudiantes
Sistema de registro con validaciones estrictas:
- Correo institucional obligatorio con dominio `.uat.edu.mx`
- Contraseña definida y confirmada por el usuario
- Información de contacto de soporte para aclaraciones: `ejemplo@ejemplo.com`

---

## 🚀 Flujos de Usuario

### 1. Flujo de Invitado
```
Pantalla Inicial (Login) 
    → Botón "Entrar como Invitado"
    → Página de Invitado (Solo Mapa)
    → Opción de crear cuenta de estudiante
```

**Características:**
- Acceso inmediato sin registro
- Solo visualización del Mapa de la UAT
- Mensaje claro sobre funcionalidades restringidas
- Opción visible para registrarse como estudiante

### 2. Flujo de Registro de Estudiante
```
Pantalla Inicial (Login)
    → Botón "Entrar como Estudiante"
    → Opciones de Autenticación
    → Botón "Registrarse"
    → Formulario de Registro
    → Validación de correo institucional
    → Creación de cuenta
    → Página Principal (Home) con acceso completo
```

**Validaciones del Registro:**
- ✅ Nombre completo requerido
- ✅ Correo institucional debe terminar en `.uat.edu.mx`
- ✅ Formato de correo: `usuario@subdominio.uat.edu.mx`
- ✅ Contraseña mínima de 6 caracteres
- ✅ Confirmación de contraseña debe coincidir
- ✅ Correo único (no duplicado)

### 3. Flujo de Inicio de Sesión de Estudiante
```
Pantalla Inicial (Login)
    → Botón "Entrar como Estudiante"
    → Opciones de Autenticación
    → Botón "Iniciar Sesión"
    → Formulario de Login
    → Validación de credenciales
    → Página Principal (Home) con acceso completo
```

---

## 🏗️ Arquitectura del Módulo

### Estructura de Carpetas
```
lib/app/
├── core/
│   ├── config/
│   │   └── supabase_config.dart
│   └── middlewares/
│       └── auth_middleware.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── services/
│       └── api_service.dart
├── modules/
│   ├── login/
│   │   ├── login_binding.dart
│   │   ├── login_controller.dart
│   │   └── login_page.dart
│   ├── auth_options/
│   │   ├── auth_options_binding.dart
│   │   ├── auth_options_controller.dart
│   │   └── auth_options_page.dart
│   ├── student_login/
│   │   ├── student_login_binding.dart
│   │   ├── student_login_controller.dart
│   │   └── student_login_page.dart
│   ├── register/
│   │   ├── register_binding.dart
│   │   ├── register_controller.dart
│   │   └── register_page.dart
│   ├── guest/
│   │   ├── guest_binding.dart
│   │   ├── guest_controller.dart
│   │   └── guest_page.dart
│   └── home/
│       ├── home_binding.dart
│       ├── home_controller.dart
│       └── home_page.dart
└── routes/
    ├── app_pages.dart
    └── app_routes.dart
```

### Componentes Principales

#### 1. **UserModel** (`user_model.dart`)
Modelo de datos del usuario con soporte para tipos de usuario.

```dart
class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String userType; // 'guest' or 'student'
  
  bool get isGuest => userType == 'guest';
  bool get isStudent => userType == 'student';
}
```

#### 2. **AuthRepository** (`auth_repository.dart`)
Gestión de autenticación y persistencia local.

**Métodos principales:**
- `registerStudent(email, password, name)` - Registro de estudiantes
- `loginStudent(email, password)` - Login de estudiantes
- `loginAsGuest()` - Login como invitado
- `getCurrentUser()` - Obtener usuario actual
- `hasActiveSession()` - Verificar sesión activa
- `logout()` - Cerrar sesión

#### 3. **Middlewares** (`auth_middleware.dart`)
Control de acceso basado en tipo de usuario.

**Middlewares disponibles:**
- `AuthMiddleware` - Redirección automática si hay sesión activa
- `GuestMiddleware` - Protección para rutas de invitado
- `StudentMiddleware` - Protección para rutas exclusivas de estudiantes

---

## 🔐 Seguridad Implementada

### Almacenamiento Local
- Uso de `GetStorage` para persistencia segura
- Almacenamiento de sesión de usuario
- Gestión de lista de usuarios registrados

### Validaciones

#### Validación de Correo Institucional
```dart
// Validación 1: Debe terminar en .uat.edu.mx
email.toLowerCase().endsWith('.uat.edu.mx')

// Validación 2: Formato correcto usuario@subdominio.uat.edu.mx
final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+\.uat\.edu\.mx$');
```

#### Validación de Contraseña
- Mínimo 6 caracteres
- Confirmación debe coincidir
- Almacenamiento en storage local

### Protección de Rutas
Las rutas están protegidas mediante middlewares que:
1. Verifican si hay sesión activa
2. Validan tipo de usuario (guest/student)
3. Redirigen automáticamente según permisos

---

## 🎨 Diseño de UI/UX

### Paleta de Colores
- **Principal**: Orange (Color UAT)
- **Secundario**: Grey para invitados
- **Información**: Blue para mensajes informativos
- **Error**: Red para validaciones fallidas
- **Éxito**: Green para operaciones exitosas

### Componentes Visuales

#### Pantalla de Login
- Logo de BUSUAT
- Información sobre modos de acceso
- Botones diferenciados por color
- Diseño limpio y profesional

#### Pantalla de Registro
- Campos claros con iconos
- Validación en tiempo real
- Visibilidad de contraseña toggle
- Mensaje de información de soporte
- Links a inicio de sesión

#### Pantalla de Invitado
- Mensaje de bienvenida
- Información de funcionalidades restringidas
- Lista visual de características bloqueadas
- Call-to-action para registrarse como estudiante
- Botón de logout

#### Pantalla de Estudiante (Home)
- Navegación por pestañas (BottomNavigationBar)
- Acceso completo: Marketplace, Mapa, Perfil
- Diseño intuitivo

---

## 📱 Rutas Configuradas

| Ruta | Descripción | Middleware | Acceso |
|------|-------------|-----------|---------|
| `/login` | Pantalla inicial | AuthMiddleware | Público |
| `/auth-options` | Opciones de autenticación | - | Público |
| `/student-login` | Login de estudiantes | - | Público |
| `/register` | Registro de estudiantes | - | Público |
| `/guest` | Vista de invitado | GuestMiddleware | Solo invitados |
| `/home` | Vista principal | StudentMiddleware | Solo estudiantes |

---

## 🔄 Estado de la Sesión

### Persistencia
La sesión del usuario se mantiene entre reinicios de la aplicación mediante `GetStorage`.

### Verificación Automática
Al iniciar la app, el `AuthMiddleware` verifica:
1. Si existe una sesión activa
2. El tipo de usuario de la sesión
3. Redirige automáticamente a la vista correspondiente:
   - Invitado → `/guest`
   - Estudiante → `/home`
   - Sin sesión → `/login`

---

## 📞 Soporte

Para problemas con el registro o la autenticación, los usuarios pueden contactar a:

**Email de Soporte:** ejemplo@ejemplo.com

Este contacto está visible en:
- Pantalla de registro (mensaje informativo)
- Documentación de la app

---

## 🔧 Configuración Técnica

### Dependencias Utilizadas
```yaml
dependencies:
  get: ^4.6.6           # Gestión de estado y navegación
  get_storage: ^2.1.1   # Almacenamiento local
  supabase_flutter: ^2.9.1  # Backend (preparado para futuro)
```

### Inicialización
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}
```

---

## 🚀 Mejoras Futuras

### Fase 1 - Actualmente Implementado ✅
- [x] Login como invitado
- [x] Registro de estudiantes con correo institucional
- [x] Login de estudiantes
- [x] Restricción de acceso por tipo de usuario
- [x] Persistencia de sesión local
- [x] Validación de correo .uat.edu.mx
- [x] UI/UX completa y profesional

### Fase 2 - Planeado 📋
- [ ] Integración completa con Supabase Auth
- [ ] Verificación de correo institucional por email
- [ ] Recuperación de contraseña
- [ ] Perfil de usuario editable
- [ ] Foto de perfil
- [ ] Configuración de privacidad

### Fase 3 - Futuro 🔮
- [ ] Autenticación con Google (correo institucional)
- [ ] Autenticación biométrica (huella/facial)
- [ ] Sistema de roles (alumno, profesor, admin)
- [ ] Notificaciones push

---

## 📝 Notas Importantes

1. **Correo Institucional**: Por el momento, el sistema no envía correos de verificación. La contraseña se establece directamente en la app.

2. **Almacenamiento Local**: Los datos de usuarios se almacenan localmente usando GetStorage. En producción, se recomienda migrar a Supabase Auth para mayor seguridad.

3. **Validación Estricta**: El sistema solo acepta correos que terminen en `.uat.edu.mx` con el formato correcto.

4. **Experiencia de Usuario**: Los mensajes de error son claros y descriptivos para ayudar al usuario en el proceso de registro/login.

---

## 🎯 Cumplimiento de Criterios de Aceptación

| # | Criterio | Estado | Detalle |
|---|----------|--------|---------|
| 1 | Opción de iniciar como invitado o estudiante | ✅ Cumplido | Pantalla inicial con dos botones claramente diferenciados |
| 2 | Restricción de acceso para invitados | ✅ Cumplido | Invitados solo ven el Mapa. Marketplace y Agendas bloqueados. |
| 3 | Registro con correo institucional (.uat.edu.mx) | ✅ Cumplido | Validación estricta del dominio y formato de correo |
| 3.1 | Contraseña definida por usuario | ✅ Cumplido | Usuario crea y confirma su contraseña |
| 3.2 | Información de soporte | ✅ Cumplido | Email de soporte visible: ejemplo@ejemplo.com |

---

## 📄 Licencia

Este módulo es parte de la aplicación BUSUAT desarrollada para la Universidad Autónoma de Tamaulipas.

---

**Última actualización:** 20 de Octubre de 2025  
**Versión del módulo:** 1.0.0  
**Estado:** ✅ Completado y funcional
