import 'package:e_health_front/screens/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/widgets/bezierContainer.dart';
import '../../services/api_service.dart';
import 'verifyOtpPageScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String message = '';

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void sendEmail() async {
    if (!isValidEmail(emailController.text)) {
      setState(() {
        message = "Veuillez entrer un email valide.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _apiService.requestPasswordReset(emailController.text);
    setState(() {
      _isLoading = false;
      message = success ? "Code envoyé !" : "Erreur !";
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpScreen(email: emailController.text),
          ),
        );
      }
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
                        'Mot de passe oublié',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Veuillez entrer votre email pour recevoir le code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: emailController,
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
                      SizedBox(height: 40),
                      _isLoading
                          ? CircularProgressIndicator()
                          : Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  offset: Offset(2, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(MyColors.color2),
                                  Color(MyColors.color2),
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: sendEmail, // Action au clic
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors
                                        .transparent, // Fond transparent pour garder le dégradé
                                shadowColor:
                                    Colors
                                        .transparent, // Enlever l'ombre par défaut du bouton
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Envoyer',
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
                                message == "Code envoyé !"
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
