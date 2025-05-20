import 'package:e_health_front/screens/appointment/bookAppointment.dart';
import 'package:e_health_front/screens/medicalFile/historyAppointmentScreen.dart';
import 'package:e_health_front/screens/styles/colors.dart';
import 'package:flutter/material.dart';

//
class DoctorProfilScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  DoctorProfilScreen({super.key, required this.doctor}) {}
  String _translateDayToFrench(String englishDay) {
    Map<String, String> dayTranslations = {
      'Monday': 'Lundi',
      'Tuesday': 'Mardi',
      'Wednesday': 'Mercredi',
      'Thursday': 'Jeudi',
      'Friday': 'Vendredi',
      'Saturday': 'Samedi',
      'Sunday': 'Dimanche',
    };

    return dayTranslations[englishDay] ?? englishDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
        title: const Text(
          'Profil du Médecin',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar avec un contour élégant
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(MyColors.color2) /*Colors.blueAccent*/,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      doctor['image'] != null
                          ? NetworkImage(doctor['image'])
                          : AssetImage('images/avatar.jpg'), // Image du docteur
                ),
              ),
              const SizedBox(height: 16),

              // Nom et spécialité du docteur avec un texte stylisé
              Text(
                'Dr. ${doctor['firstName']} ${doctor['lastName']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                doctor['speciality'] ?? 'Spécialité inconnue',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(MyColors.color2) /*Colors.blueAccent*/,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Informations du docteur sous forme de carte
              _buildInfoCard([
                _buildInfoRow(
                  Icons.location_on,
                  doctor['address'] ?? 'Adresse non renseignée',
                ),
                _buildDivider(),
                _buildInfoRow(
                  Icons.phone,
                  doctor['phone'] ?? 'Téléphone non disponible',
                ),
                _buildDivider(),
                _buildInfoRow(
                  Icons.email,
                  doctor['email'] ?? 'Email non disponible',
                ),
              ]),

              const SizedBox(height: 20),

              // Période de travail du docteur
              _buildWorkScheduleCard(doctor['schedule'] ?? []),

              const SizedBox(height: 25),

              // Bouton Prendre un rendez-vous avec effet interactif
              InkWell(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BookAppointmentScreen(doctor: doctor),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(MyColors.color2), Color(MyColors.color1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.calendar_today, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Prendre un rendez-vous',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Bouton Historique des rendez-vous
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              HistoryAppointmentScreen(doctorId: doctor['_id']),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Color(MyColors.color2) /*Colors.blueAccent*/,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        color: Color(MyColors.color2) /*Colors.blueAccent*/,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Historique des rendez-vous',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(MyColors.color2) /*Colors.blueAccent*/,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour générer les cartes d'informations
  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // Fonction pour générer une ligne d'information avec icône
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color(MyColors.color1) /*Colors.blueAccent*/,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // Fonction pour générer un séparateur
  Widget _buildDivider() {
    return const Divider(color: Colors.grey, thickness: 0.6, height: 20);
  }

  // Fonction pour afficher les horaires de travail
  Widget _buildWorkScheduleCard(List<dynamic> schedule) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Color(MyColors.color1) /*Colors.blueAccent*/,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Horaires de travail",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              children:
                  schedule.map((daySchedule) {
                    final day = _translateDayToFrench(daySchedule['day']);
                    final periods = daySchedule['periods'] as List<dynamic>;
                    final periodsText =
                        periods.isNotEmpty
                            ? periods
                                .map(
                                  (period) =>
                                      "${period['startTime']} - ${period['endTime']}",
                                )
                                .join(" | ")
                            : "Fermé";

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: /*Colors.blue*/ Color(MyColors.color1),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            periodsText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
