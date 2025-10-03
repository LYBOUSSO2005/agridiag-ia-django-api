# diagnosis_api/ai_model.py

# Garder les imports non-PyTorch en haut
from PIL import Image
import io
import os
from django.conf import settings 

# Déclarer les variables globales pour PyTorch/Torchvision
torch = None
models = None
transforms = None
# ... (le reste de vos constantes)

# Le dictionnaire qui associe l'index à la classe (maladie/plante)
class_names = [
    'Anthracnose_mangue', 'Brûlure_bactérienne_des_feuilles', 'Chancre_bacterien_mangue', 
    'Charancon_coupeur_mangue', 'Deperissement_mangue', 'Feuille_de_riz_saine', 
    'Feuille_mangue_sain', 'Fumagine_mangue', 'Hispa_un_insecte_ravageur', 
    'Le_mildiou_de_la_pomme_de_terre', 'Moucheron_des_galles_mangue', 'Oidium_mangue', 
    'Pyriculariose_du_riz', 'Tache_brune', 'Tache_foliaire_brune_étroite', 
    'cladosporiose_de_la_tomate', 'le_mildiou_précoce_de_la_pomme_de_terre', 
    'maïs_saine', 'mildiou_du_maïs', 'pomme_de_terre_saine', 'pomme_saine', 
    'pourriture_des_graines', 'pourriture_noire_du_pommier', 'rouille_du_maÏs', 
    'rouille_grillagée_du_pommier', 'stemphyliose_du maïs', 'tomate_saine', 
    'travelure_du_pommier', 'tétranyque_à_deux_points', 
    "virus_de_l'enrolement_jaune_de_la_feuille_de_tomate", 
    'virus_de_la_mosaïque_de_la_tomate', 'Échaudage_des feuilles'
]

# Modèle et prétraitement 
MODEL = None
PREPROCESS = None
DEVICE = None # Initialisé dans la fonction de chargement

def load_ai_model_once():
    """Charge les librairies PyTorch, le modèle et les transformations une seule fois."""
    global MODEL, PREPROCESS, DEVICE, torch, models, transforms
    
    if MODEL is None:
        print("--- Début du chargement des librairies PyTorch (Lazy Import) ---")
        
        # 1. IMPORTER LES LIBRAIRIES LOURDES ICI (C'est la modification clé)
        import torch as torch_lib
        import torchvision.models as models_lib
        import torchvision.transforms as transforms_lib
        
        # Mettre à jour les variables globales (nécessaire pour analyze_image)
        torch, models, transforms = torch_lib, models_lib, transforms_lib
        
        DEVICE = torch.device("cpu") # Forcer le CPU
        
        print("--- Début du chargement du modèle PyTorch (Lazy Loading) ---")
        
        # NOTE IMPORTANTE: Le chemin doit être ABSOLU sur Render.
        model_path = os.path.join(settings.BASE_DIR, 'diagnosis_api', 'model_entraine.pth')
        
        # Définir le modèle
        MODEL = models.resnet18(weights=None)
        num_ftrs = MODEL.fc.in_features
        MODEL.fc = torch.nn.Linear(num_ftrs, len(class_names))
        
        # Charger les poids
        MODEL.load_state_dict(torch.load(model_path, map_location=DEVICE))
        MODEL.eval()
        
        # Définir les transformations
        PREPROCESS = transforms.Compose([
            transforms.Resize(256),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
        
        print("--- Modèle PyTorch chargé et initialisé sur le CPU ---")

def analyze_image(image_data):
    try:
        # Charger le modèle s'il n'est pas encore chargé (première requête)
        load_ai_model_once() 

        # ... (le reste de la fonction analyze_image ne change pas)
        model_loaded = MODEL
        preprocess_loaded = PREPROCESS
        
        image = Image.open(io.BytesIO(image_data)).convert('RGB')
        
        input_tensor = preprocess_loaded(image)
        input_batch = input_tensor.unsqueeze(0) 
        
        with torch.no_grad():
            output = model_loaded(input_batch.to(DEVICE))
            
        probabilities = torch.nn.functional.softmax(output[0], dim=0)
        top_prob, top_class = torch.topk(probabilities, 1)
        
        prediction = class_names[top_class.item()]
        
        return prediction
        
    except FileNotFoundError:
        error_msg = f"Erreur: Le fichier modèle 'model_entraine.pth' n'a pas été trouvé."
        print(error_msg)
        return error_msg
        
    except Exception as e:
        print(f"Erreur d'analyse d'image: {e}")
        return "Erreur d'analyse"