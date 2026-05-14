# 🔐 Guía de Ofuscación con PyArmor

## BackOffice License Client - Seguridad del Módulo

Esta guía explica cómo ofuscar el archivo `security.py` del módulo `bo_license_client` antes de distribuirlo a los clientes.

---

## ⚠️ IMPORTANTE

**El archivo `security.py` DEBE ser ofuscado antes de distribuir el módulo a clientes.**

Sin la ofuscación, cualquier desarrollador podría:
- Ver la lógica de validación de licencias
- Comentar las líneas de verificación
- Bypassear el sistema de licenciamiento

---

## 📋 Requisitos Previos

1. **Python 3.7+** instalado
2. **PyArmor** instalado:
   ```bash
   pip install pyarmor
   ```

3. Acceso al código fuente del módulo

---

## 🚀 Proceso de Ofuscación

### Paso 1: Preparar el Entorno

```bash
# Navegar al directorio del módulo
cd /path/to/bo_license_client

# Crear un directorio para la salida
mkdir -p dist/bo_license_client_obfuscated
```

### Paso 2: Ofuscar el Archivo security.py

#### Opción A: Ofuscación Básica

```bash
pyarmor obfuscate \
    --output dist/bo_license_client_obfuscated/security \
    --recursive \
    security/security.py
```

#### Opción B: Ofuscación Avanzada (Recomendada)

```bash
pyarmor obfuscate \
    --output dist/bo_license_client_obfuscated/security \
    --recursive \
    --restrict \
    --advanced \
    security/security.py
```

**Parámetros explicados:**
- `--output`: Directorio de salida
- `--recursive`: Ofuscar también las importaciones
- `--restrict`: Modo restringido (más seguro)
- `--advanced`: Modo avanzado de ofuscación

#### Opción C: Ofuscación con Vinculación a Hardware (Máxima Seguridad)

```bash
# Obtener el identificador del hardware del cliente
pyarmor hdinfo

# Ofuscar vinculando al hardware específico
pyarmor obfuscate \
    --output dist/bo_license_client_obfuscated/security \
    --recursive \
    --restrict \
    --bind-mac XX:XX:XX:XX:XX:XX \
    security/security.py
```

### Paso 3: Copiar el Módulo Completo

```bash
# Copiar todo el módulo a dist
cp -r ../bo_license_client dist/bo_license_client_obfuscated/

# Reemplazar security.py original con la versión ofuscada
rm dist/bo_license_client_obfuscated/bo_license_client/security/security.py
cp dist/bo_license_client_obfuscated/security/security.py \
   dist/bo_license_client_obfuscated/bo_license_client/security/

# Copiar archivos de runtime de PyArmor
cp -r dist/bo_license_client_obfuscated/security/pytransform \
   dist/bo_license_client_obfuscated/bo_license_client/security/
```

### Paso 4: Verificar la Ofuscación

```bash
# Ver el contenido ofuscado
cat dist/bo_license_client_obfuscated/bo_license_client/security/security.py
```

Deberías ver código ofuscado similar a:
```python
from pytransform import pyarmor_runtime
pyarmor_runtime()
__pyarmor__(__name__, __file__, b'...[bytecode ofuscado]...')
```

### Paso 5: Empaquetar para Distribución

```bash
# Crear archivo ZIP del módulo ofuscado
cd dist/bo_license_client_obfuscated
zip -r bo_license_client_v1.0.0.zip bo_license_client/
```

---

## 🧪 Pruebas Después de la Ofuscación

### 1. Probar el Módulo Ofuscado Localmente

```bash
# Copiar el módulo ofuscado a tu instancia de Odoo
cp -r dist/bo_license_client_obfuscated/bo_license_client \
   /path/to/odoo/addons/

# Reiniciar Odoo
odoo-bin -c odoo.conf -u bo_license_client

# Verificar logs
tail -f /var/log/odoo/odoo.log
```

### 2. Verificar Funcionalidad

1. **Instalar el módulo** en una base de datos de prueba
2. **Verificar que la validación funcione:**
   - Ir a Configuración → Licencia
   - Hacer clic en "Validar Licencia Ahora"
   - Verificar que se conecte al servidor y obtenga un token

3. **Verificar el cron:**
   ```python
   # En Odoo shell
   env['ir.cron'].search([('name', '=', 'BackOffice: Validar Licencia')]).method_direct_trigger()
   ```

### 3. Verificar que NO se Pueda Leer el Código

Intenta abrir `security.py` en un editor:
- ✅ **Correcto:** Deberías ver código ofuscado incomprensible
- ❌ **Incorrecto:** Si ves el código original, la ofuscación falló

---

## 📦 Estructura del Módulo Ofuscado

```
bo_license_client/
├── __init__.py
├── __manifest__.py
├── models/
│   ├── __init__.py
│   └── license_config.py
├── security/
│   ├── __init__.py
│   ├── security.py (OFUSCADO)
│   ├── pytransform/          # Runtime de PyArmor
│   │   ├── __init__.py
│   │   └── _pytransform.so   # Biblioteca de PyArmor
│   └── ir.model.access.csv
├── data/
│   └── ir_cron.xml
├── views/
│   └── license_config_views.xml
└── docs/
    └── OBFUSCATION_GUIDE.md
```

---

## 🔧 Solución de Problemas

### Error: "No module named 'pytransform'"

**Causa:** Los archivos de runtime de PyArmor no se copiaron correctamente.

**Solución:**
```bash
# Copiar manualmente el directorio pytransform
cp -r dist/security/pytransform bo_license_client/security/
```

### Error: "License file not found"

**Causa:** Los archivos de licencia de PyArmor no están en el lugar correcto.

**Solución:**
```bash
# Verificar que existan estos archivos:
ls bo_license_client/security/pytransform/license.lic
```

### El código sigue siendo legible

**Causa:** La ofuscación no se aplicó correctamente.

**Solución:**
1. Verificar que PyArmor esté actualizado: `pip install --upgrade pyarmor`
2. Usar el modo `--advanced` en la ofuscación
3. Limpiar archivos .pyc: `find . -name "*.pyc" -delete`

---

## 🛡️ Mejores Prácticas de Seguridad

### 1. No Distribuir el Código Fuente Original

- ❌ NUNCA subir `security.py` sin ofuscar a GitHub o repositorios públicos
- ✅ Mantener el código fuente original en un repositorio privado
- ✅ Solo distribuir versiones ofuscadas a clientes

### 2. Usar Diferentes Niveles de Ofuscación

Para diferentes tipos de clientes:

- **Trial/Demo:** Ofuscación básica + expiración de fecha
- **Clientes Estándar:** Ofuscación avanzada + validación remota
- **Clientes Enterprise:** Ofuscación avanzada + vinculación a hardware

### 3. Renovación de Ofuscación

Cada vez que actualices `security.py`:
1. Probar cambios con código sin ofuscar
2. Ofuscar la nueva versión
3. Probar versión ofuscada
4. Distribuir

### 4. Mantener Registro de Versiones

```bash
# Nombrar archivos con versión
bo_license_client_v1.0.0_obfuscated.zip
bo_license_client_v1.1.0_obfuscated.zip
```

---

## 📝 Script Automatizado de Ofuscación

Crear un script `obfuscate.sh`:

```bash
#!/bin/bash

# Script para ofuscar bo_license_client

VERSION="1.0.0"
MODULE_NAME="bo_license_client"
OUTPUT_DIR="dist/${MODULE_NAME}_${VERSION}_obfuscated"

echo "🔐 Iniciando ofuscación de $MODULE_NAME v$VERSION..."

# Limpiar salida anterior
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Ofuscar security.py
echo "📝 Ofuscando security.py..."
pyarmor obfuscate \
    --output $OUTPUT_DIR/security \
    --recursive \
    --restrict \
    --advanced \
    security/security.py

# Copiar módulo completo
echo "📦 Copiando módulo completo..."
cp -r . $OUTPUT_DIR/$MODULE_NAME

# Reemplazar con versión ofuscada
echo "🔄 Reemplazando con versión ofuscada..."
rm $OUTPUT_DIR/$MODULE_NAME/security/security.py
cp $OUTPUT_DIR/security/security.py $OUTPUT_DIR/$MODULE_NAME/security/
cp -r $OUTPUT_DIR/security/pytransform $OUTPUT_DIR/$MODULE_NAME/security/

# Limpiar archivos innecesarios
echo "🧹 Limpiando..."
rm -rf $OUTPUT_DIR/$MODULE_NAME/.git
rm -rf $OUTPUT_DIR/$MODULE_NAME/__pycache__
find $OUTPUT_DIR/$MODULE_NAME -name "*.pyc" -delete

# Crear ZIP
echo "📦 Empaquetando..."
cd $OUTPUT_DIR
zip -r ${MODULE_NAME}_v${VERSION}.zip $MODULE_NAME/
cd -

echo "✅ Ofuscación completada!"
echo "📁 Archivo de salida: $OUTPUT_DIR/${MODULE_NAME}_v${VERSION}.zip"
```

Hacer ejecutable:
```bash
chmod +x obfuscate.sh
./obfuscate.sh
```

---

## 📞 Soporte

Si tienes problemas con la ofuscación, contacta al equipo de desarrollo de BackOffice.

---

## ⚖️ Licencia

Este documento es propiedad de BackOffice y es confidencial.
No distribuir sin autorización.

---

**Última actualización:** Enero 2025
**Versión del documento:** 1.0
