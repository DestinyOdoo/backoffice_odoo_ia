# -*- coding: utf-8 -*-
{
    "name": "BackOffice IA Memory Point",
    "summary": "Connect Odoo to AI: expose apps and models metadata for AI reading and integration.",
    "description": """
    BackOffice IA Memory Point - AI Connection & Data Reading
    =========================================================
    Expose Odoo application and model metadata for AI systems to connect,
    read and consume. Provides structured data (models, tables, fields) so
    AI can understand and query Odoo's data schema.
    - Browse applications (modules) with model metadata
    - AI-ready schema: model name, table name, fields per model
    - Designed for AI connectors, RAG, embeddings and intelligent assistants
    """,
    "author": "BackOffice SAS",
    "website": "https://boffice.cloud",
    "category": "Productivity",
    "version": "17.0.1.7.0",
    "license": "OPL-1",
    "depends": ["base", "web", "bo_license_client"],
    "images": [
        "static/description/main_screenshot.png",
    ],
    "data": [
        "data/bo_ia_mp_data.xml",
        "data/bo_ia_mp_cron.xml",
        "security/bo_ia_mp_security.xml",
        "security/ir.model.access.csv",
        "views/bo_ia_mp_module_model_info_views.xml",
        "views/bo_ia_mp_saved_query_views.xml",
        "views/bo_ia_mp_query_execution_views.xml",
        "views/bo_ia_mp_api_log_views.xml",
        "views/bo_ia_mp_views.xml",
        "views/bo_ia_mp_menus.xml",
    ],
    "post_init_hook": "post_init_hook",
    "application": True,
}
