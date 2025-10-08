# Guía de Pruebas - BUSUAT

## 🚀 Cómo Ejecutar la App

```bash
# Opción 1: Ejecutar en dispositivo conectado o emulador
flutter run

# Opción 2: Ejecutar en Chrome (web)
flutter run -d chrome

# Opción 3: Ejecutar en Linux desktop
flutter run -d linux
```

## ✅ Lista de Pruebas

### Test 1: Flujo Completo de Registro
**Pasos**:
1. ✅ Abrir la app
2. ✅ Click en "Entrar como Estudiante"
3. ✅ Verificar que aparece pantalla con 2 opciones
4. ✅ Click en "Registrarse"
5. ✅ Ingresar email: `estudiante@test.com`
6. ✅ Ingresar contraseña: `123456`
7. ✅ Confirmar contraseña: `123456`
8. ✅ Click en "Registrarse"
9. ✅ Verificar mensaje de éxito
10. ✅ Verificar redirección a Home
11. ✅ Verificar Bottom Navigation visible

**Resultado Esperado**: Usuario registrado y logueado en Home

---

### Test 2: Validaciones de Registro
**Pasos**:
1. ✅ Ir a pantalla de registro
2. ✅ Intentar registrar con email vacío → Error
3. ✅ Intentar con email inválido `test@` → Error
4. ✅ Intentar con contraseña < 6 caracteres → Error
5. ✅ Intentar con contraseñas no coincidentes → Error
6. ✅ Registrar email duplicado → Error

**Resultado Esperado**: Validaciones funcionando correctamente

---

### Test 3: Flujo de Inicio de Sesión
**Pasos**:
1. ✅ Abrir la app (con usuario ya registrado)
2. ✅ Click en "Entrar como Estudiante"
3. ✅ Click en "Iniciar Sesión"
4. ✅ Ingresar email registrado: `estudiante@test.com`
5. ✅ Ingresar contraseña correcta: `123456`
6. ✅ Click en "Iniciar Sesión"
7. ✅ Verificar mensaje de bienvenida
8. ✅ Verificar redirección a Home

**Resultado Esperado**: Login exitoso

---

### Test 4: Login con Credenciales Incorrectas
**Pasos**:
1. ✅ Ir a pantalla de login de estudiante
2. ✅ Ingresar email: `noexiste@test.com`
3. ✅ Ingresar contraseña: `wrong123`
4. ✅ Click en "Iniciar Sesión"
5. ✅ Verificar mensaje de error

**Resultado Esperado**: Mensaje "Correo o contraseña incorrectos"

---

### Test 5: Navegación entre Login y Registro
**Pasos**:
1. ✅ Estar en pantalla de Login de estudiante
2. ✅ Click en "Regístrate"
3. ✅ Verificar navegación a Registro
4. ✅ Click en "Inicia Sesión"
5. ✅ Verificar navegación a Login

**Resultado Esperado**: Navegación bidireccional funciona

---

### Test 6: Modo Invitado
**Pasos**:
1. ✅ Abrir la app
2. ✅ Click en "Entrar como Invitado"
3. ✅ Verificar redirección a vista de Mapa
4. ✅ Verificar que NO hay Bottom Navigation
5. ✅ Verificar mensaje de funcionalidad limitada
6. ✅ Click en logout
7. ✅ Confirmar en diálogo
8. ✅ Verificar redirección a Login

**Resultado Esperado**: Modo invitado funciona correctamente

---

### Test 7: Navegación Bottom Nav (Estudiante)
**Pasos**:
1. ✅ Iniciar sesión como estudiante
2. ✅ Verificar que inicia en Marketplace
3. ✅ Click en "Mapa" → Verificar cambio de vista
4. ✅ Click en "Perfil" → Verificar cambio de vista
5. ✅ Verificar que muestra email del usuario
6. ✅ Click en "Marketplace" → Volver a primera vista

**Resultado Esperado**: Navegación fluida entre vistas

---

### Test 8: Logout de Estudiante
**Pasos**:
1. ✅ Estar logueado como estudiante
2. ✅ Ir a vista de Perfil
3. ✅ Click en icono de logout (AppBar)
4. ✅ Verificar diálogo de confirmación
5. ✅ Click en "Salir"
6. ✅ Verificar redirección a Login

**Resultado Esperado**: Logout exitoso

---

### Test 9: Persistencia de Sesión
**Pasos**:
1. ✅ Iniciar sesión como estudiante
2. ✅ Cerrar completamente la app
3. ✅ Volver a abrir la app
4. ✅ Verificar que redirige automáticamente a Home
5. ✅ Hacer logout
6. ✅ Cerrar y abrir la app
7. ✅ Verificar que muestra Login

**Resultado Esperado**: Sesión persiste correctamente

---

### Test 10: Middleware - Protección de Rutas
**Pasos**:
1. ✅ Iniciar sesión como invitado
2. ✅ Verificar que solo puede acceder a /guest
3. ✅ Hacer logout
4. ✅ Iniciar sesión como estudiante
5. ✅ Verificar que puede acceder a /home con Bottom Nav

**Resultado Esperado**: Middlewares protegen rutas correctamente

---

### Test 11: Múltiples Usuarios
**Pasos**:
1. ✅ Registrar usuario 1: `user1@test.com`
2. ✅ Logout
3. ✅ Registrar usuario 2: `user2@test.com`
4. ✅ Logout
5. ✅ Login con user1
6. ✅ Verificar que muestra email correcto
7. ✅ Logout
8. ✅ Login con user2
9. ✅ Verificar que muestra email correcto

**Resultado Esperado**: Múltiples usuarios pueden registrarse y loguearse

---

## 🐛 Casos Edge a Probar

### Edge 1: Espacios en Email/Password
- [ ] Email con espacios al inicio/final
- [ ] Password con espacios

### Edge 2: Caracteres Especiales
- [ ] Email con caracteres especiales válidos
- [ ] Password con caracteres especiales

### Edge 3: Intentos Múltiples de Login
- [ ] 5 intentos fallidos de login
- [ ] Verificar que sigue funcionando

### Edge 4: Navegación con Botón Back
- [ ] Usar botón back del dispositivo
- [ ] Verificar que la navegación es consistente

## 📊 Checklist de Funcionalidades

### Login Screen
- [x] Logo visible
- [x] Botón "Invitado" funcional
- [x] Botón "Estudiante" funcional
- [x] UI responsive

### Auth Options Screen
- [x] Icono de estudiante visible
- [x] Botón "Iniciar Sesión" funcional
- [x] Botón "Registrarse" funcional
- [x] Botón back funcional

### Student Login Screen
- [x] Campo email con validación
- [x] Campo password con toggle visibilidad
- [x] Botón login con loading state
- [x] Link a registro funcional
- [x] Mensajes de error claros

### Register Screen
- [x] Campo email con validación
- [x] Campo password con toggle visibilidad
- [x] Campo confirm password con toggle visibilidad
- [x] Botón registro con loading state
- [x] Link a login funcional
- [x] Validaciones completas

### Guest Screen
- [x] Vista de mapa placeholder
- [x] Mensaje de funcionalidad limitada
- [x] Botón logout funcional
- [x] Diálogo de confirmación

### Home Screen (Student)
- [x] Bottom Navigation con 3 items
- [x] Vista Marketplace
- [x] Vista Mapa (igual a guest)
- [x] Vista Perfil con info de usuario
- [x] Botón logout en perfil
- [x] Navegación entre vistas funcional

### Persistencia
- [x] GetStorage inicializado
- [x] Sesión persiste entre reinicios
- [x] Usuarios guardados correctamente
- [x] Logout limpia sesión

### Middlewares
- [x] AuthMiddleware funciona
- [x] GuestMiddleware funciona
- [x] StudentMiddleware funciona
- [x] Redirecciones correctas

## 🎨 Aspectos Visuales a Verificar

- [ ] Colores consistentes (azul primary)
- [ ] Espaciado uniforme
- [ ] Botones con border radius
- [ ] Iconos apropiados
- [ ] Textos legibles
- [ ] Feedback visual (loading, errors)
- [ ] Animaciones suaves (transiciones)

## 📱 Platforms a Probar

- [ ] Android
- [ ] iOS
- [ ] Web (Chrome)
- [ ] Linux Desktop
- [ ] macOS
- [ ] Windows

## ✅ Criterios de Aceptación

✅ Todos los tests pasan
✅ No hay crashes
✅ No hay errores en consola
✅ UI es intuitiva
✅ Validaciones funcionan
✅ Persistencia funciona
✅ Middlewares protegen rutas
✅ Navegación es fluida
✅ Logout funciona en ambos modos

## 🚨 Problemas Conocidos

Ninguno detectado hasta el momento.

## 📝 Notas para el Desarrollador

- El logo es un placeholder (icono de escuela)
- Las vistas de Mapa y Marketplace son placeholders
- No hay funcionalidad de "Olvidé mi contraseña"
- Las contraseñas se guardan en texto plano (usar hash en producción)
- No hay límite de intentos de login
- No hay verificación de email
