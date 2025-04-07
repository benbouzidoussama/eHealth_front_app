import 'package:flutter/material.dart';
import 'package:e_health_front/services/api_service.dart';

class HistoryAppointmentScreen extends StatelessWidget {
  final String doctorId;

  HistoryAppointmentScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique des rendez-vous',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService().fetchCompletedAppointments(doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucun rendez-vous terminé trouvé.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          } else {
            final appointments = [
              {
                "_id": "67efaefd3b3bc1c5b8a949b0",
                "doctor": {
                  "_id": "67bc4b08a1485ab85f9a29fe",
                  "__t": "Doctor",
                  "speciality": "Dentist",
                  "doctorName": "moujib haouech",
                },
                "patient": "67c0500e8120019fe5ed3532",
                "date": "2025-04-05T00:00:00.000Z",
                "time": "12:20",
                "status": "confirmed",
                "type": "Consultation",
                "createdAt": "2025-04-04T10:05:49.929Z",
                "updatedAt": "2025-04-05T12:21:06.240Z",
                "__v": 0,
              },
              {
                "_id": "67ee8957087dd0e75d247407",
                "doctor": {
                  "_id": "67bc4b08a1485ab85f9a29fe",
                  "__t": "Doctor",
                  "speciality": "Dentist",
                  "doctorName": "moujib haouech",
                },
                "patient": "67c0500e8120019fe5ed3532",
                "date": "2025-04-07T00:00:00.000Z",
                "time": "11:40",
                "status": "confirmed",
                "type": "Consultation",
                "createdAt": "2025-04-03T13:12:56.399Z",
                "updatedAt": "2025-04-05T12:21:14.039Z",
                "__v": 0,
              },
            ];
            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final doctor = appointment['doctor'];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(
                      'Date : ${appointment['date'].toString().split('T')[0]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Heure : ${appointment['time']}\n'
                      'Type : ${appointment['type']}\n'
                      'Docteur : moujib haouech (Dentiste))',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
