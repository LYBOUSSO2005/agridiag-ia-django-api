import 'package:flutter/material.dart';
import 'main.dart'; // Importe le dictionnaire diseaseInfo

class DiseaseListScreen extends StatelessWidget {
  // Le constructeur accepte la langue sélectionnée
  final String currentLang;
  const DiseaseListScreen({super.key, required this.currentLang});

  @override
  Widget build(BuildContext context) {
    // Convertir la Map en une liste de Widgets pour l'affichage
    final diseaseEntries = diseaseInfo.entries.toList();

    return Scaffold(
      appBar: AppBar(
        // Le titre de la page reste statique (pour la simplicité)
        title: const Text('Toutes les Maladies et Conseils'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: diseaseEntries.length,
        itemBuilder: (context, index) {
          final entry = diseaseEntries[index];
          // Rendre le nom de la maladie plus lisible (remplace les _ par des espaces)
          final diseaseName = entry.key.replaceAll('_', ' ');

          // NOUVELLE LOGIQUE: Récupérer les infos dans la langue sélectionnée
          Map<String, String>? langInfo = entry.value[currentLang];
          if (langInfo == null) {
            langInfo = entry.value['FR']; // Fallback au français
          }

          final info = langInfo!; // On garantit que la Map d'infos existe (au moins FR)

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ExpansionTile( // Permet de déplier la carte pour voir les détails
              title: Text(
                diseaseName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      // Utilise la description traduite (ou le fallback FR)
                      Text(info['description']!, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 10),

                      // Conseils
                      const Text('Conseils Pratiques:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                      const SizedBox(height: 5),
                      // Utilise le conseil traduit (ou le fallback FR)
                      Text(info['conseil']!, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}