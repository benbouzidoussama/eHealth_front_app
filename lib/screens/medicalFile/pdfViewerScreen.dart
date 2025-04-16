import 'dart:io';
import 'dart:math';
//import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
//import 'package:path/path.dart' as path;

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;
  const PdfViewerScreen({required this.url, required this.title, super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  // Vérifier si les premiers octets correspondent à un PDF
  bool isPdfHeader(List<int> bytes) {
    if (bytes.length < 5) return false;

    // Un PDF valide commence généralement par "%PDF-"
    return String.fromCharCodes(bytes.sublist(0, 5)) == "%PDF-";
  }

  Future<void> loadPdf() async {
    try {
      // Afficher l'URL pour le débogage
      debugPrint('Tentative de chargement du PDF depuis: ${widget.url}');

      // Génération d'un nom de fichier unique basé sur un timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'pdf_$timestamp.pdf';

      // Téléchargement du PDF avec des headers appropriés
      final response = await http
          .get(
            Uri.parse(widget.url),
            headers: {
              'Accept': 'application/pdf',
              'User-Agent': 'Mozilla/5.0 Flutter PDF Viewer App',
            },
          )
          .timeout(const Duration(seconds: 30)); // Timeout après 30 secondes

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;

      // Log de débogage pour voir la taille et le début du fichier
      debugPrint('Taille du fichier téléchargé : ${bytes.length} octets');
      if (bytes.isNotEmpty) {
        debugPrint(
          'Premiers octets du fichier : ${bytes.sublist(0, min(20, bytes.length))}',
        );

        // Vérifier si c'est un PDF valide
        if (!isPdfHeader(bytes)) {
          throw Exception(
            'Le fichier téléchargé ne semble pas être un PDF valide',
          );
        }
      } else {
        throw Exception('Fichier téléchargé vide');
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      await file.writeAsBytes(bytes, flush: true);

      // Vérification que le fichier a bien été écrit
      if (!(await file.exists())) {
        throw Exception('Échec de création du fichier local');
      }

      debugPrint('PDF sauvegardé avec succès à: ${file.path}');

      if (mounted) {
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Erreur de chargement du PDF: $e';
          isLoading = false;
          debugPrint('Erreur: $errorMessage');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Téléchargement du PDF...'),
                  ],
                ),
              )
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger le PDF',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        loadPdf();
                      },
                      child: const Text('Réessayer'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              )
              : PDFView(
                filePath: localPath!,
                autoSpacing: true,
                enableSwipe: true,
                swipeHorizontal: false,
                pageSnap: true,
                fitEachPage: true,
                fitPolicy: FitPolicy.BOTH,
                onError: (error) {
                  setState(() {
                    errorMessage = 'Erreur lors du rendu du PDF: $error';
                    debugPrint('Erreur PDFView: $error');
                  });
                },
                onPageError: (page, error) {
                  debugPrint('Erreur à la page $page: $error');
                },
                onViewCreated: (controller) {
                  debugPrint('Vue PDF créée avec succès');
                },
                onPageChanged: (page, total) {
                  debugPrint('Page changée: $page/$total');
                },
              ),
    );
  }

  @override
  void dispose() {
    // Nettoyage du fichier temporaire (optionnel)
    if (localPath != null) {
      try {
        File(localPath!)
            .delete()
            .then((_) {
              debugPrint('Fichier temporaire supprimé: $localPath');
            })
            .catchError((e) {
              debugPrint('Erreur lors de la suppression du fichier: $e');
            });
      } catch (e) {
        debugPrint('Erreur lors de la suppression du fichier: $e');
      }
    }
    super.dispose();
  }
}
