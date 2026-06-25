# Reporte del Módulo BO IA MP (BackOffice IA Memory Point)

**Versión:** 17.0.1.0.0  
**Autor:** BackOffice SAS  
**Categoría:** Productivity

---

## 1. Objetivo del Módulo

**BO IA MP** (BackOffice IA Memory Point) es un módulo para **Odoo 17** que actúa como punto de memoria y conexión entre Odoo y sistemas de Inteligencia Artificial. Su objetivo principal es:

> **Exponer metadatos y datos estructurados de Odoo** (aplicaciones, modelos, tablas, campos, consultas guardadas y resultados históricos) de forma que sistemas de IA, conectores, RAG, embeddings o asistentes inteligentes puedan **leer, consumir y generar reportes** sin necesidad de acceder directamente a la base de datos.

El módulo permite a los gerentes y a la IA tener acceso controlado a información de contexto sobre el esquema de datos de Odoo, muestras de registros por tabla, consultas predefinidas ejecutadas en distintos períodos (hora, día, semana, mes) y todo ello mediante una **API REST** para integración externa.

---

## 2. Funciones y Funcionalidades

### 2.1 Catálogo de Aplicaciones y Modelos

| Función | Descripción |
|--------|-------------|
| **Carga de modelos** | Vincula cada módulo instalado (`ir.module.module`) con sus modelos registrados en `ir.model`, creando registros en `bo.ia.mp.module.model.info`. |
| **Información de tablas** | Expone el nombre técnico del modelo, el nombre de la tabla en PostgreSQL (convención: `x.y.z` → `x_y_z`) y la lista de campos. |
| **Muestra de datos** | Para cada modelo, permite cargar un JSON con registros de muestra usando un simple `SELECT * FROM tabla LIMIT N` (sin ORM, para evitar errores de modelos abstractos o complejos). |

### 2.2 Parámetro de Configuración

| Parámetro | Clave | Valor por defecto | Descripción |
|-----------|-------|-------------------|-------------|
| Límite de registros de muestra | `bo_ia_mp.sample_record_limit` | 100 | Cantidad máxima de registros a incluir en `sample_data_json` por tabla. Configurable en **Configuración → Técnico → Parámetros del sistema**. |

### 2.3 Consultas Guardadas (Saved Queries)

| Función | Descripción |
|--------|-------------|
| **Guardar consultas** | Permite almacenar consultas SQL que usan placeholders de fecha/hora. |
| **Validación SELECT-only** | Solo acepta `SELECT` o `WITH` (CTEs). Rechaza INSERT, UPDATE, DELETE, DROP, CREATE, ALTER, etc. |
| **Placeholders** | `{{date_from}}`, `{{date_to}}`, `{{datetime_from}}`, `{{datetime_to}}` se sustituyen automáticamente al ejecutar. |

### 2.4 Ejecución Programada de Queries

| Función | Descripción |
|--------|-------------|
| **Ejecución horaria** | Cada hora se ejecutan todas las queries activas para la ventana de la hora actual. |
| **Ejecución diaria** | A las 00:xx se ejecutan para el día anterior completo. |
| **Ejecución semanal** | El lunes a las 00:xx se ejecutan para la semana anterior (lunes a domingo). |
| **Ejecución mensual** | El día 1 a las 00:xx se ejecutan para el mes anterior completo. |
| **Almacenamiento** | Los resultados se guardan en `bo.ia.mp.query.execution` con `period_type`, `period_start`, `period_end` y `result_json`. |

### 2.5 Post-instalación (Hook)

| Función | Descripción |
|--------|-------------|
| **post_init_hook** | Al instalar el módulo, carga modelos de todos los módulos instalados y ejecuta `action_load_sample_data` para llenar `sample_data_json`. Realiza commits periódicos para evitar timeouts. |

### 2.6 Permisos

| Grupo | Descripción | Modelos afectados |
|-------|-------------|-------------------|
| **Data IA / User** | Solo lectura | Module Model Info, Saved Query, Query Execution |
| **Data IA / Manager** | Lectura, escritura, creación, eliminación | Todos los modelos del módulo |

---

## 3. Descripción de la API y Ejemplos

Base URL: `https://destinyodoo-odoo-destiny-stage-28210784.dev.odoo.com/api/bo_ia_mp`

**Nota:** Estos endpoints usan autenticación por sesión de usuario. Para integración externa con API Key/Secret, debe configurarse en el módulo o usar la cookie de sesión de Odoo.

---

### 3.1 Crear Consulta Guardada

**Endpoint**
```
https://destinyodoo-odoo-destiny-stage-28210784.dev.odoo.com/api/bo_ia_mp/saved_query
```

**Header**
```
Content-Type: application/json
X-API-Key: XF_UpZ_-QxcbCdEXo6gWvca91GKc45c_Tu2nZNQs9e0
X-API-Secret: tUl87-eaWOlJ34RpX-6FDac789AYBBNSN3p4ZUXDrXw
Cookie: session_id=<tu_session_id>
```

**Body**
```json
{
  "name": "ventas_confirmadas",
  "query": "SELECT id, name, partner_id, amount_total, date_order FROM sale_order WHERE date_order >= '{{datetime_from}}' AND date_order <= '{{datetime_to}}' AND state = 'sale'",
  "description": "Órdenes de venta confirmadas por período"
}
```

**JSON entregado**
```json
{
  "id": 5,
  "name": "ventas_confirmadas",
  "message": "Query saved successfully"
}
```

**JSON error (400)**
```json
{
  "error": "Only SELECT queries are allowed. UPDATE, INSERT, DELETE and other write operations are forbidden."
}
```

---

### 3.2 Listar Consultas Guardadas

**Endpoint**
```
https://destinyodoo-odoo-destiny-stage-28210784.dev.odoo.com/api/bo_ia_mp/saved_query
```

**Header**
```
X-API-Key: XF_UpZ_-QxcbCdEXo6gWvca91GKc45c_Tu2nZNQs9e0
X-API-Secret: tUl87-eaWOlJ34RpX-6FDac789AYBBNSN3p4ZUXDrXw
Cookie: session_id=<tu_session_id>
```

**Query params (opcionales)**
- `include_inactive=1` — Incluir consultas desactivadas

**Body**
```
(sin body - petición GET)
```

**JSON entregado**
```json
{
  "queries": [
    {
      "id": 1,
      "name": "ventas_confirmadas",
      "query": "SELECT id, name, partner_id FROM sale_order WHERE date_order >= '{{datetime_from}}' AND date_order <= '{{datetime_to}}'",
      "description": "Órdenes de venta por período"
    },
    {
      "id": 2,
      "name": "facturas_mes",
      "query": "SELECT * FROM account_move WHERE move_type = 'out_invoice' AND date >= '{{date_from}}' AND date <= '{{date_to}}'",
      "description": "Facturas de cliente del período"
    }
  ]
}
```

---

### 3.3 Ejecutar Todas las Consultas

**Endpoint**
```
https://destinyodoo-odoo-destiny-stage-28210784.dev.odoo.com/api/bo_ia_mp/saved_query/execute
```

**Header**
```
Content-Type: application/json
X-API-Key: XF_UpZ_-QxcbCdEXo6gWvca91GKc45c_Tu2nZNQs9e0
X-API-Secret: tUl87-eaWOlJ34RpX-6FDac789AYBBNSN3p4ZUXDrXw
Cookie: session_id=<tu_session_id>
```

**Body**
```json
{}
```

**JSON entregado**
```json
{
  "message": "Queries executed successfully"
}
```

---

### 3.4 Desactivar Consulta

**Endpoint**
```
https://destinyodoo-odoo-destiny-stage-28210784.dev.odoo.com/api/bo_ia_mp/saved_query/5
```

**Header**
```
X-API-Key: XF_UpZ_-QxcbCdEXo6gWvca91GKc45c_Tu2nZNQs9e0
X-API-Secret: tUl87-eaWOlJ34RpX-6FDac789AYBBNSN3p4ZUXDrXw
Cookie: session_id=<tu_session_id>
```

**Body**
```
(sin body - petición DELETE)
```

**JSON entregado**
```json
{
  "message": "Query deactivated"
}
```

**JSON error (404)**
```json
{
  "error": "Query not found"
}
```

---

## 4. Placeholders para Queries con Fecha/Hora

| Placeholder | Formato | Uso |
|-------------|---------|-----|
| `{{date_from}}` | YYYY-MM-DD | Fecha inicio (solo fecha) |
| `{{date_to}}` | YYYY-MM-DD | Fecha fin (solo fecha) |
| `{{datetime_from}}` | YYYY-MM-DD HH:MM:SS | Inicio con hora |
| `{{datetime_to}}` | YYYY-MM-DD HH:MM:SS | Fin con hora |

**Ejemplo de query con placeholders:**
```sql
SELECT 
  id, name, date_order, amount_total
FROM sale_order
WHERE date_order >= '{{datetime_from}}'
  AND date_order <= '{{datetime_to}}'
  AND state = 'sale'
ORDER BY date_order
```

---

## 5. Resumen de Modelos

| Modelo | Descripción |
|--------|-------------|
| `bo.ia.mp.module.model.info` | Metadatos por modelo: tabla, campos, sample_data_json |
| `bo.ia.mp.saved.query` | Consultas guardadas (SELECT-only) |
| `bo.ia.mp.query.execution` | Resultados de ejecución por período (hourly/daily/weekly/monthly) |

---

## 6. Menús de la Aplicación

- **BO IA Memory Point** (raíz)
  - **Applications** — Catálogo de módulos con modelos y sample data
  - **Saved Queries** — Consultas guardadas (solo Manager)
  - **Query Executions** — Historial de ejecuciones (solo Manager)
