#!/usr/bin/env bash

# Force le répertoire courant (où se trouve manage.py) dans le chemin Python
export PYTHONPATH=$PWD

# Lance Gunicorn en utilisant le nom de votre module
# VÉRIFIEZ ENCORE LE NOM : il doit correspondre au dossier qui a settings.py
gunicorn agriculture.wsgi:application