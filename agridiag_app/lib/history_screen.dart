import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('diagnostics_history');
    if (historyJson != null) {
      final List<dynamic> decodedList = json.decode(historyJson);
      // S'assurer que chaque élément est bien un Map<String, dynamic>
      _history = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Fonction pour afficher le nom de la maladie sans le préfixe 'Diagnostic: '
  String _formatResult(String result) {
    return result.split(': ').length > 1 ? result.split(': ')[1].replaceAll('_', ' ') : result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Diagnostics'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(
        child: Text('Aucun diagnostic enregistré pour l\'instant.', style: TextStyle(fontSize: 16)),
      )
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index]; // L'ordre est déjà correct (le plus récent en premier)
          final imagePath = item['image_path'] as String;
          final result = _formatResult(item['result'] as String);
          final date = item['date'] as String;
          final imageFile = File(imagePath);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: imagePath.isNotEmpty && imageFile.existsSync()
                  ? Image.file(
                imageFile,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              title: Text(result, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Diagnostiqué le $date'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Laissez-le simple pour l'instant ou implémentez une vue détaillée
              },
            ),
          );
        },
      ),
    );
  }
}