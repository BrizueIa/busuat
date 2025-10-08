# Cloudflare Pages - BUSUAT

## 🚀 Deployment Configuration

Este proyecto está configurado para desplegarse en Cloudflare Pages.

### 📁 Build Output Directory
```
build/web
```

### ⚙️ Build Settings en Cloudflare Pages

1. **Framework preset**: None (o Flutter Web)
2. **Build command**: `flutter build web --release`
3. **Build output directory**: `build/web`
4. **Root directory**: `/`

### 🔧 Variables de Entorno (si es necesario)

No se requieren variables de entorno especiales para este proyecto.

### 📝 Notas Importantes

- ✅ La carpeta `build/web` está incluida en el repositorio
- ✅ El `.gitignore` está configurado para permitir `build/web`
- ✅ El build se genera con `flutter build web --release`

### 🌐 Despliegue Automático

Cada push a la rama `main` desplegará automáticamente a Cloudflare Pages.

### 🔄 Proceso de Build Local

Para generar un nuevo build:

```bash
# Limpiar build anterior
flutter clean

# Generar nuevo build
flutter build web --release

# Agregar cambios a git
git add build/web
git commit -m "Update web build"
git push
```

### 📊 Estructura de build/web

```
build/web/
├── assets/                  # Assets de la aplicación
├── canvaskit/              # CanvasKit para rendering
├── icons/                  # Iconos de la app
├── index.html             # Punto de entrada
├── main.dart.js          # Código compilado
├── flutter.js            # Flutter engine
└── manifest.json         # Web app manifest
```

### 🐛 Troubleshooting

**Problema**: Los cambios no se reflejan en el deploy
**Solución**: 
```bash
flutter clean
flutter build web --release
git add build/web -f
git commit -m "Rebuild web"
git push
```

**Problema**: Error 404 en rutas
**Solución**: Cloudflare Pages maneja automáticamente el routing de Flutter

### 🔗 Enlaces Útiles

- [Cloudflare Pages Docs](https://developers.cloudflare.com/pages/)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

---

**Última actualización del build**: Generado automáticamente con cada deploy
