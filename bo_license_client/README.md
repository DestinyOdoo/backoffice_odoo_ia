# BackOffice License Client

Cliente Odoo 17 que valida licencias contra el servidor BackOffice y protege módulos del catálogo licenciado.

**Dependencias:** `base`, `web` · **No modificar** `security/security.py` en distribución (código sensible / ofuscado).

---

## Instalación

1. Copiar el módulo en `addons` e instalar `requests` si falta: `pip install requests`
2. En Odoo: actualizar lista de aplicaciones → instalar **BackOffice License Client**
3. Al instalar se ejecuta validación contra el servidor (`post_init_hook`) y se genera `backoffice.license.bearer_token` si no existe

---

## Flujo resumido

| Paso | Qué pasa |
|------|----------|
| **Instalar** | Se consulta el servidor con `database.uuid` y dominio (`web.base.url`). Si hay licencia, se guardan token y metadatos en `ir.config_parameter` (`backoffice.license.*`). |
| **Uso diario** | `check_license_status` lee caché local (sin llamar al servidor). El cron revalida cada ~15 días o si cambian UUID/dominio. |
| **Manual** | Menú **Configuración → Licencia** → *Validar licencia ahora* o *Actualizar suscripción* (portal RBAC). |
| **Desinstalar / reinstalar** | `uninstall_hook` borra `backoffice.license.*`. Al reinstalar se limpia caché y se vuelve a validar; si el servidor no tiene licencia, el estado local queda inválido. |
| **Módulos protegidos** | Otros addons usan `@require_valid_license` o `security.is_license_valid(env)`; sin licencia válida, operaciones críticas se bloquean. |

---

## Parámetros útiles (`ir.config_parameter`)

| Clave | Uso |
|-------|-----|
| `backoffice.license.token` / `.expiration` / `.data` | Datos de licencia validada |
| `backoffice.license.bearer_token` | Bearer para integraciones (p. ej. API `bo_ia_mp/token`) |
| `token.ia.bo` | Token IA (compartido con `bo_ia_mp`) |

Consulta: **Ajustes → Técnico → Parámetros del sistema**.

---

## Desarrollo

```python
from odoo.addons.bo_license_client.security import security

success, message = security.validate_license(env, force=True)
is_valid, info = security.check_license_status(env)
```

```python
from odoo.addons.bo_license_client.security.security import require_valid_license

@require_valid_license
def metodo_protegido(self):
    ...
```

Ofuscación y empaquetado: ver `docs/OBFUSCATION_GUIDE.md` (si aplica en tu entrega).

---

## Soporte

- https://www.boffice.cloud/
- soporte@boffice.cloud

Licencia: LGPL-3 · © BackOffice SAS
