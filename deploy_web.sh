#!/bin/bash

# Script para rebuild y deploy a Cloudflare Pages

echo "🚀 Iniciando proceso de build para Cloudflare Pages..."
echo ""

# Paso 1: Limpiar build anterior
echo "🧹 Limpiando build anterior..."
flutter clean

# Paso 2: Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

# Paso 3: Generar build de producción
echo "🔨 Generando build de producción..."
flutter build web --release

# Verificar si el build fue exitoso
if [ $? -eq 0 ]; then
    echo "✅ Build generado exitosamente en build/web"
    echo ""
    
    # Paso 4: Agregar a git
    echo "📝 Agregando cambios a git..."
    git add build/web .gitignore
    
    # Mostrar estado
    echo ""
    echo "📊 Archivos listos para commit:"
    git status --short | grep "build/web"
    
    echo ""
    echo "✅ Build completado y listo para deploy"
    echo ""
    echo "📋 Próximos pasos:"
    echo "  1. git commit -m 'Update web build'"
    echo "  2. git push"
    echo ""
    echo "🌐 El deploy se realizará automáticamente en Cloudflare Pages"
else
    echo "❌ Error en el build"
    exit 1
fi
