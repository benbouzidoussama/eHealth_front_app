// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:e_health_front/screens/auth/forgotPasswordScreen.dart';
import 'package:e_health_front/screens/auth/signupScreen.dart';
import 'package:e_health_front/screens/bottom_nav/navigation.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/widgets/bezierContainer.dart';
import 'package:provider/provider.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/providers/article_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  // Fonction pour gérer la connexion
  Future<void> _loginUser() async {
    final loginData = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    final responseData = await _apiService.loginUser(loginData);
    final loginResponse = responseData["loginResponse"];
    final articlesResponse = responseData["articlesResponse"];
    final userData=responseData["userData"];
    

    if (loginResponse != null && loginResponse["accessToken"] != null) {
      print("Connexion réussie : ${loginResponse['accessToken']}");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Connexion réussie")));
      
      // Stocker les informations de l'utilisateur
      Provider.of<UserProvider>(context, listen: false).setUser(userData);
      // Stocker les articles
      if (articlesResponse != null) {
        Provider.of<ArticleProvider>(
          context,
          listen: false,
        ).setArticles(List<Map<String, dynamic>>.from(articlesResponse));
      }

      // Navigation vers la page principale
      Navigator.push(context, MaterialPageRoute(builder: (_) => Navigation()));
    } else {
      print("Échec de la connexion");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email ou mot de passe invalide")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'E',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.lightBlue,
                          ),
                          children: [
                            TextSpan(
                              text: '-H',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                              ),
                            ),
                            TextSpan(
                              text: 'l',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 30,
                              ),
                            ),
                            TextSpan(
                              text: 'eat',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                              ),
                            ),
                            TextSpan(
                              text: 'h',
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: "Email",
                          suffixIcon: Icon(Icons.email, color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          fillColor: Color(0xfff3f3f4),
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 50),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: "Mot de passe",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          fillColor: Color(0xfff3f3f4),
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Oublié mot de passe ?',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 60,
                        width:
                            double
                                .infinity, // Prend toute la largeur disponible
                        child: ElevatedButton(
                          onPressed:
                              _loginUser, // Appeler la logique de connexion
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Vous n\'avez pas de compte ?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    color: Color(0xFF0389F6),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[SizedBox(width: 5)],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.keyboard_arrow_left, color: Colors.black),
                        Text(
                          'Retour',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
