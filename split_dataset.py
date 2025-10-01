import os
import shutil
import random

# Définition du chemin vers le dossier contenant vos 16 dossiers
source_dir = './datasets'

# Dossiers de destination pour l'entraînement et la validation
train_dir = os.path.join(source_dir, 'train')
val_dir = os.path.join(source_dir, 'val')

# Création des dossiers train et val s'ils n'existent pas
os.makedirs(train_dir, exist_ok=True)
os.makedirs(val_dir, exist_ok=True)

# Pourcentage de photos pour l'entraînement
split_ratio = 0.8

print("Début de la répartition des photos...")

# Parcourir chaque dossier de maladie
for class_name in os.listdir(source_dir):
    class_path = os.path.join(source_dir, class_name)
    
    # Ignorer les dossiers 'train' et 'val' s'ils existent déjà
    if class_name in ['train', 'val']:
        continue
    
    if os.path.isdir(class_path):
        # Créer les sous-dossiers dans train et val pour la classe actuelle
        train_class_dir = os.path.join(train_dir, class_name)
        val_class_dir = os.path.join(val_dir, class_name)
        os.makedirs(train_class_dir, exist_ok=True)
        os.makedirs(val_class_dir, exist_ok=True)

        # Lister toutes les photos du dossier de la maladie
        photos = [f for f in os.listdir(class_path) if os.path.isfile(os.path.join(class_path, f))]
        random.shuffle(photos)  # Mélanger les photos aléatoirement

        # Calculer le nombre de photos pour chaque groupe
        split_point = int(len(photos) * split_ratio)
        train_photos = photos[:split_point]
        val_photos = photos[split_point:]

        # Déplacer les photos vers les dossiers train et val
        for photo in train_photos:
            src_path = os.path.join(class_path, photo)
            dest_path = os.path.join(train_class_dir, photo)
            shutil.move(src_path, dest_path)
            
        for photo in val_photos:
            src_path = os.path.join(class_path, photo)
            dest_path = os.path.join(val_class_dir, photo)
            shutil.move(src_path, dest_path)
            
        print(f"Dossier '{class_name}' réparti: {len(train_photos)} pour l'entraînement, {len(val_photos)} pour la validation.")

print("\nRépartition terminée avec succès !")
print("Vos photos sont maintenant dans les dossiers 'train' et 'val' à l'intérieur de 'datasets'.")

# Nettoyer les dossiers de classes originaux s'ils sont vides
for class_name in os.listdir(source_dir):
    class_path = os.path.join(source_dir, class_name)
    if os.path.isdir(class_path) and not os.listdir(class_path) and class_name not in ['train', 'val']:
        os.rmdir(class_path)