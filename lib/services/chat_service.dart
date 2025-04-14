import 'dart:convert';
import 'package:e_health_front/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final String baseUrl = "http://localhost:3000/api";

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
    
    print('chatId: $chatId');
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$chatId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
