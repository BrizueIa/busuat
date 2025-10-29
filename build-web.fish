#!/usr/bin/env fish

# Script para compilar la app web con la API key de Google Maps
# Uso: ./build-web.fish <API_KEY>

# Verificar que se proporcionó la API key
if test (count $argv) -lt 1
    echo "❌ Error: Debes proporcionar tu API key de Google Maps"
    echo "Uso: ./build-web.fish <TU_API_KEY>"
    exit 1
end

set API_KEY $argv[1]
set INDEX_FILE "web/index.html"
set BACKUP_FILE "web/index.html.bak"

echo "🔧 Configurando Google Maps API key..."

# Hacer backup del archivo original
if test -f $INDEX_FILE
    cp $INDEX_FILE $BACKUP_FILE
    echo "✅ Backup creado: $BACKUP_FILE"
end

# Reemplazar la API key
sed -i "s/TU_API_KEY/$API_KEY/g" $INDEX_FILE
echo "✅ API key configurada"

echo ""
echo "🚀 Compilando Flutter Web..."
flutter build web --release

# Restaurar el archivo original (para no commitear la API key)
if test -f $BACKUP_FILE
    mv $BACKUP_FILE $INDEX_FILE
    echo "✅ Archivo index.html restaurado"
end

echo ""
echo "✨ Build completado!"
echo "📁 Los archivos están en: build/web/"
echo ""
echo "Para probar localmente, ejecuta:"
echo "  cd build/web && python -m http.server 8000"
echo "  Luego abre: http://localhost:8000"
