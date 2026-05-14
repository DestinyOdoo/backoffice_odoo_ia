# BackOffice IA Memory Point (bo_ia_mp)

## Resumen

Módulo para Odoo 17 centrado en la **conexión y lectura de información con IA**. Expone metadatos de aplicaciones y modelos (modelos, tablas, campos) para que sistemas de IA puedan conectarse a Odoo y consumir su esquema de datos.

---

## 1. Objetivo

Habilitar la **conexión y lectura de información entre Odoo e IA**:

- Exponer el esquema de datos de Odoo (modelos, tablas, campos) para consumo por sistemas de IA
- Permitir que asistentes inteligentes, RAG, embeddings o APIs lean y comprendan la estructura de Odoo
- Servir como punto de memoria/contexto para integraciones con IA

---

## 2. Menús y contenido

| Menú | Contenido |
|------|-----------|
| **BO IA Memory Point** (raíz) | Menú principal con icono personalizado |
| **Applications** | Lista de módulos con vista tree, form y kanban |

---

## 3. Vistas

- **Lista (tree)**: Nombre, nombre técnico, estado, resumen, versión. Filtro por defecto: instalados.
- **Formulario**: Nombre, descripción y pestaña **Models** con:
  - **Model**: Nombre técnico del modelo (ej. `sale.order`)
  - **Table Name**: Nombre de tabla en BD (ej. `sale_order`)
  - **Fields**: Campos del modelo separados por comas
- **Kanban**: Tarjetas por aplicación.

---

## 4. Funcionalidades (conexión IA)

- **Exposición de metadatos**: Modelos, tablas y campos disponibles para lectura por sistemas de IA.
- **Load Models**: Carga metadatos de modelos del módulo para consumo por IA.
- **post_init_hook**: Carga modelos de todos los módulos instalados al instalar.
- **Estructura AI-ready**: Datos estructurados para RAG, embeddings, APIs y asistentes.
- **Permisos**: Categoría "Data IA" con User y Manager.

---

## 5. Dependencias

- base
- web

---

## 6. Autor

**BackOffice SAS**  
Web: https://boffice.cloud

---

## 7. Licencia

OPL-1
