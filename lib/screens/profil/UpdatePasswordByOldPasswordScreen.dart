import 'package:e_health_front/screens/styles/colors.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';

class UpdatePasswordByOldPasswordScreen extends StatefulWidget {
  const UpdatePasswordByOldPasswordScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordByOldPasswordScreen> createState() =>
      _UpdatePasswordByOldPasswordScreenState();
}

class _UpdatePasswordByOldPasswordScreenState
    extends State<UpdatePasswordByOldPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscureOldPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final ApiService _apiService =
      ApiService(); // Create instance of your API service

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _apiService.updatePasswordByOldPassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _successMessage = result['message'];
          // Clear form on success
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 221, 221),
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
        title: const Text('Changer mot de passe'),
        backgroundColor: Color.fromARGB(255, 224, 221, 221),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Modification du mot de passe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Veuillez entrer votre ancien mot de passe et votre nouveau mot de passe.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Old Password Field
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _isObscureOldPassword,
                  decoration: InputDecoration(
                    labelText: 'Ancien mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureOldPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureOldPassword = !_isObscureOldPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre ancien mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // New Password Field
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _isObscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureNewPassword = !_isObscureNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nouveau mot de passe';
                    }
                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isObscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureConfirmPassword =
                              !_isObscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre nouveau mot de passe';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Display Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red.shade100,
                    width: double.infinity,
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),

                // Display Success Message
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green.shade100,
                    width: double.infinity,
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                _updatePassword();
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(MyColors.color2),
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Mettre à jour',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
