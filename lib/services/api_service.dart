import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'chat_service.dart'; // Make sure to import the ChatService

class ApiService {
  //final String baseUrl = "http://10.0.2.2:3000/api";
  final String baseUrl = "http://localhost:3000/api";

  String? token;
  final ChatService _chatService = ChatService(); // Create ChatService instance

  Future<http.Response> registerUser(Map<String, dynamic> userData) async {
    final String url = '$baseUrl/auth/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );
    return response;
  }

  // Connexion de l'utilisateur with chat integration
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

      // Sauvegarder le token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);

      // Initialize socket connection and notifications
      await _chatService.initializeNotifications();
      await _chatService.initializeSocket();

      // Get all user chats and join them
      try {
        List<dynamic> chats = await _chatService.getChats();
        for (var chat in chats) {
          String chatId = chat['_id'];
          _chatService.joinChat(chatId);

          // Set up message listener for each chat
          _chatService.listenForMessages(chatId, (message) {
            // This callback will be executed when new messages arrive
            // You might want to update this based on your app's architecture
            print(
              "New message received in chat $chatId: ${message['content']}",
            );
          });
        }
      } catch (e) {
        print("Error initializing chats: $e");
        // Continue login process even if chat initialization fails
      }

      // Récupération des articles
      final articlesResponse = await http.get(
        Uri.parse('$baseUrl/articles'),
        headers: {"Content-Type": "application/json"},
      );

      List<dynamic> articles = jsonDecode(articlesResponse.body);
      articles = articles.reversed.toList();
      // Ajouter le nom du docteur à chaque article
      for (int i = 0; i < articles.length; i++) {
        final doctorId = articles[i]['idDoctor'];
        if (doctorId != null) {
          final doctorResponse = await http.get(
            Uri.parse('$baseUrl/doctors/${doctorId['_id']}'),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
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
      return {
        "userData": userData,
        "loginResponse": jsonDecode(response.body),
        "articlesResponse": articles, // Use the modified articles list
        "chats": await _chatService.getChats(), // Add chats to the response
      };
    } else {
      // Échec de l'authentification, on retourne seulement cette réponse
      return {
        "loginResponse": jsonDecode(response.body),
        "articlesResponse": null,
        "userData": null,
        "chats": null,
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
    return SharedPreferences.getInstance().then((prefs) {
      token = prefs.getString("token");
    });
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

  Future<List<dynamic>> getNotifications(String token) async {
    final url = Uri.parse('$baseUrl/notifications');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? token;
    // if (token == null) {
    //   throw Exception("Token non défini");
    // }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data['notifications'];
    } else {
      throw Exception('Erreur lors de la récupération des notifications');
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    final url = Uri.parse('$baseUrl/notifications/$notificationId/read');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? token;
    if (token == null) {
      throw Exception("Token non défini");
    }
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      print('Notification introuvable ou n’appartient pas à l’utilisateur.');
      return false;
    } else {
      print('Erreur (${response.statusCode}): ${response.body}');
      throw Exception('Erreur lors du marquage de la notification comme lue');
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
    for (int i = 0; i < confirmedAppointments.length; i++) {
      String doctorId = confirmedAppointments[i]['doctor']['_id'];
      try {
        Map<String, dynamic> doctorDetails = await fetchDoctorById(doctorId);

        // Add doctor's image to the appointment
        confirmedAppointments[i]['doctor']['image'] = doctorDetails['image'];
      } catch (e) {
        confirmedAppointments[i]['doctor']['image'] = null; // Optional default
      }
    }

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
    for (int i = 0; i < pendingAppointments.length; i++) {
      String doctorId = pendingAppointments[i]['doctor']['_id'];
      try {
        Map<String, dynamic> doctorDetails = await fetchDoctorById(doctorId);

        // Add doctor's image to the appointment
        pendingAppointments[i]['doctor']['image'] = doctorDetails['image'];
      } catch (e) {
        pendingAppointments[i]['doctor']['image'] = null; // Optional default
      }
    }
    return pendingAppointments;
  }

  Future<List<Map<String, dynamic>>> fetchCanceledAppointments() async {
    // Fetch all appointments
    List<Map<String, dynamic>> myAppointments = await fetchMyAppointments();

    // Filter to get only canceled appointments
    List<Map<String, dynamic>> canceledAppointments =
        myAppointments
            .where((appointment) => appointment['status'] == 'canceled')
            .toList();

    // Sort appointments by date (most recent first)
    canceledAppointments.sort(
      (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
    );

    // Enhance each appointment with doctor's image
    for (int i = 0; i < canceledAppointments.length; i++) {
      String doctorId = canceledAppointments[i]['doctor']['_id'];
      try {
        Map<String, dynamic> doctorDetails = await fetchDoctorById(doctorId);

        // Add doctor's image to the appointment
        canceledAppointments[i]['doctor']['image'] = doctorDetails['image'];
      } catch (e) {
        canceledAppointments[i]['doctor']['image'] = null; // Optional default
      }
    }

    return canceledAppointments;
  }

  Future<List<Map<String, dynamic>>> fetchCompletedAppointments(
    String iddoctor,
  ) async {
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

    for (int i = 0; i < completedAppointments.length; i++) {
      String doctorId = completedAppointments[i]['doctor']['_id'];
      try {
        Map<String, dynamic> doctorDetails = await fetchDoctorById(doctorId);

        // Add doctor's image to the appointment
        completedAppointments[i]['doctor']['image'] = doctorDetails['image'];
      } catch (e) {
        completedAppointments[i]['doctor']['image'] = null; // Optional default
      }
    }
    return completedAppointments;
  }

  // Récupérer les détails d'un rendez-vous
  Future<Map<String, dynamic>> getAppointmentDetails(
    String appointmentId,
  ) async {
    final String url =
        '$baseUrl/appointments/appointmentDetails/$appointmentId';
    await loadToken(); // Charger le token

    if (token == null) {
      throw Exception("Token non défini");
    }

    final response = await http.get(
      Uri.parse(url),
      // headers: {
      //   "Content-Type": "application/json",
      //   "Authorization": "Bearer $token",
      // },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retourne les détails du rendez-vous
    } else {
      throw Exception(
        'Erreur lors de la récupération des détails du rendez-vous : ${response.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllAppointmentDetails(
    String iddoctor,
  ) async {
    try {
      // Étape 1 : récupérer tous les rendez-vous complétés du docteur
      List<Map<String, dynamic>> completedAppointments =
          await fetchCompletedAppointments(iddoctor);

      // Étape 2 : pour chaque rendez-vous, récupérer les détails
      List<Map<String, dynamic>> detailedAppointments = [];

      for (var appointment in completedAppointments) {
        try {
          String appointmentId = appointment['_id'];
          Map<String, dynamic> details = await getAppointmentDetails(
            appointmentId,
          );
          detailedAppointments.add(details);
        } catch (e) {
          print(
            "Erreur lors de la récupération des détails pour l'ID ${appointment['_id']}: $e",
          );
        }
      }

      return detailedAppointments;
    } catch (e) {
      print("Erreur dans getAllAppointmentDetails: $e");
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    final String url = '$baseUrl/appointments/$appointmentId/update';
    await loadToken(); // Charger le token

    if (token == null) {
      throw Exception("Token non défini");
    }
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

  Future<List<Map<String, dynamic>>> getDoctorsBySpeciality({
    required String specialityName,
  }) async {
    final url = Uri.parse('$baseUrl/doctors/speciality/$specialityName');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Ajoute "Authorization" si ton API est protégée par JWT
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur de chargement des docteurs : ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updatePasswordByOldPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/auth/change-password");
    await loadToken();
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Erreur inconnue",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion"};
    }
  }

  // Get user chats
  Future<List<Map<String, dynamic>>> getUserChats() async {
    try {
      List<dynamic> chats = await _chatService.getChats();
      return chats.map((chat) => chat as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error getting user chats: $e");
      throw Exception('Failed to load chats');
    }
  }

  // Create a chat with a doctor
  Future<Map<String, dynamic>> createChatWithDoctor(String doctorId) async {
    try {
      final response = await _chatService.createChat(doctorId: doctorId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Chat created successfully
        Map<String, dynamic> chatData = jsonDecode(response.body);

        // Join the new chat
        _chatService.joinChat(chatData['_id']);

        // Set up listener for the new chat
        _chatService.listenForMessages(chatData['_id'], (message) {
          print(
            "New message received in chat ${chatData['_id']}: ${message['content']}",
          );
        });

        return chatData;
      } else {
        throw Exception('Failed to create chat: ${response.body}');
      }
    } catch (e) {
      print("Error creating chat with doctor: $e");
      throw Exception('Error creating chat');
    }
  }

  // Send text message
  Future<bool> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    await loadToken();
    if (token == null) {
      throw Exception("Token non défini");
    }

    try {
      final response = await _chatService.sendTextMessage(
        token: token!,
        chatId: chatId,
        content: content,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error sending text message: $e");
      return false;
    }
  }

  // Send image message
  Future<bool> sendImageMessage({
    required String chatId,
    required File imageFile,
  }) async {
    await loadToken();
    if (token == null) {
      throw Exception("Token non défini");
    }

    try {
      final response = await _chatService.sendImageMessage(
        token: token!,
        chatId: chatId,
        imageFile: imageFile,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error sending image message: $e");
      return false;
    }
  }

  // Get chat messages
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    try {
      List<dynamic> messages = await _chatService.getMessages(chatId);
      return messages
          .map((message) => message as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error getting chat messages: $e");
      throw Exception('Failed to load messages');
    }
  }

  Future<void> logout() async {
    // Disconnect from socket
    _chatService.disconnect();

    // Clear token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le token
    token = null;
  }

  Future<bool> isUserLoggedIn() async {
    await loadToken();
    // Vérifier si le token existe
    if (token == null || token!.isEmpty) {
      return false;
    }
    // Vérifier si le token est valide (non expiré)
    try {
      bool isExpired = JwtDecoder.isExpired(token!);
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  Future<String> sendMessageChatbot(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': message}),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Échec de connexion au serveur: $e');
    }
  }
}
