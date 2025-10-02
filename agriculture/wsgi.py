"""
WSGI config for agricul_ia project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application

# CORRECTION : Le module de configuration doit être 'agriculture.settings'
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'agriculture.settings')

application = get_wsgi_application()
