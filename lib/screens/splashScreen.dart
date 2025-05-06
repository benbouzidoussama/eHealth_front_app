import 'dart:convert';
import 'package:e_health_front/screens/auth/welcomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:e_health_front/screens/bottom_nav/navigation.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:e_health_front/services/chat_service.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/providers/article_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _apiService = ApiService();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      bool isLoggedIn = await _apiService.isUserLoggedIn();
      
      if (isLoggedIn) {
        // Initialisation des notifications
        await _chatService.initializeNotifications();
        
        // Récupérer les données de l'utilisateur et les articles au démarrage
        await _loadUserData();
        
        // Initialisation du socket après avoir chargé les données
        await _initializeSocketAndChats();
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => Navigation()),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => WelcomeScreen()),
          );
        }
      }
    } catch (e) {
      print("Erreur lors de la vérification du statut de connexion: $e");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => WelcomeScreen()),
        );
      }
    }
  }

  Future<void> _initializeSocketAndChats() async {
    try {
      // Initialisation de la connexion socket
      await _chatService.initializeSocket();
      
      // Récupération des chats de l'utilisateur
      List<dynamic> chats = await _chatService.getChats();
      
      // Rejoindre chaque chat et configurer les écouteurs de messages
      for (var chat in chats) {
        String chatId = chat['_id'];
        _chatService.joinChat(chatId);
        
        // Configuration de l'écouteur pour les messages
        _chatService.listenForMessages(chatId, (message) {
          // Cette fonction sera exécutée lorsque de nouveaux messages arrivent
          print("Nouveau message reçu dans le chat $chatId: ${message['content']}");
          // Vous pourriez ajouter ici une logique pour les notifications
        });
      }
      
      // Stocker l'ID utilisateur pour les notifications
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await _apiService.loadToken();
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_apiService.token!);
      String userId = decodedToken["id"];
      await prefs.setString("userId", userId);
      
    } catch (e) {
      print("Erreur lors de l'initialisation du socket et des chats: $e");
      // Continuer même en cas d'erreur pour ne pas bloquer l'expérience utilisateur
    }
  }

  Future<void> _loadUserData() async {
    try {
      await _apiService.loadToken();
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_apiService.token!);
      String userId = decodedToken["id"];
      
      // Charger les données utilisateur
      final userResponse = await http.get(
        Uri.parse('${_apiService.baseUrl}/users/$userId'),
        headers: {"Content-Type": "application/json"},
      );
      final userData = jsonDecode(userResponse.body);
      
      // Récupération des articles
      final articlesResponse = await http.get(
        Uri.parse('${_apiService.baseUrl}/articles'),
        headers: {"Content-Type": "application/json"},
      );
      
      List<dynamic> articles = jsonDecode(articlesResponse.body);
      articles = articles.reversed.toList();
      // Ajouter le nom du docteur à chaque article
      for (int i = 0; i < articles.length; i++) {
        final doctorId = articles[i]['idDoctor'];
        if (doctorId != null) {
          final doctorResponse = await http.get(
            Uri.parse('${_apiService.baseUrl}/doctors/${doctorId['_id']}'),
            headers: {"Content-Type": "application/json"},
          );
          if (doctorResponse.statusCode == 200) {
            final doctorData = jsonDecode(doctorResponse.body);
            articles[i]['doctorName'] =
                doctorData['firstName'] + ' ' + doctorData['lastName'] ?? "Inconnu";
          } else {
            articles[i]['doctorName'] = "Inconnu";
          }
        } else {
          articles[i]['doctorName'] = "Non spécifié";
        }
      }
      
      // Stocker les données dans les providers
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).setUser(userData);
        Provider.of<ArticleProvider>(context, listen: false)
            .setArticles(List<Map<String, dynamic>>.from(articles));
      }
    } catch (e) {
      print("Erreur lors du chargement des données: $e");
      // En cas d'erreur, forcer la déconnexion
      await _apiService.logout();
      throw e; // Propager l'erreur pour que _checkLoginStatus puisse la gérer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'E',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.lightBlue,
                ),
                children: [
                  TextSpan(
                    text: '-H',
                    style: TextStyle(color: Colors.black, fontSize: 40),
                  ),
                  TextSpan(
                    text: 'l',
                    style: TextStyle(color: Colors.blue, fontSize: 40),
                  ),
                  TextSpan(
                    text: 'eat',
                    style: TextStyle(color: Colors.black, fontSize: 40),
                  ),
                  TextSpan(
                    text: 'h',
                    style: TextStyle(color: Colors.lightBlue, fontSize: 40),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}