// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:e_health_front/screens/auth/forgotPasswordScreen.dart';
import 'package:e_health_front/screens/auth/signupScreen.dart';
import 'package:e_health_front/screens/bottom_nav/navigation.dart';
import 'package:e_health_front/screens/styles/colors.dart';
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
  String? _errorMessage; // New variable to store error message

  // Fonction pour gérer la connexion
  Future<void> _loginUser() async {
    // Reset error message at the start of login attempt
    setState(() {
      _errorMessage = null;
    });

    final loginData = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    final responseData = await _apiService.loginUser(loginData);
    final loginResponse = responseData["loginResponse"];
    final articlesResponse = responseData["articlesResponse"];
    final userData = responseData["userData"];

    // Après la connexion réussie dans la méthode _loginUser()
    if (loginResponse != null &&
        loginResponse["accessToken"] != null &&
        loginResponse["role"] == "patient") {
      print("Connexion réussie : ${loginResponse['accessToken']}");

      // Stocker les informations de l'utilisateur
      Provider.of<UserProvider>(context, listen: false).setUser(userData);

      // Stocker les articles
      if (articlesResponse != null) {
        Provider.of<ArticleProvider>(
          context,
          listen: false,
        ).setArticles(List<Map<String, dynamic>>.from(articlesResponse));
      }

      // Navigation vers la page principale avec remplacement pour éviter de revenir au login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Navigation()),
      );
    } else {
      // Gérer les erreurs de connexion
      setState(() {
        _errorMessage = "email ou mot de passe incorrect";
      });
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
                      SizedBox(height: height * .15),
                      Image.asset('images/logo7.png', width: 150, height: 150),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Heal',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(MyColors.color2),
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'ora',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(MyColors.color2),
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Display error message if exists
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
                            backgroundColor: Color(
                              MyColors.color2,
                            ) /*Colors.blue*/,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Se Connecter',
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
                                    color: Color(
                                      MyColors.color2,
                                    ) /*Color(0xFF0389F6)*/,
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
                        Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.black,
                          size: 30,
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
