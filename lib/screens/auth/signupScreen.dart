// ignore_for_file: library_private_types_in_public_api, use_super_parameters, sized_box_for_whitespace

import 'package:e_health_front/screens/auth/loginScreen.dart';
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

  // Controllers for text fields
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
                        SizedBox(height: height * .2),
                        Text(
                          'E-Health',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.lightBlue,
                          ),
                        ),
                        SizedBox(height: 50),
                        _buildTextField(
                          "First Name",
                          "first name",
                          Icons.person,
                          _firstNameController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return 'Please enter a valid first name';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "Last Name",
                          "last name",
                          Icons.person,
                          _lastNameController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return 'Please enter a valid last name';
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
                              return 'Please enter a valid email';
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
                              return 'CIN must be 8 digits';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "Phone",
                          "phone",
                          Icons.phone,
                          _phoneController,
                          (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^\d{8}$').hasMatch(value)) {
                              return 'Phone number must be 8 digits';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          "Address",
                          "address",
                          Icons.home,
                          _addressController,
                          (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        _buildDatePickerField(),
                        _buildPasswordField(
                          "Password",
                          _obscurePassword,
                          (val) {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          _passwordController,
                          (value) {
                            if (value!.isEmpty || value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        _buildPasswordField(
                          "Confirm Password",
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
                              return 'Passwords do not match';
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
            "Date of Birth",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 10),
          TextField(
            readOnly: true,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              hintText:
                  _selectedDate == null
                      ? "date of birth"
                      : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
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
              hintText: "password",
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
          gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
        ),
        child: Text(
          'Register',
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
              'Already have an account ?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Text(
              'Login',
              style: TextStyle(
                color: Color(0xFF0389F6),
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
              Icon(Icons.arrow_back, color: Colors.black, size: 30),
              Text(
                'Back',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Inscription réussie: ${data['message']}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Inscription réussie")));
    } else {
      final errorData = jsonDecode(response.body);
      String errorMessage = errorData['message'] ?? 'Erreur inconnue';
      print("Erreur: $errorMessage");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  void _validateAndRegister() {
    print("Validation en cours...");
    if (_formKey.currentState!.validate()) {
      _registerUser(); // Envoi des données au backend
    }
  }
}
