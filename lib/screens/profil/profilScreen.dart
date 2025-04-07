import 'package:e_health_front/screens/profil/updateProfilScreen.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        automaticallyImplyLeading: false, // Supprime l'icône de retour
        elevation: 0,
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Avatar et informations utilisateur
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 79),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blueAccent,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      userData?["image"] ??
                          "https://res.cloudinary.com/dvrhrdvps/image/upload/v1741181587/profile_pictures/ytl0zhqqkbnj2mllstyv.jpg",
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                    userData?["firstName"] + " " + userData?["lastName"] ??
                      "Nom Prénom",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'oussamabenbouzid159@gmail.com',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),

          // Liste des paramètres
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSettingsItem(
                    Icons.account_circle,
                    'Modifier le profil',
                    context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProfilScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    Icons.lock,
                    'Changer le mot de passe',
                    context,
                  ),
                  _buildSettingsItem(
                    Icons.notifications,
                    'Notifications',
                    context,
                  ),
                  _buildSettingsItem(Icons.language, 'Langue', context),
                  _buildSettingsItem(Icons.info, 'À propos', context),
                  _buildSettingsItem(
                    Icons.logout,
                    'Déconnexion',
                    context,
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    BuildContext context, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? Colors.red : Colors.blue, size: 26),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLogout ? Colors.red : Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
