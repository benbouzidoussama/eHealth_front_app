import 'package:e_health_front/screens/auth/loginScreen.dart';
import 'package:e_health_front/screens/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/widgets/bezierContainer.dart';
import '../../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  ResetPasswordScreen({required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ApiService _apiService = ApiService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String message = '';
  String? passwordError;
  
  // Fonction pour valider le mot de passe
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return "Veuillez saisir un mot de passe";
    } else if (password.length < 8) {
      return "Le mot de passe doit contenir au moins 8 caractères";
    }
    return null;
  }

  void resetPassword() async {
    // Validation du mot de passe
    final passwordValidation = validatePassword(passwordController.text);
    if (passwordValidation != null) {
      setState(() {
        passwordError = passwordValidation;
      });
      return;
    }
    
    // Vérification de la correspondance des mots de passe
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        message = "Les mots de passe ne correspondent pas.";
        passwordError = null;
      });
      return;
    }

    setState(() {
      passwordError = null;
      _isLoading = true;
    });

    final result = await _apiService.resetPassword(
      widget.token,
      passwordController.text,
    );

    setState(() {
      _isLoading = false;
      message =
          result != null && result == "Mot de passe changé !"
              ? result
              : "Erreur lors du changement du mot de passe";
    });
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
                      Text(
                        'Nouveau mot de passe',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Veuillez entrer et confirmer votre nouveau mot de passe (minimum 8 caractères)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 30),

                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: "Nouveau mot de passe",
                          errorText: passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                        onChanged: (value) {
                          // Valider à chaque changement pour donner un feedback immédiat
                          setState(() {
                            passwordError = validatePassword(value);
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      TextField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: "Confirmer le mot de passe",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
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
                      SizedBox(height: 50),

                      _isLoading
                          ? CircularProgressIndicator()
                          : GestureDetector(
                            onTap: resetPassword,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(MyColors.color2),
                                    Color(MyColors.color2),
                                  ],
                                ),
                              ),
                              child: Text(
                                'Changer',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      SizedBox(height: 20),

                      if (message.isNotEmpty)
                        Text(
                          message,
                          style: TextStyle(
                            color:
                                message == "Mot de passe changé !"
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Retour à la connexion',
                          style: TextStyle(
                            color: Color(MyColors.color2) /*Color(0xFF0389F6)*/,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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