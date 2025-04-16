import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ChatService {
  final String baseUrl = "http://localhost:3000/api";
  //final String baseUrl = "http://10.0.2.2:3000/api";

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getChats() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/chat/chats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load chats');
    }
  }

  Future<List<dynamic>> getMessages(String chatId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$chatId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<http.Response> sendTextMessage({
    required String token,
    required String chatId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'chatId': chatId, 'type': 'text', 'content': content}),
    );

    return response;
  }

  Future<http.Response> sendImageMessage({
    required String token,
    required String chatId,
    required File imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/messages/send-image');

    final request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['chatId'] = chatId
          ..fields['type'] = 'image';

    final mimeType = lookupMimeType(imageFile.path)!.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
        filename: basename(imageFile.path),
      ),
    );

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
  
  Future<http.Response> createChat({
  required String token,
  required String doctorId,
}) async {
  final token = await getToken();
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    // Récupérer l'ID utilisateur
    String patientId = decodedToken["id"] ?? "ID non trouvé";

  final url = Uri.parse('$baseUrl/chat/createChat');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // facultatif selon ton authMiddleware
    },
    body: jsonEncode({
      'doctorId': doctorId,
      'patientId': patientId,
    }),
  );

  return response;
}

}
