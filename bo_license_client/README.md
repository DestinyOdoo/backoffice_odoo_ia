# 🔐 BackOffice License Client

## Cliente de Validación de Licencias para Módulos Odoo

### Descripción

Módulo cliente que valida licencias contra el servidor de BackOffice y protege módulos de Odoo.

⚠️ **IMPORTANTE:** Este módulo contiene código de seguridad ofuscado. No modifique los archivos de seguridad.

---

## ✨ Características

- 🔄 **Validación Automática**
  - Validación al instalar el módulo
  - Re-validación cada 15 días mediante cron
  - Re-validación si cambia el UUID o dominio

- 🔒 **Protección de Métodos**
  - Decorador `@require_valid_license` para proteger métodos críticos
  - Bloqueo automático si la licencia expira

- 💾 **Almacenamiento Seguro**
  - Tokens JWT almacenados en `ir.config_parameter`
  - Verificación de integridad de datos

- 🚫 **Detección de Manipulación**
  - Detecta cambios en UUID de base de datos
  - Detecta cambios en dominio/IP del servidor
  - Requiere re-validación si se detectan cambios

- 🔐 **Código Ofuscado**
  - Archivo `security.py` ofuscado con PyArmor
  - Protección contra ingeniería inversa

---

## 📦 Instalación

### Para Desarrolladores (Código sin Ofuscar)

1. Copiar el módulo:
   ```bash
   cp -r bo_license_client /path/to/odoo/addons/
   ```

2. Instalar dependencias Python:
   ```bash
   pip install requests
   ```

3. Actualizar lista de módulos en Odoo

4. Instalar el módulo

### Para Clientes (Código Ofuscado)

1. Descomprimir el archivo ZIP recibido:
   ```bash
   unzip bo_license_client_v1.0.0.zip
   ```

2. Copiar a la carpeta de addons:
   ```bash
   cp -r bo_license_client /path/to/odoo/addons/
   ```

3. Reiniciar Odoo:
   ```bash
   sudo systemctl restart odoo
   ```

4. Instalar el módulo desde la interfaz de Odoo

---

## 🚀 Uso

### Configuración Inicial

1. **Obtener el UUID de tu base de datos:**
   ```sql
   SELECT value FROM ir_config_parameter WHERE key='database.uuid';
   ```

2. **Obtener tu dominio:**
   ```sql
   SELECT value FROM ir_config_parameter WHERE key='web.base.url';
   ```

3. **Enviar estos datos a BackOffice** para que registren tu licencia

4. **Instalar el módulo** - la validación se ejecutará automáticamente

### Ver Estado de la Licencia

1. Ir a **Configuración → Licencia**
2. Ver el estado actual:
   - ✅ Licencia Válida
   - ❌ Licencia Inválida
   - ⚠️ Error

3. Hacer clic en **Validar Licencia Ahora** para forzar una validación

### Validación Manual (Desde Código)

```python
from odoo.addons.bo_license_client.security import security

# Validar licencia
success, message = security.validate_license(env)

if success:
    print(f"✅ {message}")
else:
    print(f"❌ {message}")

# Verificar estado sin conectar al servidor
is_valid, info = security.check_license_status(env)

if is_valid:
    print(f"Tipo: {info['license_type']}")
    print(f"Cliente: {info['client_name']}")
    print(f"Expira: {info['expiration_date']}")
```

### Proteger Métodos con el Decorador

```python
from odoo import models, fields, api
from odoo.addons.bo_license_client.security.security import require_valid_license

class MiModelo(models.Model):
    _name = 'mi.modelo'
    
    @require_valid_license
    def metodo_protegido(self):
        """Este método solo funcionará con licencia válida"""
        # Tu código aquí
        return True
    
    def metodo_normal(self):
        """Este método funciona sin licencia"""
        return True
```

Si la licencia no es válida, el usuario verá:
```
AccessError: Licencia inválida o expirada. Por favor, contacte a soporte para renovar su licencia.
```

---

## ⚙️ Configuración

### Cambiar el Servidor de Licencias

Editar `/security/security.py` (ANTES de ofuscar):

```python
# Cambiar estas constantes
LICENSE_SERVER_STAGE = 'https://tu-servidor-stage.odoo.com'
LICENSE_SERVER_PRODUCTION = 'https://tu-servidor-prod.odoo.com'

# Usar producción o stage
LICENSE_SERVER_URL = LICENSE_SERVER_PRODUCTION
```

### Cambiar la Frecuencia de Validación

1. Ir a **Configuración → Técnico → Automatización → Acciones Programadas**
2. Buscar "BackOffice: Validar Licencia"
3. Modificar el intervalo (por defecto: 1 día)

### Ajustar el Periodo de Gracia

Editar `/security/security.py` (ANTES de ofuscar):

```python
VALIDATION_GRACE_PERIOD_DAYS = 2  # Cambiar a los días deseados
```

---

## 🔒 Ofuscación (Para Desarrolladores)

**⚠️ CRITICO:** Antes de distribuir este módulo, debes ofuscar `security.py`

Ver la guía completa en: `/docs/OBFUSCATION_GUIDE.md`

**Resumen rápido:**

```bash
# Instalar PyArmor
pip install pyarmor

# Ofuscar
pyarmor obfuscate \
    --output dist/security \
    --recursive \
    --restrict \
    --advanced \
    security/security.py

# Copiar archivos ofuscados
cp dist/security/security.py security/
cp -r dist/security/pytransform security/

# Distribuir
zip -r bo_license_client_v1.0.0.zip bo_license_client/
```

---

## 📚 Estructura del Código

```
bo_license_client/
├── __init__.py
├── __manifest__.py
├── models/
│   ├── __init__.py
│   └── license_config.py      # Modelo de configuración
├── security/
│   ├── __init__.py
│   ├── security.py            # ⚠️ ARCHIVO A OFUSCAR
│   ├── pytransform/           # Runtime de PyArmor (después de ofuscar)
│   └── ir.model.access.csv
├── data/
│   └── ir_cron.xml            # Cron de validación
├── views/
│   └── license_config_views.xml
└── docs/
    └── OBFUSCATION_GUIDE.md   # Guía de ofuscación
```

---

## 🐛 Solución de Problemas

### Error: "No se pudo obtener el UUID de la base de datos"

**Causa:** El parámetro `database.uuid` no existe.

**Solución:**
```sql
INSERT INTO ir_config_parameter (key, value) 
VALUES ('database.uuid', gen_random_uuid()::text);
```

### Error: "No se pudo obtener el dominio del servidor"

**Causa:** El parámetro `web.base.url` no está configurado.

**Solución:**
1. Ir a **Configuración → General → Parámetros del Sistema**
2. Buscar `web.base.url`
3. Establecer: `https://tu-dominio.odoo.com`

### Error: "Licencia inválida o expirada"

**Verificar:**
1. ¿La licencia fue creada en el servidor?
2. ¿El UUID coincide exactamente?
3. ¿El dominio coincide exactamente?
4. ¿La licencia está activa en el servidor?
5. ¿No ha expirado?

**Forzar validación:**
```python
# En Odoo shell
from odoo.addons.bo_license_client.security import security
success, message = security.validate_license(env, force=True)
print(message)
```

### Error: "No module named 'pytransform'"

**Causa:** Falta el runtime de PyArmor (solo en versión ofuscada).

**Solución:**
1. Verificar que existe `/security/pytransform/`
2. Reinstalar el módulo completo

### El Cron no se ejecuta

**Verificar:**
1. Ir a **Configuración → Técnico → Acciones Programadas**
2. Buscar "BackOffice: Validar Licencia"
3. Verificar que esté **Activo**
4. Hacer clic en **Ejecutar Manualmente** para probar

---

## 🛡️ Seguridad

### ¿Qué protege este módulo?

✅ **Protege contra:**
- Copia no autorizada de módulos
- Uso después de expiración de licencia
- Transferencia a otro servidor sin autorización
- Lectura del código de validación (ofuscado)

⚠️ **NO protege contra:**
- Ingeniería inversa avanzada de la ofuscación
- Modificación del código Python de otros archivos
- Acceso directo a la base de datos para modificar parámetros

### Mejores Prácticas

1. **Siempre ofuscar** antes de distribuir
2. **Usar diferentes niveles de ofuscación** para diferentes clientes
3. **Monitorear validaciones** en el servidor para detectar anomalías
4. **Combinar con otros métodos** (hardw are binding, watermarks, etc.)

---

## 📝 Changelog

### Version 1.0.0 (2025-01-31)

- ✨ Lanzamiento inicial
- ✅ Validación contra servidor de licencias
- ✅ Almacenamiento seguro de tokens
- ✅ Decorador de protección de métodos
- ✅ Detección de cambios en sistema
- ✅ Cron de re-validación
- ✅ Guía de ofuscación

---

## 📞 Soporte

Para soporte técnico:
- **Email:** soporte@boffice.cloud
- **Web:** https://www.boffice.cloud/

---

## ©️ Licencia

LGPL-3

© 2025 BackOffice. Todos los derechos reservados.
