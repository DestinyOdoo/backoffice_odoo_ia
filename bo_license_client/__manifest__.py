# -*- coding: utf-8 -*-
{
    'name': 'BackOffice License Client',
    'version': '17.0.1.0.0',
    'category': 'Tools',
    'summary': 'Cliente de validación de licencias para módulos Odoo protegidos',
    'description': '''
        Cliente de Licenciamiento para Módulos Odoo
        ==========================================
        
        Este módulo valida licencias contra el servidor de BackOffice.
        
        **IMPORTANTE:** Este módulo contiene código de seguridad ofuscado.
        No modifique los archivos de seguridad o el módulo dejará de funcionar.
        
        Características:
        * Validación automática cada 15 días
        * Protección de métodos críticos
        * Almacenamiento seguro de tokens
        * Verificación de UUID de base de datos y dominio
    ''',
    'author': 'BACKOFFICE S.A.S.',
    'website': 'https://www.boffice.cloud/',
    'license': 'LGPL-3',
    'depends': ['base', 'web'],
    'data': [
        'security/groups.xml',
        'security/ir.model.access.csv',
        'data/ir_cron.xml',
        'views/license_config_views.xml',
        'views/license_subscription_wizard_views.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'bo_license_client/static/src/components/subscription_banner.scss',
            'bo_license_client/static/src/components/subscription_banner.xml',
            'bo_license_client/static/src/components/subscription_banner.js',
        ],
    },
    'post_init_hook': 'post_init_hook',
    'uninstall_hook': 'uninstall_hook',
    'installable': True,
    'application': False,
    'auto_install': False,
}