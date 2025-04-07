import 'package:flutter/material.dart';
import 'package:e_health_front/widgets/bezierContainer.dart';
import 'package:e_health_front/screens/auth/ResetPasswordScreen.dart';
import '../../services/api_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  VerifyOtpScreen({required this.email});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  String message = '';
  bool _isLoading = false;

  void verifyOtp() async {
    setState(() => _isLoading = true);

    final token = await _apiService.verifyOtp(widget.email, otpController.text);

    setState(() => _isLoading = false);

    if (token != null) {
      setState(() => message = "Code validé !");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(token: token)),
      );
    } else {
      setState(() => message = "Code invalide !");
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
                      Text(
                        'Vérification du code',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Veuillez entrer le code envoyé à votre email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: otpController,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: "Code OTP",
                          suffixIcon: Icon(Icons.lock, color: Colors.black54),
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
                          : Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            alignment: Alignment.center,
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
                                colors: [Colors.blue, Colors.lightBlue],
                              ),
                            ),
                            child: InkWell(
                              onTap: verifyOtp,
                              child: Text(
                                'Vérifier',
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
                                message == "Code validé!"
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
                          'Retour',
                          style: TextStyle(
                            color: Color(0xFF0389F6),
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
