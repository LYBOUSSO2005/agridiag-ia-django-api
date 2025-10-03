import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'disease_list_screen.dart';
import 'history_screen.dart';

// L'URL de votre API Django.
// ASSUREZ-VOUS que cette adresse IP est l'adresse IPv4 ACTUELLE de votre PC.
const String apiBaseUrl = 'https://agridiag-ia-django-api-1.onrender.com/api/diagnose/';
// Dictionnaire d'informations multilingues (FR et WO)
// Structure: {Nom_Maladie: {Code_Langue: {description: '...', conseil: '...'}}}
const Map<String, Map<String, Map<String, String>>> diseaseInfo = {
  // --- MALADIES DE LA MANGUE ---
  'Anthracnose_mangue': {
    'FR': {
      'description': 'Lésions noires et irrégulières sur les feuilles et les fruits, pouvant entraîner la chute des fleurs et des jeunes fruits.',
      'conseil': '**Traitement :** Appliquez un fongicide au **cuivre** (type bouillie bordelais) au stade de la floraison. **Culturel :** Éliminez les branches infectées et les résidus au sol.',
    },
    'WO': { // WOLOF (Traduction partielle - À COMPLÉTER)
      'description': 'Lëndëm yu ñuul ci xob ak meññeef, mën a def liy tax muy rot. (Dawe ci doom ak xob yi).',
      'conseil': '**Fàj :** Jëfandikoo « Bouillie bordelaise » (cuivre) ci lamiñ ak doom yi. **Tëggin :** Xañal xeer yi ak lëndëm yi ci suuf.',
    },
  },
  'Chancre_bacterien_mangue': {
    'FR': {
      'description': 'Petites taches noires, souvent avec un centre clair, qui peuvent former des chancres et des fissures sur les branches et les fruits.',
      'conseil': '**Traitement :** Des pulvérisations d\'antibiotiques spécifiques ou un **fongicide au cuivre** peuvent aider. **Culturel :** Évitez les blessures lors de la taille.',
    },
    'WO': {
      'description': '[WO] Petites taches noires, souvent avec un centre clair, qui peuvent former des chancres et des fissures sur les branches et les fruits.',
      'conseil': '[WO] Des pulvérisations d\'antibiotiques spécifiques ou un **fongicide au cuivre** peuvent aider. **Culturel :** Évitez les blessures lors de la taille.',
    },
  },
  'Charancon_coupeur_mangue': {
    'FR': {
      'description': 'Dégâts causés par un insecte (charançon). Les larves creusent des galeries, coupant souvent les jeunes pousses, provoquant leur chute.',
      'conseil': '**Traitement :** Utilisez des **insecticides systémiques** (type Imidaclopride) au début de l\'infestation. **Méthode :** Ramassez et détruisez les pousses tombées.',
    },
    'WO': {
      'description': '[WO] Dégâts causés par un insecte (charançon). Les larves creusent des galeries, coupant souvent les jeunes pousses, provoquant leur chute.',
      'conseil': '[WO] Utilisez des **insecticides systémiques** (type Imidaclopride) au début de l\'infestation. **Méthode :** Ramassez et détruisez les pousses tombées.',
    },
  },
  'Deperissement_mangue': {
    'FR': {
      'description': 'Le dépérissement commence par le brunissement et le dessèchement des pointes des jeunes pousses, progressant vers les branches plus anciennes.',
      'conseil': '**Traitement :** Taillez les parties infectées (jusqu\'au bois sain). Protégez la coupe avec un **fongicide cicatrisant** à base de Tebuconazole. **Culturel :** Améliorez le drainage du sol.',
    },
    'WO': {
      'description': '[WO] Le dépérissement commence par le brunissement et le dessèchement des pointes des jeunes pousses, progressant vers les branches plus anciennes.',
      'conseil': '[WO] Taillez les parties infectées (jusqu\'au bois sain). Protégez la coupe avec un **fongicide cicatrisant** à base de Tebuconazole. **Culturel :** Améliorez le drainage du sol.',
    },
  },
  'Feuille_mangue_sain': {
    'FR': {
      'description': 'La plante est en excellente santé. Les feuilles sont d\'un vert vif sans taches ni déformations.',
      'conseil': '**Conseil :** Maintenez l\'arbre bien nourri (vérifiez l\'azote) et bien arrosé. Surveillance régulière.',
    },
    'WO': {
      'description': 'Garab gi wer na lool. Xob yi dañu yéwén, amul lëndëm, amul luñu defar. (Xob yu wer).',
      'conseil': '**Xamle :** Mënal garab gi lakk (azote) bu baax te jox ko ndox mu doy. Saytu ko suñu ko gisee.',
    },
  },
  'Fumagine_mangue': {
    'FR': {
      'description': 'Couche superficielle noire, ressemblant à de la suie, causée par la présence de miellat sécrété par des insectes (cochenilles, pucerons).',
      'conseil': '**Traitement :** Utilisez un **insecticide** (type huile horticole ou Pyréthrine) pour contrôler les insectes qui produisent le miellat. **Nettoyage :** Lavez les feuilles avec de l\'eau savonneuse.',
    },
    'WO': {
      'description': '[WO] Couche superficielle noire, ressemblant à de la suie, causée par la présence de miellat sécrété par des insectes (cochenilles, pucerons).',
      'conseil': '[WO] Utilisez un **insecticide** (type huile horticole ou Pyréthrine) pour contrôler les insectes qui produisent le miellat. **Nettoyage :** Lavez les feuilles avec de l\'eau savonneuse.',
    },
  },
  'Moucheron_des_galles_mangue': {
    'FR': {
      'description': 'Présence de petites excroissances (galles) sur les feuilles, causées par les larves de moucherons qui se nourrissent des tissus foliaires.',
      'conseil': '**Traitement :** Les traitements chimiques sont plus efficaces contre les adultes avant la ponte. **Méthode :** Ramassez et brûlez les feuilles très infectées.',
    },
    'WO': {
      'description': '[WO] Présence de petites excroissances (galles) sur les feuilles, causées par les larves de moucherons qui se nourrissent des tissus foliaires.',
      'conseil': '[WO] Les traitements chimiques sont plus efficaces contre les adultes avant la ponte. **Méthode :** Ramassez et brûlez les feuilles très infectées.',
    },
  },
  'Oidium_mangue': {
    'FR': {
      'description': 'Un revêtement blanc poudreux apparaît sur les feuilles, les jeunes pousses et les fleurs, entravant la photosynthèse et la fructification.',
      'conseil': '**Traitement :** Appliquez du **soufre mouillable** (fongicide traditionnel) ou des fongicides systémiques (type Triazole). **Culturel :** Améliorez la circulation de l\'air.',
    },
    'WO': {
      'description': '[WO] Un revêtement blanc poudreux apparaît sur les feuilles, les jeunes pousses et les fleurs, entravant la photosynthèse et la fructification.',
      'conseil': '[WO] Appliquez du **soufre mouillable** (fongicide traditionnel) ou des fongicides systémiques (type Triazole). **Culturel :** Améliorez la circulation de l\'air.',
    },
  },

  // --- MALADIES DU RIZ ---
  'Brûlure_bactérienne_des_feuilles': {
    'FR': {
      'description': 'Lésions aqueuses vert-grisâtre qui apparaissent sur les bords des feuilles et s\'étendent en bandes jaunes ou blanches.',
      'conseil': '**Traitement :** Les traitements à base de **cuivre** peuvent limiter la propagation. **Culturel :** Utilisez des variétés résistantes et évitez les engrais azotés excessifs.',
    },
    'WO': {
      'description': '[WO] Lésions aqueuses vert-grisâtre qui apparaissent sur les bords des feuilles et s\'étendent en bandes jaunes ou blanches.',
      'conseil': '[WO] Les traitements à base de **cuivre** peuvent limiter la propagation. **Culturel :** Utilisez des variétés résistantes et évitez les engrais azotés excessifs.',
    },
  },
  'Échaudage_des feuilles': {
    'FR': {
      'description': 'Grandes lésions irrégulières, gris-vertes, donnant l\'impression que la feuille a été échaudée par de l\'eau bouillante.',
      'conseil': '**Traitement :** Utilisez des fongicides systémiques (ex: Difenoconazole). **Culturel :** Réduisez la densité de semis et assurez un bon drainage des parcelles.',
    },
    'WO': {
      'description': '[WO] Grandes lésions irrégulières, gris-vertes, donnant l\'impression que la feuille a été échaudée par de l\'eau bouillante.',
      'conseil': '**Traitement :** [WO] Utilisez des fongicides systémiques (ex: Difenoconazole). **Culturel :** Réduisez la densité de semis et assurez un bon drainage des parcelles.',
    },
  },
  'Feuille_de_riz_saine': {
    'FR': {
      'description': 'La feuille est en bonne santé. Surveillez la couleur pour détecter une carence en nutriments.',
      'conseil': '**Conseil :** Maintenez le niveau d\'eau optimal. Vérifiez l\'apport en nutriments essentiels.',
    },
    'WO': {
      'description': '[WO] La feuille est en bonne santé. Surveillez la couleur pour détecter une carence en nutriments.',
      'conseil': '[WO] Maintenez le niveau d\'eau optimal. Vérifiez l\'apport en nutriments essentiels.',
    },
  },
  'Hispa_un_insecte_ravageur': {
    'FR': {
      'description': 'Les feuilles sont grattées ou présentent des galeries (tunnels) causées par l\'insecte, réduisant la capacité photosynthétique.',
      'conseil': '**Traitement :** Utilisez des **insecticides ciblés** (type Cyperméthrine) si l\'infestation est grave. **Méthode :** Éliminez les herbes folles autour des rizières.',
    },
    'WO': {
      'description': '[WO] Les feuilles sont grattées ou présentent des galeries (tunnels) causées par l\'insecte, réduisant la capacité photosynthétique.',
      'conseil': '[WO] Utilisez des **insecticides ciblés** (type Cyperméthrine) si l\'infestation est grave. **Méthode :** Éliminez les herbes folles autour des rizières.',
    },
  },
  'Pyriculariose_du_riz': {
    'FR': {
      'description': 'Taches en forme de losange avec un centre gris et des bords rouges-bruns sur les feuilles. Très destructeur.',
      'conseil': '**Traitement :** Application de **fongicides spécifiques** (type Tricyclazole ou Azoxystrobine) au début de la saison. **Culturel :** Utilisez des variétés résistantes.',
    },
    'WO': {
      'description': '[WO] Taches en forme de losange avec un centre gris et des bords rouges-bruns sur les feuilles. Très destructeur.',
      'conseil': '[WO] Application de **fongicides spécifiques** (type Tricyclazole ou Azoxystrobine) au début de la saison. **Culturel :** Utilisez des variétés résistantes.',
    },
  },
  'Tache_brune': {
    'FR': {
      'description': 'Taches ovales, brunes avec un petit centre gris. Elles peuvent affecter la qualité du grain et réduire le rendement.',
      'conseil': '**Traitement :** Appliquez des fongicides si le seuil d\'alerte est dépassé. **Culturel :** Évitez les carences en **potassium**. Améliorez le drainage.',
    },
    'WO': {
      'description': '[WO] Taches ovales, brunes avec un petit centre gris. Elles peuvent affecter la qualité du grain et réduire le rendement.',
      'conseil': '[WO] Appliquez des fongicides si le seuil d\'alerte est dépassé. **Culturel :** Évitez les carences en **potassium**. Améliorez le drainage.',
    },
  },
  'Tache_foliaire_brune_étroite': {
    'FR': {
      'description': 'Petites lésions fines et brun-rouille, qui courent parallèlement aux nervures de la feuille.',
      'conseil': '**Traitement :** Les fongicides utilisés pour la Pyriculariose sont souvent efficaces. **Culturel :** Utilisez des semences saines et contrôlez les mauvaises herbes.',
    },
    'WO': {
      'description': '[WO] Petites lésions fines et brun-rouille, qui courent parallèlement aux nervures de la feuille.',
      'conseil': '[WO] Les fongicides utilisés pour la Pyriculariose sont souvent efficaces. **Culturel :** Utilisez des semences saines et contrôlez les mauvaises herbes.',
    },
  },
  'pourriture_des_graines': {
    'FR': {
      'description': 'Dégâts sur la gaine foliaire du riz, souvent près de la ligne de flottaison, formant des lésions irrégulières et une pourriture humide.',
      'conseil': '**Culturel :** Réduisez la densité de semis pour améliorer la circulation de l\'air. Évitez une fertilisation azotée tardive. **Traitement :** Fongicides systémiques si nécessaire.',
    },
    'WO': {
      'description': '[WO] Dégâts sur la gaine foliaire du riz, souvent près de la ligne de flottaison, formant des lésions irrégulières et une pourriture humide.',
      'conseil': '[WO] Réduisez la densité de semis pour améliorer la circulation de l\'air. Évitez une fertilisation azotée tardive. **Traitement :** Fongicides systémiques si nécessaire.',
    },
  },

  // --- CLASSES SECONDAIRES ---
  'cladosporiose_de_la_tomate': {
    'FR': {
      'description': 'Taches veloutées brun-olive au revers des feuilles de tomate, devenant jaunes ou nécrotiques sur la face supérieure.',
      'conseil': '**Traitement :** Utilisez des fongicides protecteurs (ex: Chlorothalonil ou Mancozèbe). **Culturel :** Améliorez la ventilation et évitez l\'arrosage par aspersion.',
    },
    'WO': {
      'description': '[WO] Taches veloutées brun-olive au revers des feuilles de tomate, devenant jaunes ou nécrotiques sur la face supérieure.',
      'conseil': '[WO] Utilisez des fongicides protecteurs (ex: Chlorothalonil ou Mancozèbe). **Culturel :** Améliorez la ventilation et évitez l\'arrosage par aspersion.',
    },
  },
  'le_mildiou_précoce_de_la_pomme_de_terre': {
    'FR': {
      'description': 'Taches circulaires avec des anneaux concentriques (cible) sur les feuilles de pomme de terre, causées par Alternaria solani.',
      'conseil': '**Traitement :** Fongicides préventifs comme le **Mancozèbe** ou des Triazoles. **Culturel :** Maintenez une bonne nutrition.',
    },
    'WO': {
      'description': '[WO] Taches circulaires avec des anneaux concentriques (cible) sur les feuilles de pomme de terre, causées par Alternaria solani.',
      'conseil': '[WO] Fongicides préventifs comme le **Mancozèbe** ou des Triazoles. **Culturel :** Maintenez une bonne nutrition.',
    },
  },
  'maïs_saine': {
    'FR': {
      'description': 'La plante de maïs est en excellente santé. Continuez les pratiques culturales régulières.',
      'conseil': '**Conseil :** Surveillez l\'irrigation. Pratiquez une rotation des cultures.',
    },
    'WO': {
      'description': '[WO] La plante de maïs est en excellente santé. Continuez les pratiques culturales régulières.',
      'conseil': '[WO] Surveillez l\'irrigation. Pratiquez une rotation des cultures.',
    },
  },
  'mildiou_du_maïs': {
    'FR': {
      'description': 'Taches circulaires ou ovales de couleur blanc-gris à jaune-pâle sur les feuilles de maïs.',
      'conseil': '**Traitement :** Fongicides à base de **Métalaxyl** ou Mancozèbe au besoin. **Culturel :** Utilisez des variétés résistantes.',
    },
    'WO': {
      'description': '[WO] Taches circulaires ou ovales de couleur blanc-gris à jaune-pâle sur les feuilles de maïs.',
      'conseil': '[WO] Fongicides à base de **Métalaxyl** ou Mancozèbe au besoin. **Culturel :** Utilisez des variétés résistantes.',
    },
  },
  'pomme_de_terre_saine': {
    'FR': {
      'description': 'La plante de pomme de terre est saine et vigoureuse.',
      'conseil': '**Conseil :** Surveillez les nuisibles. Évitez l\'humidité excessive du feuillage.',
    },
    'WO': {
      'description': '[WO] La plante de pomme de terre est saine et vigoureuse.',
      'conseil': '[WO] Surveillez les nuisibles. Évitez l\'humidité excessive du feuillage.',
    },
  },
  'pomme_saine': {
    'FR': {
      'description': 'La pomme est en parfait état. La peau est lisse et uniforme.',
      'conseil': '**Conseil :** Continuez la taille et l\'éclaircissage pour un bon développement des fruits.',
    },
    'WO': {
      'description': '[WO] La pomme est en parfait état. La peau est lisse et uniforme.',
      'conseil': '[WO] Continuez la taille et l\'éclaircissage pour un bon développement des fruits.',
    },
  },
  'pourriture_noire_du_pommier': {
    'FR': {
      'description': 'Taches marron foncé qui s\'étendent rapidement sur les fruits de pomme, devenant noires et ratatinées.',
      'conseil': '**Traitement :** Fongicides après la floraison. **Culturel :** Éliminez les fruits momifiés (momies) et les branches infectées.',
    },
    'WO': {
      'description': '[WO] Taches marron foncé qui s\'étendent rapidement sur les fruits de pomme, devenant noires et ratatinées.',
      'conseil': '[WO] Fongicides après la floraison. **Culturel :** Éliminez les fruits momifiés (momies) et les branches infectées.',
    },
  },
  'rouille_du_maÏs': {
    'FR': {
      'description': 'Présence de pustules brun-rouille sur les deux faces de la feuille de maïs, libérant une poudre de spores.',
      'conseil': '**Traitement :** Fongicides systémiques (type Azoxystrobine) si l\'infection est précoce. **Culturel :** Utilisez des hybrides résistants.',
    },
    'WO': {
      'description': '[WO] Présence de pustules brun-rouille sur les deux faces de la feuille de maïs, libérant une poudre de spores.',
      'conseil': '[WO] Fongicides systémiques (type Azoxystrobine) si l\'infection est précoce. **Culturel :** Utilisez des hybrides résistants.',
    },
  },
  'rouille_grillagée_du_pommier': {
    'FR': {
      'description': 'Taches jaunes ou oranges vif sur la face supérieure des feuilles de pommier, souvent avec de petites structures "grillagées" sur la face inférieure.',
      'conseil': '**Traitement :** Fongicides au stade du bouton rose. **Culturel :** Évitez la proximité des genévriers (hôte alternatif).',
    },
    'WO': {
      'description': '[WO] Taches jaunes ou oranges vif sur la face supérieure des feuilles de pommier, souvent avec de petites structures "grillagées" sur la face inférieure.',
      'conseil': '[WO] Fongicides au stade du bouton rose. **Culturel :** Évitez la proximité des genévriers (hôte alternatif).',
    },
  },
  'stemphyliose_du maïs': {
    'FR': {
      'description': 'Grandes lésions nécrotiques gris-vert à brun-rouge de forme ovale ou irrégulière sur les feuilles de maïs.',
      'conseil': '**Culturel :** Rotation des cultures et enfouissement des résidus de culture. **Traitement :** Fongicides s\'il y a une forte pression de maladie.',
    },
    'WO': {
      'description': '[WO] Grandes lésions nécrotiques gris-vert à brun-rouge de forme ovale ou irrégulière sur les feuilles de maïs.',
      'conseil': '[WO] Rotation des cultures et enfouissement des résidus de culture. **Traitement :** Fongicides s\'il y a une forte pression de maladie.',
    },
  },
  'tomate_saine': {
    'FR': {
      'description': 'La plante de tomate est saine. Les feuilles sont vertes et sans taches.',
      'conseil': '**Conseil :** Fournissez un bon support et une taille régulière pour aérer la plante.',
    },
    'WO': {
      'description': '[WO] La plante de tomate est saine. Les feuilles sont vertes et sans taches.',
      'conseil': '[WO] Fournissez un bon support et une taille régulière pour aérer la plante.',
    },
  },
  'travelure_du_pommier': {
    'FR': {
      'description': 'Taches veloutées brun-olive sur les feuilles de pommier, causant des déformations et des fissures sur les fruits.',
      'conseil': '**Traitement :** Fongicides de couverture (ex: Captan) dès l\'apparition des boutons floraux. **Culturel :** Nettoyez les feuilles tombées en automne.',
    },
    'WO': {
      'description': '[WO] Taches veloutées brun-olive sur les feuilles de pommier, causant des déformations et des fissures sur les fruits.',
      'conseil': '[WO] Fongicides de couverture (ex: Captan) dès l\'apparition des boutons floraux. **Culturel :** Nettoyez les feuilles tombées en automne.',
    },
  },
  'tétranyque_à_deux_points': {
    'FR': {
      'description': 'Petits acariens qui causent un jaunissement et des taches. Une fine toile d\'araignée est souvent visible sur la face inférieure des feuilles.',
      'conseil': '**Traitement :** Utilisez des **acaricides** spécifiques (ex: Abamectine). **Méthode Biologique :** Favorisez les acariens prédateurs (lutte biologique).',
    },
    'WO': {
      'description': '[WO] Petits acariens qui causent un jaunissement et des taches. Une fine toile d\'araignée est souvent visible sur la face inférieure des feuilles.',
      'conseil': '[WO] Utilisez des **acaricides** spécifiques (ex: Abamectine). **Méthode Biologique :** Favorisez les acariens prédateurs (lutte biologique).',
    },
  },
  "virus_de_l'enrolement_jaune_de_la_feuille_de_tomate": {
    'FR': {
      'description': 'Feuilles s\'enroulant vers le haut et jaunissement sévère des bords, causé par un virus transmis par les aleurodes (mouches blanches).',
      'conseil': '**Traitement :** **Pas de remède pour le virus**. Concentrez-vous sur le contrôle strict des **aleurodes** (insecticides spécifiques). **Méthode :** Éliminez les plantes infectées immédiatement.',
    },
    'WO': {
      'description': '[WO] Feuilles s\'enroulant vers le haut et jaunissement sévère des bords, causé par un virus transmis par les aleurodes (mouches blanches).',
      'conseil': '[WO] **Pas de remède pour le virus**. Concentrez-vous sur le contrôle strict des **aleurodes** (insecticides spécifiques). **Méthode :** Éliminez les plantes infectées immédiatement.',
    },
  },
  'virus_de_la_mosaïque_de_la_tomate': {
    'FR': {
      'description': 'Motifs de taches vertes et jaunes (mosaïque) sur les feuilles, causant souvent des déformations et une réduction de la croissance.',
      'conseil': '**Traitement :** **Pas de remède pour le virus**. **Méthode :** Éliminez les plantes infectées et stérilisez les outils de taille.',
    },
    'WO': {
      'description': '[WO] Motifs de taches vertes et jaunes (mosaïque) sur les feuilles, causant souvent des déformations et une réduction de la croissance.',
      'conseil': '[WO] **Pas de remède pour le virus**. **Méthode :** Éliminez les plantes infectées et stérilisez les outils de taille.',
    },
  },
  'Le_mildiou_de_la_pomme_de_terre': {
    'FR': {
      'description': 'Taches foncées irrégulières entourées d\'un halo jaune sur les feuilles de pomme de terre. C\'est l\'une des maladies les plus destructrices.',
      'conseil': '**Traitement :** Utilisez des fongicides à base de **Chlorothalonil** ou **Azoxystrobine**. **Culturel :** Éliminez les résidus de culture et ne pas arroser le feuillage.',
    },
    'WO': {
      'description': '[WO] Taches foncées irrégulières entourées d\'un halo jaune sur les feuilles de pomme de terre. C\'est l\'une des maladies les plus destructrices.',
      'conseil': '[WO] Utilisez des fongicides à base de **Chlorothalonil** ou **Azoxystrobine**. **Culturel :** Éliminez les résidus de culture et ne pas arroser le feuillage.',
    },
  },
};

void main() {
  runApp(const AgriDiagApp());
}

class AgriDiagApp extends StatelessWidget {
  const AgriDiagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriDiag AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DiagnosisScreen(),
    );
  }
}

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  File? _image;
  String _prediction = 'Cliquez sur le bouton pour commencer l\'analyse.';
  String _description = '';
  String _conseil = '';
  bool _isLoading = false;
  String _currentLang = 'FR'; // 'FR' ou 'WO' (Langue actuelle)

  // --- Logique d'Historique (shared_preferences) ---
  Future<void> _saveHistory(String imagePath, String result) async {
    final prefs = await SharedPreferences.getInstance();
    final date = DateTime.now().toLocal().toString().split(' ')[0];

    final newItem = {
      'image_path': imagePath,
      'result': result,
      'date': date,
    };

    final historyJson = prefs.getString('diagnostics_history');
    List<Map<String, dynamic>> history = [];

    if (historyJson != null) {
      final List<dynamic> decodedList = json.decode(historyJson);
      history = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    history.insert(0, newItem);
    if (history.length > 20) {
      history = history.sublist(0, 20); // Limiter à 20 entrées
    }

    await prefs.setString('diagnostics_history', json.encode(history));
  }
  // --------------------------------------------------

  // NOUVEAU: Fonction pour afficher le sélecteur de langue
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Français (FR)'),
              trailing: _currentLang == 'FR' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() => _currentLang = 'FR');
                Navigator.pop(context);
                // Réinitialiser l'affichage après changement de langue si un diagnostic est affiché
                if (_description.isNotEmpty) {
                  _updateDisplayAfterLangChange();
                }
              },
            ),
            ListTile(
              title: const Text('Wolof (WO)'),
              trailing: _currentLang == 'WO' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() => _currentLang = 'WO');
                Navigator.pop(context);
                if (_description.isNotEmpty) {
                  _updateDisplayAfterLangChange();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction pour mettre à jour la description/conseil après un changement de langue
  void _updateDisplayAfterLangChange() {
    // Retirer 'Résultat: ' pour obtenir le nom de la classe
    final currentPredictionClass = _prediction.split(': ').length > 1 ? _prediction.split(': ')[1] : _prediction;

    final diseaseData = diseaseInfo[currentPredictionClass];
    Map<String, String>? langInfo = diseaseData?[_currentLang];

    if (langInfo == null) {
      langInfo = diseaseData?['FR'];
    }

    final String description = langInfo?['description'] ?? 'Description non trouvée.';
    final String conseil = langInfo?['conseil'] ?? 'Conseil non trouvé.';

    setState(() {
      _description = description;
      _conseil = conseil;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isLoading) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _prediction = 'Image sélectionnée. Envoi en cours...';
        _description = '';
        _conseil = '';
        _isLoading = true;
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    var uri = Uri.parse(apiBaseUrl);
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        final predictedClass = jsonResponse['prediction'];

        // --- Logique Multilingue ---
        final diseaseData = diseaseInfo[predictedClass];
        Map<String, String>? langInfo = diseaseData?[_currentLang];

        if (langInfo == null) {
          langInfo = diseaseData?['FR']; // Fallback au français
        }

        final String description = langInfo?['description'] ?? 'Aucune description détaillée disponible.';
        final String conseil = langInfo?['conseil'] ?? 'Aucun conseil disponible.';
        // -------------------------

        setState(() {
          _prediction = 'Résultat: $predictedClass';
          _description = description;
          _conseil = conseil;
        });

        // Sauvegarde de l'historique
        if (_image != null) {
          await _saveHistory(_image!.path, 'Diagnostic: $predictedClass');
        }
      } else {
        setState(() {
          _prediction = 'Erreur API: Code ${response.statusCode}. Réponse: ${responseBody.substring(0, 50)}...';
          _description = '';
          _conseil = '';
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Erreur de connexion : Vérifiez que l\'API Django est lancée et que l\'URL est correcte. Vous pouvez consulter les fiches techniques via l\'icône "Toutes les maladies".';
        _description = '';
        _conseil = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget;

    if (_isLoading) {
      resultWidget = const CircularProgressIndicator(color: Colors.green);
    } else if (_description.isNotEmpty && _description != 'Aucune description détaillée disponible.') {
      final titleText = _prediction.split(': ').length > 1 ? _prediction.split(': ')[1].replaceAll('_', ' ') : _prediction;

      resultWidget = Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Diagnostic: $titleText',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description de la Maladie:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.black87)),
                      const Divider(),
                      Text(_description, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Conseils de Traitement:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.green)),
                      const Divider(color: Colors.green),
                      Text(_conseil, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      resultWidget = Text(
        _prediction,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _prediction.startsWith('Erreur') ? Colors.red : Colors.green.shade800
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse AgriDiag AI'),
        backgroundColor: Colors.green,
        actions: [
          // 1. Bouton de sélection de langue
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSelector(context),
            tooltip: 'Changer de langue',
          ),
          // 2. Bouton d'Historique
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            tooltip: 'Historique des diagnostics',
          ),
          // 3. Bouton Liste des maladies
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DiseaseListScreen(currentLang: _currentLang)),
              );
            },
            tooltip: 'Toutes les maladies',
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                Expanded(
                  child: Image.file(_image!, fit: BoxFit.contain),
                )
              else
                const Icon(Icons.image, size: 150, color: Colors.green),

              const SizedBox(height: 20),

              resultWidget,

              if (_description.isEmpty && !_isLoading)
                const SizedBox(height: 100),

              const SizedBox(height: 30),

              // Bouton Galerie
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Sélectionner une photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // Bouton Caméra
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Prendre une photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}