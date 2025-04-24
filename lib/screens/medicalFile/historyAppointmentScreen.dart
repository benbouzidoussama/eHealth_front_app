import 'package:e_health_front/screens/medicalFile/imageViewerScreen.dart';
import 'package:e_health_front/screens/medicalFile/noteScreen.dart';
import 'package:e_health_front/screens/medicalFile/ordonnanceScreen.dart';
import 'package:e_health_front/screens/medicalFile/regimeScreen.dart';
import 'package:e_health_front/screens/medicalFile/pdfViewerScreen.dart'; // Ensure this import is correct and the file exists
import 'package:flutter/material.dart';
import 'package:e_health_front/services/api_service.dart';

//
class HistoryAppointmentScreen extends StatefulWidget {
  final String doctorId;

  const HistoryAppointmentScreen({super.key, required this.doctorId});

  @override
  State<HistoryAppointmentScreen> createState() =>
      _HistoryAppointmentScreenState();
}

class _HistoryAppointmentScreenState extends State<HistoryAppointmentScreen> {
  final Map<String, bool> _expandedCards = {};
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;
  late Future<List<Map<String, dynamic>>> _allAppointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = ApiService().fetchCompletedAppointments(
      widget.doctorId,
    );
    _allAppointmentsFuture = ApiService().getAllAppointmentDetails(
      widget.doctorId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique des rendez-vous',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder(
        future: Future.wait([_appointmentsFuture, _allAppointmentsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A6572)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur : ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final appointments = snapshot.data![0] as List<Map<String, dynamic>>;
          final allDetails = snapshot.data![1] as List<Map<String, dynamic>>;

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun rendez-vous terminé',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vos rendez-vous terminés apparaîtront ici',
                    style: TextStyle(fontSize: 16, color: Colors.black38),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final id = appointment['_id'];
              final doctor = appointment['doctor'];
              final isExpanded = _expandedCards[id] ?? false;

              final details = allDetails.firstWhere(
                (element) => element['_id'] == id,
                orElse: () => {},
              );

              // Format the date to make it more readable
              final dateStr = appointment['date'].toString().split('T')[0];
              final dateComponents = dateStr.split('-');
              final formattedDate =
                  '${dateComponents[2]}/${dateComponents[1]}/${dateComponents[0]}';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  elevation: 0,
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            _expandedCards[id] = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF4A6572,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4A6572),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF2E3C42),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          appointment['time'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: const Color(0xFF4A6572),
                                    size: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.local_hospital,
                                'Type',
                                appointment['type'],
                                Colors.blue,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.person,
                                'Docteur',
                                '${doctor['doctorName']} (${doctor['speciality']})',
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(height: 0),
                        secondChild: _buildAppointmentDetails(details),
                        crossFadeState:
                            isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentDetails(Map<String, dynamic> appointment) {
    final Color primaryColor = const Color(0xFF4A6572);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Détails du rendez-vous',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Créé le',
            (appointment['createdAt'] ?? '').toString().split('T')[0],
          ),
          _buildDetailRow(
            'Mis à jour le',
            (appointment['updatedAt'] ?? '').toString().split('T')[0],
          ),
          const Divider(height: 24),

          // Notes section
          if (appointment['notes'] != null && appointment['notes'].isNotEmpty)
            _buildSectionWithNavigation(
              '📝 Notes',
              appointment['notes'],
              (notes) => NoteScreen(notes: notes),
              (note) => '${note['titre']}: ${note['content']}',
              Colors.blue[100]!,
              Colors.blue[700]!,
            ),

          // Prescriptions section
          if (appointment['prescriptions'] != null &&
              appointment['prescriptions'].isNotEmpty)
            _buildSectionWithNavigation(
              '💊 Ordonnances',
              appointment['prescriptions'],
              (prescriptions) => OrdonnanceScreen(prescriptions: prescriptions),
              (presc) => presc['description'],
              Colors.purple[100]!,
              Colors.purple[700]!,
            ),

          // Diet plans section
          if (appointment['dietPlans'] != null &&
              appointment['dietPlans'].isNotEmpty)
            _buildSectionWithNavigation(
              '🥗 Régimes',
              appointment['dietPlans'],
              (dietPlans) => RegimeScreen(dietPlans: dietPlans),
              (diet) => '${diet['dietType']}: ${diet['description']}',
              Colors.green[100]!,
              Colors.green[700]!,
            ),

          // Documents section
          if (appointment['documents'] != null &&
              appointment['documents'].isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '📁 Documents',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange[50],
              ),
              child: Column(
                children:
                    appointment['documents'].map<Widget>((doc) {
                      // Déterminer le type de fichier
                      final String fileUrl = doc['file']?.toString() ?? '';
                      final bool isImage =
                          fileUrl.toLowerCase().contains('.jpg') ||
                          fileUrl.toLowerCase().contains('.jpeg') ||
                          fileUrl.toLowerCase().contains('.png') ||
                          fileUrl.toLowerCase().contains('.gif') ||
                          fileUrl.contains('/image/upload/');

                      // Sélectionner l'icône appropriée
                      final IconData fileIcon =
                          isImage ? Icons.image : Icons.picture_as_pdf;
                      final Color iconColor = isImage ? Colors.red : Colors.red;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(fileIcon, color: iconColor),
                        ),
                        title: Text(
                          doc['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(doc['description'] ?? ''),

                        onTap: () => _openDocument(context, doc),
                      );
                    }).toList(),
              ),
            ),
          ],

          if ((appointment['notes'] == null || appointment['notes'].isEmpty) &&
              (appointment['prescriptions'] == null ||
                  appointment['prescriptions'].isEmpty) &&
              (appointment['dietPlans'] == null ||
                  appointment['dietPlans'].isEmpty) &&
              (appointment['documents'] == null ||
                  appointment['documents'].isEmpty))
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text(
                      'Aucun détail supplémentaire',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Ajoutez cette fonction dans votre classe _HistoryAppointmentScreenState
  void _openDocument(BuildContext context, Map<String, dynamic> doc) {
    // Vérifier que doc['file'] existe et n'est pas vide
    if (doc['file'] == null || doc['file'].toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien vers le fichier manquant ou invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String fileUrl = doc['file'].toString();
    final String title = doc['title'] ?? 'Document';

    debugPrint('URL du fichier: $fileUrl');

    try {
      // Détecter si c'est une image basé sur l'URL ou l'extension
      bool isImage =
          fileUrl.toLowerCase().contains('.jpg') ||
          fileUrl.toLowerCase().contains('.jpeg') ||
          fileUrl.toLowerCase().contains('.png') ||
          fileUrl.toLowerCase().contains('.gif') ||
          fileUrl.contains('/image/upload/');

      if (isImage) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(url: fileUrl, title: title),
          ),
        );
      } else {
        // Traiter comme PDF par défaut
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(url: fileUrl, title: title),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture du document : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ouverture du document : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionWithNavigation(
    String title,
    List<dynamic> items,
    Widget Function(List<Map<String, dynamic>>) navigationDestination,
    String Function(dynamic) itemDescriptionBuilder,
    Color backgroundColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF4A6572),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => navigationDestination(
                          List<Map<String, dynamic>>.from(items),
                        ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6572).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Voir plus',
                      style: TextStyle(
                        color: Color(0xFF4A6572),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF4A6572),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                items.take(2).map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: textColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${itemDescriptionBuilder(item).split(' ').take(5).join(' ')}...",
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
        if (items.length > 2)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              '+ ${items.length - 2} autres...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}
