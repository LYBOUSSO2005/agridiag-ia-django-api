# views.py

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .ai_model import analyze_image # Importe la fonction d'analyse IA

@csrf_exempt
def diagnose_plant(request):
    if request.method == 'POST':
        if 'photo' in request.FILES:
            uploaded_file = request.FILES['photo']

            # Lire les données binaires de la photo
            image_data = uploaded_file.read()

            # Appeler la fonction d'analyse IA
            prediction = analyze_image(image_data)

            # Retourner la prédiction du modèle IA
            return JsonResponse({'status': 'success', 'prediction': prediction, 'file_name': uploaded_file.name})
        else:
            return JsonResponse({'status': 'error', 'message': 'Aucune photo trouvée dans la requête.'}, status=400)

    return JsonResponse({'status': 'error', 'message': 'Méthode de requête non autorisée.'}, status=405)