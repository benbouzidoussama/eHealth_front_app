import 'package:flutter/material.dart';

class DocumentScreen extends StatelessWidget {
  final List<Map<String, dynamic>> documents;

  const DocumentScreen({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        centerTitle: true,
      ),
      body: documents.isEmpty
          ? const Center(child: Text('Aucun document disponible.'))
          : ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(document['title'] ?? 'Sans titre'),
                  subtitle: Text(document['description'] ?? 'Pas de description'),
                  onTap: () {
                    // Implémentez l'ouverture du document ici
                  },
                );
              },
            ),
    );
  }
}