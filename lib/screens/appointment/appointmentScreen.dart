import 'package:e_health_front/screens/appointment/canceledScreen.dart';
import 'package:e_health_front/screens/appointment/upcomingScreen.dart';
import 'package:e_health_front/screens/appointment/confirmedScreen.dart';

import 'package:flutter/material.dart';

//
class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _buttonIndex = 0;
  final List<String> _tabs = ["Upcoming", "Confirmed", "Canceled"];
  final List<Widget> _scheduleWidgets = [
    UpcomingScreen(), // Upcoming appointments
    ConfirmedScreen(), // Condirmed appointments
    CanceledScreen(), // Canceled appointments
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 221, 221),
      appBar: AppBar(
        title: Text(
          "Schedule",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // Supprime l'icône de retour
        backgroundColor: Color.fromARGB(255, 224, 221, 221),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs for selecting appointment type
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_tabs.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _buttonIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              _buttonIndex == index
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                          boxShadow:
                              _buttonIndex == index
                                  ? [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Text(
                          _tabs[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                _buttonIndex == index
                                    ? Colors.white
                                    : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Appointment List Section
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _scheduleWidgets[_buttonIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
