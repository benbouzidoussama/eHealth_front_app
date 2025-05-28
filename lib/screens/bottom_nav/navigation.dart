import 'package:e_health_front/screens/appointment/appointmentScreen.dart';
//import 'package:e_health_front/screens/chatScreen.dart';
import 'package:e_health_front/screens/chat/chatListScreen.dart';
import 'package:e_health_front/screens/home.dart';
import 'package:e_health_front/screens/doctor/doctorScreen.dart';
import 'package:e_health_front/screens/profil/profilScreen.dart';
import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentIndexTab = 0;

  final List<Widget> pages = [
    HomeScreen(),
    DoctorScreen(),
    ChatListScreen(),
    AppointmentScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[currentIndexTab],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.white,
            color: Colors.grey[600],
            activeColor: Colors.blueAccent,
            tabBackgroundColor: Colors.blueAccent.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home, text: 'Accueil'),
              GButton(icon: Icons.health_and_safety_sharp, text: 'Médecin'),
              GButton(icon: Icons.message, text: 'Msg'),
              GButton(icon: Icons.calendar_month, text: 'RDV'),
              GButton(icon: Icons.person, text: 'Profil'),
            ],
            selectedIndex: currentIndexTab,
            onTabChange: (index) {
              setState(() {
                currentIndexTab = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
