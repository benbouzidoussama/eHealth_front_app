import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  //final String baseUrl = "http://10.0.2.2:3000/api";
  final String baseUrl = "http://localhost:3000/api";

  String? token;

  Future<http.Response> registerUser(Map<String, dynamic> userData) async {
    final String url = '$baseUrl/auth/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );
    return response;
  }

  // Connexion de l'utilisateur
  Future<Map<String, dynamic>> loginUser(Map<String, String> loginData) async {
    final String url = '$baseUrl/auth/login';

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginData),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      token = responseBody["accessToken"];
      await loadToken(); // Charger le token avant d'utiliser JwtDecoder
      // Vérifier si le token est défini
      if (token == null) {
        throw Exception("Token non défini");
      }
      // Sauvegarder le token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);
      // Récupération des articles
      final articlesResponse = await http.get(
        Uri.parse('$baseUrl/articles'),
        headers: {"Content-Type": "application/json"},
      );

      List<dynamic> articles = jsonDecode(articlesResponse.body);
      // Ajouter le nom du docteur à chaque article
      for (int i = 0; i < articles.length; i++) {
        final doctorId = articles[i]['idDoctor'];
        if (doctorId != null) {
          final doctorResponse = await http.get(
            Uri.parse('$baseUrl/doctors/$doctorId'),
            headers: {"Content-Type": "application/json"},
          );
          if (doctorResponse.statusCode == 200) {
            final doctorData = jsonDecode(doctorResponse.body);
            articles[i]['doctorName'] =
                doctorData['firstName'] + ' ' + doctorData['lastName'] ??
                "Inconnu"; // Ajoute le nom du docteur
          } else {
            articles[i]['doctorName'] =
                "Inconnu"; // Si le docteur n'est pas trouvé
          }
        } else {
          articles[i]['doctorName'] =
              "Non spécifié"; // Si aucun doctorId n'est associé
        }
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      String userId = decodedToken["id"] ?? "ID non trouvé";
      final userResponse = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {"Content-Type": "application/json"},
      );
      final userData = jsonDecode(userResponse.body);
      print("userData: $userData");
      return {
        "userData": userData,
        "loginResponse": jsonDecode(response.body),
        "articlesResponse": articles, // Use the modified articles list
      };
    } else {
      // Échec de l'authentification, on retourne seulement cette réponse
      return {
        "loginResponse": jsonDecode(response.body),
        "articlesResponse": null,
        "userData": null,
      };
    }
  }

  // Next Appointment
  Future<List<Map<String, dynamic>>> fetchNextAppointment() async {
    List<Map<String, dynamic>> firstAppointment = [];
    List<Map<String, dynamic>> AppointmentsConfirmed =
        await fetchConfirmedAppointments();
    if (AppointmentsConfirmed.isNotEmpty) {
      firstAppointment = [AppointmentsConfirmed.first];
    }
    return firstAppointment;
  }

  // Demander la réinitialisation du mot de passe par e-mail
  Future<bool> requestPasswordReset(String email) async {
    final String url = '$baseUrl/auth/request-reset';

    final response = await http.post(Uri.parse(url), body: {"email": email});

    return response.statusCode == 200;
  }

  // Vérifier le code OTP
  Future<String?> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      body: {"email": email, "otp": otp},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"]; // Supposons que l'API renvoie un token
    }
    return null; // Retourne `null` si OTP invalide
  }

  //réinitialiser le mot de passe
  Future<String?> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-passwordPatient'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"token": token, "newPassword": newPassword}),
    );
    if (response.statusCode == 200) {
      return "Mot de passe changé !";
    } else {
      final data = jsonDecode(response.body);
      return data['message'] ?? "Erreur inconnue";
    }
  }

  // Récupérer tous les docteurs
  Future<List<Map<String, dynamic>>> fetchAllDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/doctors'));

    if (response.statusCode == 200) {
      List<dynamic> doctors = jsonDecode(response.body);
      return doctors.map((doctor) => doctor as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // Récupérer les docteurs de l'utilisateur
  Future<List<Map<String, dynamic>>> fetchMyDoctors() async {
    await loadToken(); // Charger le token avant d'utiliser JwtDecoder
    // Vérifier si le token est défini
    if (token == null) {
      throw Exception("Token non défini");
    }
    // Décoder le token
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    // Récupérer l'ID utilisateur
    String userId = decodedToken["id"] ?? "ID non trouvé";

    final response = await http.get(
      Uri.parse('$baseUrl/patients/$userId/doctors'),
    );

    if (response.statusCode == 200) {
      List<dynamic> doctors = jsonDecode(response.body);
      return doctors.map((doctor) => doctor as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load my doctors');
    }
  }

  // Charger le token depuis SharedPreferences
  Future<void> loadToken() async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);
    }
    return SharedPreferences.getInstance().then((prefs) {
      token = prefs.getString("token");
    });
    //print("Token chargé depuis SharedPreferences: $token");
  }

  Future<List<String>> fetchAvailableSlots(String doctorId, String date) async {
    final String url = '$baseUrl/appointments/$doctorId/slotsDoctor?date=$date';
    await loadToken();
    if (token == null) {
      throw Exception("Token non défini");
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['availableSlots']);
    } else {
      throw Exception('Failed to fetch available slots');
    }
  }

  // Réserver un rendez-vous
  Future<void> bookAppointment({
    required String doctorId,
    required String date,
    required String time,
    required String type,
  }) async {
    final String url = '$baseUrl/appointments/book';
    await loadToken();
    if (token == null) {
      throw Exception("Token non défini");
    }
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "doctorId": doctorId,
        "date": date,
        "time": time,
        "type": type,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to book appointment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchDoctorById(String doctorId) async {
    final String url = '$baseUrl/doctors/$doctorId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final doctorData = jsonDecode(response.body) as Map<String, dynamic>;
      return doctorData;
    } else {
      throw Exception('Failed to fetch doctor data');
    }
  }

  // Récupérer les rendez-vous de l'utilisateur
  Future<List<Map<String, dynamic>>> fetchMyAppointments() async {
    await loadToken(); // Charger le token avant d'utiliser JwtDecoder
    if (token == null) {
      throw Exception("Token non défini");
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    String userId = decodedToken["id"] ?? "ID non trouvé";

    final response = await http.get(
      Uri.parse('$baseUrl/patients/$userId/appointments'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> appointments =
          data['appointments']; // Accéder à la clé "appointments"

      final List<Map<String, dynamic>> myAppointments =
          appointments
              .map((appointment) => appointment as Map<String, dynamic>)
              .toList();

      // Ajouter le nom du docteur à chaque rendez-vous
      for (int i = 0; i < myAppointments.length; i++) {
        final doctorId = myAppointments[i]['doctor']['_id'];
        if (doctorId != null) {
          final doctorResponse = await http.get(
            Uri.parse('$baseUrl/doctors/$doctorId'),
            headers: {"Content-Type": "application/json"},
          );
          if (doctorResponse.statusCode == 200) {
            final doctorData = jsonDecode(doctorResponse.body);
            myAppointments[i]['doctor']['doctorName'] =
                doctorData['firstName'] + ' ' + doctorData['lastName'] ??
                "Inconnu";
          } else {
            myAppointments[i]['doctorName'] = "Inconnu";
          }
        } else {
          myAppointments[i]['doctorName'] = "Non spécifié";
        }
      }

      //print("myAppointments: $myAppointments");
      return myAppointments;
    } else {
      throw Exception('Failed to load my appointments');
    }
  }

  Future<List<Map<String, dynamic>>> fetchConfirmedAppointments() async {
    List<Map<String, dynamic>> myAppointments = await fetchMyAppointments();
    List<Map<String, dynamic>> confirmedAppointments =
        myAppointments
            .where((appointment) => appointment['status'] == 'confirmed')
            .toList();
    // Trier les rendez-vous en fonction de la date
    confirmedAppointments.sort(
      (a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
    );
    print("confirmedAppointments: $confirmedAppointments");
    return confirmedAppointments;
  }

  Future<List<Map<String, dynamic>>> fetchPendingAppointments() async {
    List<Map<String, dynamic>> myAppointments = await fetchMyAppointments();

    List<Map<String, dynamic>> pendingAppointments =
        myAppointments
            .where((appointment) => appointment['status'] == 'pending')
            .toList();

    // Trier les rendez-vous en fonction de la date
    pendingAppointments.sort(
      (a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
    );

    return pendingAppointments;
  }

  Future<List<Map<String, dynamic>>> fetchCanceledAppointments() async {
    List<Map<String, dynamic>> myAppointments = await fetchMyAppointments();
    List<Map<String, dynamic>> canceledAppointments =
        myAppointments
            .where((appointment) => appointment['status'] == 'canceled')
            .toList();
    // Trier les rendez-vous en fonction de la date
    canceledAppointments.sort(
      (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
    );
    return canceledAppointments;
  }

  Future<List<Map<String, dynamic>>> fetchCompletedAppointments(String iddoctor) async {
    List<Map<String, dynamic>> myAppointments = await fetchMyAppointments();
    List<Map<String, dynamic>> completedAppointments =
        myAppointments
            .where(
              (appointment) =>
                  appointment['status'] == 'completed' &&
                  appointment['doctor']['_id'] == iddoctor,
            )
            .toList();
    // Trier les rendez-vous en fonction de la date
    completedAppointments.sort(
      (a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
    );
    print("completedAppointments: $completedAppointments");
    return completedAppointments;
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    final String url = '$baseUrl/appointments/$appointmentId/update';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"status": status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update appointment status: ${response.body}');
    }
  }

  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String newDate,
    required String newTime,
  }) async {
    final String url = '$baseUrl/appointments/$appointmentId/reschedule';
    await loadToken(); // Charger le token

    if (token == null) {
      throw Exception("Token non défini");
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"newDate": newDate, "newTime": newTime}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du reprogrammation du rendez-vous : ${response.body}',
      );
    }

    print("Rendez-vous reprogrammé avec succès");
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updatedData,
  ) async {
    final String url = '$baseUrl/auth/updateProfile';
    await loadToken(); // Charger le token

    if (token == null) {
      throw Exception("Token non défini");
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retourne la réponse complète
    } else {
      throw Exception(
        'Erreur lors de la mise à jour du profil : ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> updateProfileImage(File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Récupère le token

      if (token == null) {
        return {"success": false, "message": "Utilisateur non authentifié"};
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/updateProfileImage'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return {"success": true, "data": responseData};
      } else {
        return {
          "success": false,
          "message": json.decode(response.body)['message'],
        };
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }

  // Future<void> logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('token'); // Supprime le token
  // }
}
