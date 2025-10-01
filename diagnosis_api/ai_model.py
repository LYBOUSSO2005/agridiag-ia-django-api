import torch
from torchvision import models, transforms
from PIL import Image
import io

# Le dictionnaire qui associe l'index à la classe (maladie/plante)
# Mettre à jour avec la liste exacte des 32 classes
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

# Charger le modèle entraîné
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model = models.resnet18(weights=None)
num_ftrs = model.fc.in_features
model.fc = torch.nn.Linear(num_ftrs, len(class_names))
model.load_state_dict(torch.load('model_entraine.pth', map_location=device))
model.eval()

# Définir les transformations pour les nouvelles images
preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

def analyze_image(image_data):
    try:
        # Ouvrir l'image
        image = Image.open(io.BytesIO(image_data)).convert('RGB')
        
        # Prétraiter l'image
        input_tensor = preprocess(image)
        input_batch = input_tensor.unsqueeze(0)  # Créer un mini-batch
        
        # Déplacer l'image sur le bon périphérique
        with torch.no_grad():
            output = model(input_batch.to(device))
            
        # Obtenir les probabilités et la classe prédite
        probabilities = torch.nn.functional.softmax(output[0], dim=0)
        top_prob, top_class = torch.topk(probabilities, 1)
        
        # Obtenir le nom de la classe
        prediction = class_names[top_class.item()]
        
        return prediction
    except Exception as e:
        print(f"Erreur d'analyse d'image: {e}")
        return "Erreur d'analyse"