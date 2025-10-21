#!/bin/bash
set -ex

echo "🚀 Iniciando build de Flutter para Cloudflare Pages"
echo "=================================================="

# Verificar variables de entorno
echo "📋 Verificando variables de entorno..."
if [ -z "$SUPABASE_URL" ]; then
    echo "❌ ERROR: SUPABASE_URL no está definida"
    exit 1
fi
if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ ERROR: SUPABASE_ANON_KEY no está definida"
    exit 1
fi
echo "✅ Variables de entorno configuradas"

# Crear .env temporal (para que Flutter no falle, aunque no se usa)
echo ""
echo "📝 Creando archivo .env temporal..."
cat > .env << EOF
# Este archivo es temporal para compilación en Cloudflare
# Las variables reales se pasan via --dart-define
SUPABASE_URL=placeholder
SUPABASE_ANON_KEY=placeholder
EOF

# Usar versión de Flutter específica si está definida
FLUTTER_BRANCH="${FLUTTER_VERSION:-stable}"
echo "📌 Versión de Flutter a usar: $FLUTTER_BRANCH"

# Instalar Flutter
echo ""
echo "📦 Descargando Flutter SDK..."
if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b "$FLUTTER_BRANCH" --depth 1
else
    echo "Flutter ya está descargado, saltando..."
fi

# Configurar PATH
echo ""
echo "🔧 Configurando Flutter..."
export PATH="$PATH:$PWD/flutter/bin"
export PATH="$PATH:$PWD/flutter/bin/cache/dart-sdk/bin"

# Verificar Flutter
echo ""
echo "🔍 Verificando instalación de Flutter..."
flutter --version

# Pre-configuración de Flutter
echo ""
echo "⚙️ Configurando Flutter..."
flutter config --no-analytics
flutter config --enable-web

# Obtener dependencias
echo ""
echo "📦 Obteniendo dependencias..."
flutter pub get

# Compilar para web
echo ""
echo "🔨 Compilando Flutter Web..."
echo "   URL: $SUPABASE_URL"
echo "   KEY: ${SUPABASE_ANON_KEY:0:20}..."

flutter build web \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --release

# Verificar que build/web existe
echo ""
echo "🔍 Verificando directorio de salida..."
if [ -d "build/web" ]; then
    echo "✅ build/web creado exitosamente"
    echo "📁 Contenido de build/web:"
    ls -la build/web
else
    echo "❌ ERROR: build/web no fue creado"
    exit 1
fi

echo ""
echo "✅ Compilación completada exitosamente"
echo "=================================================="