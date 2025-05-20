// ignore_for_file: library_private_types_in_public_api, use_super_parameters, sized_box_for_whitespace

import 'package:e_health_front/screens/auth/loginScreen.dart';
import 'package:e_health_front/screens/styles/colors.dart';
import 'package:e_health_front/widgets/bezierContainer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:e_health_front/services/api_service.dart';

final ApiService _apiService = ApiService();

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDate;

  // Contrôleurs pour les champs de texte
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: height * .15),
                        Image.asset(
                          'images/logo7.png',
                          width: 150,
                          height: 150,
                        ),

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
                        _buildTextField(
                          "Prénom",
                          "prénom",
                          Icons.person,
                          _firstNameController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return 'Veuillez entrer un prénom valide';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "Nom",
                          "nom",
                          Icons.person,
                          _lastNameController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return 'Veuillez entrer un nom valide';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "Email",
                          "email",
                          Icons.email,
                          _emailController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "CIN",
                          "cin",
                          Icons.credit_card,
                          _cinController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^\d{8}$').hasMatch(value)) {
                              return 'Le CIN doit comporter 8 chiffres';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "Téléphone",
                          "téléphone",
                          Icons.phone,
                          _phoneController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^\d{8}$').hasMatch(value)) {
                              return 'Le numéro de téléphone doit comporter 8 chiffres';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "Adresse",
                          "adresse",
                          Icons.home,
                          _addressController,
                          (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer votre adresse';
                            }
                            return null;
                          },
                        ),
                        _buildDatePickerField(),
                        _buildPasswordField(
                          "Mot de passe",
                          _obscurePassword,
                          (val) {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          _passwordController,
                          (value) {
                            if (value!.isEmpty || value.length < 8) {
                              return 'Le mot de passe doit comporter au moins 8 caractères';
                            }
                            return null;
                          },
                        ),
                        _buildPasswordField(
                          "Confirmer le mot de passe",
                          _obscureConfirmPassword,
                          (val) {
                            setState(
                              () =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                            );
                          },
                          _confirmPasswordController,
                          (value) {
                            if (value!.isEmpty ||
                                value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildRegisterButton(),
                        _buildLoginRedirect(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: controller,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: Icon(icon, color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Date de naissance",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 10),
          TextField(
            readOnly: true,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              hintText:
                  _selectedDate == null
                      ? "date de naissance"
                      : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.black54),
                onPressed: () => _selectDate(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    bool obscureText,
    Function onPressed,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: controller,
            style: TextStyle(fontSize: 20),
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: "mot de passe",
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () => onPressed(null),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _validateAndRegister,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          gradient: LinearGradient(
            colors: [Color(MyColors.color2), Color(MyColors.color2)],
          ),
        ),
        child: Text(
          'S\'inscrire',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Vous avez déjà un compte ?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Text(
              'Connexion',
              style: TextStyle(
                color: Color(MyColors.color2) /*Color(0xFF0389F6)*/,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
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
              Icon(Icons.keyboard_arrow_left, color: Colors.black, size: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    final userData = {
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "email": _emailController.text,
      "cin": _cinController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "dateOfBirth":
          _selectedDate != null ? _selectedDate!.toIso8601String() : "",
      "password": _passwordController.text,
      "role": "patient",
    };

    final response = await _apiService.registerUser(userData);
    final data = jsonDecode(response.body);
    final errorMessage = data['message'] ?? 'Erreur inconnue';
    if (response.statusCode == 200 ||
        data['message'] == "refreshToken is not defined" ||
        errorMessage == 'Erreur inconnue') {
      print("Inscription réussie: ${data['message']}");
      _showSuccessDialog("Inscription réussie",Icons.check_circle,Colors.green);
    } else if (errorMessage == 'User already exists') {
      _showSuccessDialog("Cet utilisateur existe déjà",Icons.error,Colors.red);
    } else {
      final errorData = jsonDecode(response.body);
      String errorMessage = errorData['message'] ?? 'Erreur inconnue';
      print("Erreur: $errorMessage");
      
        _showSuccessDialog("Erreur lors de l'inscription",Icons.error,Colors.red);
      
    }
  }

  void _validateAndRegister() {
    print("Validation en cours...");
    if (_formKey.currentState!.validate()) {
      _registerUser(); // Envoi des données au backend
    }
  }

  void _showSuccessDialog(String message,IconData icon,Color color) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Empêche de fermer le dialogue en cliquant à l'extérieur
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône animée
              Icon(icon,
                size:80,
                color: color,
              ),
              const SizedBox(height: 20),
              // Message de succès
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(MyColors.color2) /*Color(0xFF4880D8)*/,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialogue
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
