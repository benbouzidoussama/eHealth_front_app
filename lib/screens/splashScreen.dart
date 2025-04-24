import 'dart:convert';
import 'package:e_health_front/screens/auth/welcomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:e_health_front/screens/bottom_nav/navigation.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/providers/article_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await _apiService.isUserLoggedIn();
    
    if (isLoggedIn) {
      // Récupérer les données de l'utilisateur et les articles au démarrage
      await _loadUserData();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Navigation()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
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
      
      // Ajouter le nom du docteur à chaque article
      for (int i = 0; i < articles.length; i++) {
        final doctorId = articles[i]['idDoctor'];
        if (doctorId != null) {
          final doctorResponse = await  http.get(
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