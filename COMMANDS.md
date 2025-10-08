# 🚀 Comandos Rápidos - BUSUAT

## 📱 Ejecución

### Ejecutar en dispositivo/emulador
```bash
flutter run
```

### Ejecutar en Chrome (Web)
```bash
flutter run -d chrome
```

### Ejecutar en Linux Desktop
```bash
flutter run -d linux
```

### Ejecutar con hot reload automático
```bash
flutter run --hot
```

### Ejecutar en modo release
```bash
flutter run --release
```

## 🔍 Análisis y Debug

### Analizar código
```bash
flutter analyze
```

### Ver dispositivos disponibles
```bash
flutter devices
```

### Ver información del sistema
```bash
flutter doctor -v
```

### Ver logs detallados
```bash
flutter logs
```

## 🧹 Limpieza

### Limpiar build
```bash
flutter clean
```

### Limpiar y reinstalar dependencias
```bash
flutter clean && flutter pub get
```

## 📦 Dependencias

### Instalar/actualizar dependencias
```bash
flutter pub get
```

### Ver dependencias desactualizadas
```bash
flutter pub outdated
```

### Actualizar dependencias
```bash
flutter pub upgrade
```

## 🔨 Build

### Build APK (Android)
```bash
flutter build apk
```

### Build APK split por ABI
```bash
flutter build apk --split-per-abi
```

### Build App Bundle (Android)
```bash
flutter build appbundle
```

### Build iOS
```bash
flutter build ios
```

### Build Web
```bash
flutter build web
```

### Build Linux
```bash
flutter build linux
```

## 🧪 Testing

### Ejecutar todos los tests
```bash
flutter test
```

### Ejecutar tests con coverage
```bash
flutter test --coverage
```

### Ver cobertura de tests
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📊 Inspección de Código

### Ver estructura del proyecto
```bash
tree lib/
```

### Contar archivos Dart
```bash
find lib -name "*.dart" | wc -l
```

### Contar líneas de código
```bash
find lib -name "*.dart" | xargs wc -l
```

### Ver archivos ordenados por tamaño
```bash
find lib -name "*.dart" -exec wc -l {} + | sort -rn
```

### Buscar TODO en el código
```bash
grep -r "TODO" lib/
```

### Buscar FIXME en el código
```bash
grep -r "FIXME" lib/
```

## 🎨 Formato

### Formatear todo el código
```bash
dart format lib/
```

### Formatear y sobrescribir
```bash
dart format lib/ -w
```

### Verificar formato sin cambiar
```bash
dart format lib/ --set-exit-if-changed
```

## 🔧 GetX Específicos

### Ver todas las rutas
```bash
grep -r "static const" lib/app/routes/app_routes.dart
```

### Ver todos los controllers
```bash
find lib/app/modules -name "*_controller.dart"
```

### Ver todos los bindings
```bash
find lib/app/modules -name "*_binding.dart"
```

### Ver todas las páginas
```bash
find lib/app/modules -name "*_page.dart"
```

## 📱 Emulador

### Listar emuladores Android
```bash
flutter emulators
```

### Iniciar emulador específico
```bash
flutter emulators --launch <emulator_id>
```

### Crear nuevo emulador
```bash
flutter emulators --create
```

## 🐛 Debug

### Ejecutar en modo debug
```bash
flutter run --debug
```

### Ejecutar con verbose
```bash
flutter run -v
```

### Ver performance overlay
```bash
flutter run --profile
```

### Inspector de widgets
```bash
# Mientras la app está corriendo, presiona:
# 'w' - Toggle widget inspector
# 'p' - Toggle debug painting
# 'i' - Toggle platform mode
# 'o' - Toggle brightness
# 'z' - Toggle elevation
```

## 🔐 GetStorage Debug

### Limpiar datos de GetStorage (terminal Dart)
```dart
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  final box = GetStorage();
  
  // Ver todos los datos
  print(box.getKeys());
  
  // Ver usuario actual
  print(box.read('current_user'));
  
  // Ver todos los usuarios
  print(box.read('users'));
  
  // Limpiar todo
  await box.erase();
}
```

## 📝 Scripts Útiles

### Script para limpiar y ejecutar
```bash
#!/bin/bash
flutter clean
flutter pub get
flutter run
```

### Script para build release Android
```bash
#!/bin/bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
open build/app/outputs/flutter-apk/
```

### Script para análisis completo
```bash
#!/bin/bash
echo "🔍 Analizando código..."
flutter analyze

echo "\n📊 Contando archivos..."
find lib -name "*.dart" | wc -l

echo "\n📈 Contando líneas..."
find lib -name "*.dart" | xargs wc -l | tail -1

echo "\n✅ Análisis completado"
```

## 🎯 Comandos de Desarrollo Diario

### Inicio del día
```bash
cd /home/brizuela/development/flutterProjects/busuat
git pull
flutter pub get
flutter run
```

### Antes de commit
```bash
dart format lib/ -w
flutter analyze
flutter test
git add .
git commit -m "mensaje"
git push
```

### Actualización de dependencias
```bash
flutter pub outdated
flutter pub upgrade
flutter analyze
flutter test
```

## 🔄 Git Helpers

### Ver cambios
```bash
git status
git diff
```

### Crear branch para feature
```bash
git checkout -b feature/nombre-feature
```

### Ver historial
```bash
git log --oneline --graph
```

### Stash cambios
```bash
git stash
git stash pop
```

## 📋 Checklist de Deploy

```bash
# 1. Tests
flutter test

# 2. Análisis
flutter analyze

# 3. Formato
dart format lib/ -w

# 4. Build
flutter build apk --release

# 5. Verificar tamaño
ls -lh build/app/outputs/flutter-apk/*.apk

# 6. Test en device
flutter install

# 7. Tag version
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

## 🎨 UI Debug

### Toggle debug paint
```bash
# En la app corriendo, presiona 'p' en el terminal
```

### Toggle performance overlay
```bash
# En la app corriendo, presiona 'P' en el terminal
```

### Take screenshot
```bash
# En la app corriendo, presiona 's' en el terminal
```

## 📱 Platform Specific

### Android Logcat
```bash
adb logcat | grep flutter
```

### iOS Simulator
```bash
open -a Simulator
```

### Clear iOS derived data
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## 🚀 Performance

### Profile build
```bash
flutter run --profile
```

### Trace performance
```bash
flutter run --trace-startup
```

### Analyze size
```bash
flutter build apk --analyze-size
```

## 💡 Tips

### Reiniciar hot reload
```bash
# En la app corriendo:
# 'r' - Hot reload
# 'R' - Hot restart
# 'h' - Help
# 'q' - Quit
```

### Ver ayuda de comandos
```bash
flutter help
flutter run --help
flutter build --help
```

### Actualizar Flutter
```bash
flutter upgrade
flutter doctor
```

---

**💡 Tip**: Crea aliases en tu shell para comandos frecuentes:

```bash
# Agregar a ~/.bashrc o ~/.zshrc o ~/.config/fish/config.fish

# Para Bash/Zsh:
alias fr='flutter run'
alias fa='flutter analyze'
alias fc='flutter clean'
alias fpg='flutter pub get'

# Para Fish:
alias fr 'flutter run'
alias fa 'flutter analyze'
alias fc 'flutter clean'
alias fpg 'flutter pub get'
```
