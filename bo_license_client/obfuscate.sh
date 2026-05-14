#!/bin/bash

# =====================================================
# Script de Ofuscación para bo_license_client
# =====================================================

VERSION="1.0.0"
MODULE_NAME="bo_license_client"
OUTPUT_DIR="dist/${MODULE_NAME}_${VERSION}_obfuscated"

echo "🔐 Iniciando ofuscación de $MODULE_NAME v$VERSION..."
echo ""

# Verificar que PyArmor esté instalado
if ! command -v pyarmor &> /dev/null; then
    echo "❌ Error: PyArmor no está instalado"
    echo "Instalar con: pip install pyarmor"
    exit 1
fi

echo "✓ PyArmor encontrado: $(pyarmor --version)"
echo ""

# Limpiar salida anterior
if [ -d "$OUTPUT_DIR" ]; then
    echo "🧹 Limpiando salida anterior..."
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

# Ofuscar security.py
echo "📝 Ofuscando security.py..."
pyarmor obfuscate \
    --output "$OUTPUT_DIR/security" \
    --recursive \
    --restrict \
    --advanced \
    security/security.py

if [ $? -ne 0 ]; then
    echo "❌ Error en la ofuscación"
    exit 1
fi

echo "✓ Ofuscación completada"
echo ""

# Copiar módulo completo
echo "📦 Copiando módulo completo..."
cp -r . "$OUTPUT_DIR/$MODULE_NAME"

# Excluir archivos innecesarios
rm -rf "$OUTPUT_DIR/$MODULE_NAME/.git"
rm -rf "$OUTPUT_DIR/$MODULE_NAME/__pycache__"
rm -rf "$OUTPUT_DIR/$MODULE_NAME/dist"
rm -rf "$OUTPUT_DIR/$MODULE_NAME/build"
find "$OUTPUT_DIR/$MODULE_NAME" -name "*.pyc" -delete
find "$OUTPUT_DIR/$MODULE_NAME" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null

echo "✓ Módulo copiado"
echo ""

# Reemplazar con versión ofuscada
echo "🔄 Reemplazando con versión ofuscada..."
rm "$OUTPUT_DIR/$MODULE_NAME/security/security.py"
cp "$OUTPUT_DIR/security/security.py" "$OUTPUT_DIR/$MODULE_NAME/security/"
cp -r "$OUTPUT_DIR/security/pytransform" "$OUTPUT_DIR/$MODULE_NAME/security/"

echo "✓ Archivos reemplazados"
echo ""

# Verificar estructura
echo "📋 Verificando estructura..."

if [ ! -f "$OUTPUT_DIR/$MODULE_NAME/security/security.py" ]; then
    echo "❌ Error: security.py no encontrado"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR/$MODULE_NAME/security/pytransform" ]; then
    echo "❌ Error: directorio pytransform no encontrado"
    exit 1
fi

echo "✓ Estructura verificada"
echo ""

# Crear ZIP
echo "📦 Empaquetando..."
cd "$OUTPUT_DIR"
zip -r "${MODULE_NAME}_v${VERSION}.zip" "$MODULE_NAME/" > /dev/null
cd - > /dev/null

echo "✓ Empaquetado completado"
echo ""

echo "╔═══════════════════════════════════════════════════╗"
echo "║  ✅ OFUSCACIÓN COMPLETADA EXITOSAMENTE           ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
echo "📁 Ubicación:"
echo "   $OUTPUT_DIR/${MODULE_NAME}_v${VERSION}.zip"
echo ""
echo "📊 Tamaño del archivo:"
du -h "$OUTPUT_DIR/${MODULE_NAME}_v${VERSION}.zip"
echo ""
echo "🎯 Próximos pasos:"
echo "   1. Probar el módulo ofuscado en una instancia local"
echo "   2. Verificar que la validación funcione correctamente"
echo "   3. Distribuir el archivo ZIP a los clientes"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   • NO distribuir el código fuente original (security.py sin ofuscar)"
echo "   • Mantener este script y el código fuente en repositorio privado"
echo "   • Solo distribuir el archivo ZIP generado"
echo ""
