import 'package:e_health_front/screens/styles/colors.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateProfilScreen extends StatefulWidget {
  const UpdateProfilScreen({super.key});

  @override
  State<UpdateProfilScreen> createState() => _UpdateProfilScreenState();
}

class _UpdateProfilScreenState extends State<UpdateProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Contrôleurs pour les champs
  TextEditingController? firstNameController;
  TextEditingController? lastNameController;
  TextEditingController? emailController;
  TextEditingController? phoneController;
  TextEditingController? addressController;

  @override
  void initState() {
    super.initState();

    // Charger les données utilisateur depuis UserProvider
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    if (userData != null) {
      firstNameController = TextEditingController(text: userData["firstName"]);
      lastNameController = TextEditingController(text: userData["lastName"]);
      emailController = TextEditingController(text: userData["email"]);
      phoneController = TextEditingController(text: userData["phone"]);
      addressController = TextEditingController(text: userData["address"]);
    }
  }

  @override
  void dispose() {
    firstNameController?.dispose();
    lastNameController?.dispose();
    emailController?.dispose();
    phoneController?.dispose();
    addressController?.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Préparer les données à envoyer
      final updatedData = {
        "firstName": firstNameController?.text,
        "lastName": lastNameController?.text,
        "phone": phoneController?.text,
        "address": addressController?.text,
      };

      try {
        // Appeler l'API pour mettre à jour le profil
        final response = await _apiService.updateProfile(updatedData);
        if (response['user'] != null) {
          // Mettre à jour les données utilisateur dans UserProvider
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUser(response['user']);
          _showSuccessDialog("Profil mis à jour avec succès !");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Erreur inconnue')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      try {
        // Appeler l'API pour mettre à jour l'image de profil
        final response = await _apiService.updateProfileImage(imageFile);
        if (response['success'] == true) {
          // Mettre à jour l'image dans UserProvider
          final updatedUser = response['data']['user'];
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUser(updatedUser);

          // Rafraîchir l'image
          setState(() {});

          _showSuccessDialog("Image de profil mise à jour avec succès !");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Erreur inconnue')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image sélectionnée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'Modifier le Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar avec option de modification
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).user?["image"] ??
                        "https://res.cloudinary.com/dvrhrdvps/image/upload/v1741181587/profile_pictures/ytl0zhqqkbnj2mllstyv.jpg",
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(MyColors.color2) /*Colors.blue*/,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _updateProfileImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(firstNameController!, "Prénom", Icons.person),
                  _buildTextField(
                    lastNameController!,
                    "Nom",
                    Icons.person_outline,
                  ),
                  _buildTextField(
                    emailController!,
                    "Email",
                    Icons.email,
                    isReadOnly: true,
                  ),
                  _buildTextField(phoneController!, "Téléphone", Icons.phone),
                  _buildTextField(
                    addressController!,
                    "Adresse",
                    Icons.location_on,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(MyColors.color2) /*Colors.blue*/,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(MyColors.color1) /*Colors.blue*/),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? "Veuillez entrer $label"
                    : null,
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Empêche de fermer le dialogue en cliquant à l'extérieur
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône animée
              Icon(Icons.check_circle, color: Colors.green, size: 80),
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
                  backgroundColor: Color(MyColors.color1) /*Color(0xFF4880D8)*/,
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
