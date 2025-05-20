import 'package:e_health_front/screens/appointment/updateAppointmentScreen.dart';
import 'package:e_health_front/screens/doctor/doctorProfilScreen.dart';
import 'package:e_health_front/screens/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/services/api_service.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAppointments();
  }

  void _refreshAppointments() {
    setState(() {
      _appointmentsFuture = _fetchAppointments();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    try {
      return await _apiService.fetchPendingAppointments();
    } catch (e) {
      throw Exception('Erreur : Impossible de charger les rendez-vous');
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showSuccessDialog(String message) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // Empêche de fermer le dialogue en cliquant à l'extérieur
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône animée
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                // Message de succès
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(
                      MyColors.color2,
                    ) /*Color(0xFF4880D8)*/,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialogue
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 221, 221),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun rendez-vous à venir'));
          } else {
            final appointments = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final doctor = appointment['doctor'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                doctor != null
                                    ? 'Dr. ${doctor['doctorName']}'
                                    : 'Docteur inconnu',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(doctor['speciality']),
                              trailing: CircleAvatar(
                                backgroundImage:
                                    doctor['image'] != null
                                        ? NetworkImage(doctor['image'])
                                        : AssetImage('images/avatar.jpg'),
                                radius: 35,
                              ),
                              onTap: () async {
                                try {
                                  final apiService = ApiService();
                                  final doctorData = await apiService
                                      .fetchDoctorById(doctor['_id']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DoctorProfilScreen(
                                            doctor: doctorData,
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erreur : Impossible de charger les données du docteur',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Divider(thickness: 1, height: 20),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      appointment['date'].toString().split(
                                        'T',
                                      )[0],
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      appointment['time'],
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color:
                                            appointment['status'] == 'confirmed'
                                                ? Colors.green
                                                : appointment['status'] ==
                                                    'pending'
                                                ? Colors.orange
                                                : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      appointment['status'] == 'confirmed'
                                          ? 'confirmé'
                                          : appointment['status'] == 'pending'
                                          ? 'en attente'
                                          : 'annulé',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    // Afficher une boîte de dialogue de confirmation
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (
                                            BuildContext context,
                                            StateSetter setState,
                                          ) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              backgroundColor: Colors.white,
                                              title: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Color(
                                                      MyColors.color2,
                                                    ),
                                                    size: 28,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Confirmation",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Êtes-vous sûr de vouloir annuler ce rendez-vous?',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                ],
                                              ),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 10,
                                                            ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop(); // Fermer la boîte de dialogue
                                                      },
                                                      child: Text(
                                                        "Non",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15),
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Color(
                                                          MyColors.color2,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 10,
                                                            ),
                                                      ),
                                                      onPressed: () async {
                                                        // Fermer la boîte de dialogue
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        //_fetchAppointments();
                                                        try {
                                                          // Appeler la fonction pour mettre à jour le statut
                                                          await _apiService
                                                              .updateAppointmentStatus(
                                                                appointment['_id'],
                                                                "canceled",
                                                              );

                                                          _showSuccessDialog(
                                                            "Rendez-vous annulé avec succès !",
                                                          );
                                                          _refreshAppointments();
                                                          // Rafraîchir la liste des rendez-vous
                                                          // setState(() {
                                                          //   _fetchAppointments();
                                                          // });
                                                        } catch (e) {
                                                          // Afficher un message d'erreur
                                                          //_showSuccessDialog();
                                                        }
                                                      },
                                                      child: Text(
                                                        "Oui",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 150,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F6FA),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Annuler",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                UpdateAppointmentScreen(
                                                  appointmentId:
                                                      appointment['_id'],
                                                  doctor: appointment['doctor'],
                                                ),
                                      ),
                                    ).then((value) {
                                      if (value == 'refresh') {
                                        setState(() {
                                          // pour mettre à jour l'affichage
                                          _refreshAppointments();
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 150,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        MyColors.color2,
                                      ) /*Colors.blueAccent*/,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Reprogrammer",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
