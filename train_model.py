import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, models, transforms
import os

if __name__ == '__main__':
    # --- 1. Définition des paramètres ---
    data_dir = './datasets'
    num_epochs = 50
    batch_size = 32
    learning_rate = 0.001
    num_workers = 0 # Changement : mettez à 0 pour éviter ce type d'erreur sur Windows

    # --- 2. Préparation des données (Transformations) ---
    data_transforms = {
        'train': transforms.Compose([
            transforms.RandomResizedCrop(224),
            transforms.RandomHorizontalFlip(),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ]),
        'val': transforms.Compose([
            transforms.Resize(256),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ]),
    }

    # --- 3. Chargement des données ---
    image_datasets = {x: datasets.ImageFolder(os.path.join(data_dir, x), data_transforms[x])
                      for x in ['train', 'val']}
    dataloaders = {x: DataLoader(image_datasets[x], batch_size=batch_size, shuffle=True, num_workers=num_workers)
                   for x in ['train', 'val']}
    dataset_sizes = {x: len(image_datasets[x]) for x in ['train', 'val']}
    class_names = image_datasets['train'].classes
    print("Classes trouvées:", class_names)
    print("Nombre de classes:", len(class_names))

    # --- 4. Définition du modèle (Apprentissage par transfert) ---
    model = models.resnet18(weights='IMAGENET1K_V1')
    num_classes = len(class_names)
    num_ftrs = model.fc.in_features
    model.fc = nn.Linear(num_ftrs, num_classes)

    # --- 5. Définition de la fonction de perte et de l'optimiseur ---
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    # --- 6. Boucle d'entraînement ---
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model = model.to(device)

    print("\nDébut de l'entraînement...")
    for epoch in range(num_epochs):
        print(f'Epoch {epoch+1}/{num_epochs}')
        model.train()
        running_loss = 0.0
        for inputs, labels in dataloaders['train']:
            inputs = inputs.to(device)
            labels = labels.to(device)
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            running_loss += loss.item() * inputs.size(0)
        
        epoch_loss = running_loss / dataset_sizes['train']
        print(f'Loss de l\'époque: {epoch_loss:.4f}')

    print("Entraînement terminé.")

    # --- 7. Sauvegarde du modèle entraîné ---
    model_path = 'model_entraine.pth'
    torch.save(model.state_dict(), model_path)
    print(f"Modèle sauvegardé sous le nom: {model_path}")