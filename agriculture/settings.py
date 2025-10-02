# agridiag_ia/settings.py

import os
from pathlib import Path
# Import nécessaire pour la gestion des bases de données de production
import dj_database_url 

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# --- SÉCURITÉ ET DÉPLOIEMENT ---

# SECURITY WARNING: Conservez votre clé secrète actuelle.
SECRET_KEY = 'MAMADOU2005' 

# DÉBOGAGE : Utilise la variable d'environnement 'DEBUG' de Render, par défaut à False.
DEBUG = os.environ.get('DEBUG', 'False') == 'True' 

# NOUVEAU: Autorise toutes les connexions (requis pour l'hébergement cloud comme Render)
ALLOWED_HOSTS = ['*'] 


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # VOTRE APP API : Remplacez par le nom de votre application Django qui gère l'IA.
    'diagnosis_api', 
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    # NOUVEAU: WhiteNoise doit être placé ici (juste après SecurityMiddleware)
    'whitenoise.middleware.WhiteNoiseMiddleware', 
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'agriculture.urls' 

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'agriculture.wsgi.application' 


# --- BASE DE DONNÉES (Configuration de Production) ---
# Utilise dj-database-url pour lire l'URL de la base de données de l'environnement (Render)
# Par défaut, utilise SQLite pour le développement local si aucune variable n'est définie.
DATABASES = {
    'default': dj_database_url.config(
        default='sqlite:///db.sqlite3',
        conn_max_age=600 
    )
}


# Password validation
# (Laissez les validateurs par défaut)
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
LANGUAGE_CODE = 'fr-fr' # Langue par défaut
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True


# --- CONFIGURATION DES FICHIERS STATIQUES (Modèles, etc.) ---

# L'URL utilisée pour accéder aux fichiers statiques
STATIC_URL = 'static/'

# NOUVEAU: Le chemin où WhiteNoise/Render va collecter tous les fichiers statiques pour la production
STATIC_ROOT = BASE_DIR / 'staticfiles' 

# NOUVEAU: Configuration pour que WhiteNoise serve les fichiers statiques (plus rapide et compressé)
STORAGES = {
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'