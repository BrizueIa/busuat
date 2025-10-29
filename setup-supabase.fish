#!/usr/bin/env fish

# Script para verificar y crear las tablas de Supabase necesarias para el tracking del bus

echo "🔍 Verificando configuración de Supabase..."
echo ""

# Verificar que exista el archivo .env
if not test -f .env
    echo "❌ Error: No se encontró el archivo .env"
    echo "   Crea un archivo .env con tus credenciales de Supabase"
    exit 1
end

echo "✅ Archivo .env encontrado"
echo ""

# Extraer credenciales del .env
set SUPABASE_URL (grep SUPABASE_URL .env | cut -d '=' -f2)
set SUPABASE_ANON_KEY (grep SUPABASE_ANON_KEY .env | cut -d '=' -f2)

echo "📊 Configuración:"
echo "   URL: $SUPABASE_URL"
echo "   ANON_KEY: "(string sub -l 20 $SUPABASE_ANON_KEY)"..."
echo ""

echo "📋 Pasos a seguir:"
echo ""
echo "1. Ve a tu proyecto de Supabase:"
echo "   👉 $SUPABASE_URL"
echo ""
echo "2. Abre el SQL Editor (menú lateral)"
echo ""
echo "3. Copia y ejecuta el SQL del archivo SUPABASE_SETUP.md"
echo "   Este archivo contiene:"
echo "   - Tabla user_locations (ubicaciones de usuarios)"
echo "   - Tabla bus_locations (ubicación del bus)"
echo "   - Políticas de seguridad (RLS)"
echo "   - Índices para optimización"
echo ""
echo "4. IMPORTANTE: Habilita Realtime en las tablas"
echo "   - Ve a Database > Replication"
echo "   - Marca 'Enable Realtime' para user_locations"
echo "   - Marca 'Enable Realtime' para bus_locations"
echo ""
echo "5. Prueba la app:"
echo "   flutter run"
echo ""
echo "✨ Una vez completados estos pasos, la funcionalidad estará lista!"
echo ""
