// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:e_health_front/screens/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:e_health_front/services/api_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedAppointmentType = 'Consultation';
  List<String> availableSlots = [];
  bool isLoading = false;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchSlotsForSelectedDay();
  }

  Future<void> _fetchSlotsForSelectedDay() async {
    setState(() => isLoading = true);
    try {
      final formattedDate =
          "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}";
      final slots = await apiService.fetchAvailableSlots(
        widget.doctor['_id'],
        formattedDate,
      );
      setState(() => availableSlots = slots);
    } catch (e) {
      print("Error fetching slots: $e");
      setState(() => availableSlots = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _fetchSlotsForSelectedDay();
  }

  void _confirmAppointment(String hour) async {
    final String formattedDate =
        "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}";

    try {
      setState(() => isLoading = true);

      // Appeler l'API pour enregistrer le rendez-vous
      await apiService.bookAppointment(
        doctorId: widget.doctor['_id'],

        date: formattedDate,
        time: hour,
        type: _selectedAppointmentType,
      );

      // Afficher un message de succès sous forme de showDialog
      _showSuccessDialog();
    } catch (e) {
      // Afficher un message d'erreur
      _showErrorDialog("Erreur lors de la réservation : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
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
                "Rendez-vous réservé avec succès !",
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
                  backgroundColor: Color(MyColors.color2), //Color(0xFF4880D8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialogue
                  Navigator.of(context).pop(); // Fermer l'écran de réservation
                  _fetchSlotsForSelectedDay(); // Recharger les créneaux disponibles
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

  void _showErrorDialog(String errorMessage) {
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
              // Icône d'erreur
              Icon(Icons.error, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              // Message d'erreur
              Text(
                errorMessage,
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
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialogue
                  Navigator.of(context).pop(); // Fermer l'écran de réservation
                  _fetchSlotsForSelectedDay(); // Recharger les créneaux disponibles
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

  void _showConfirmationDialog(String hour) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(MyColors.color2) /*Color(0xFF4880D8)*/,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Confirmation",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Rendez-vous réservé à $hour le ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    value: _selectedAppointmentType,
                    items:
                        ['Consultation', 'controle'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAppointmentType = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(
                        MyColors.color2,
                      ), //Color(0xFF4880D8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => _confirmAppointment(hour),
                    child: Text(
                      "Confirmer",
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
      },
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      rowHeight: 40,
      focusedDay: _focusedDay,
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2026, 12, 31),
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      enabledDayPredicate: (day) => !day.isBefore(DateTime.now()),
      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent.shade100,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color(MyColors.color2), //Color(0xFF4880D8),
          shape: BoxShape.circle,
        ),
      ),
      locale: 'fr_FR',
      // Configuration personnalisée pour les jours et mois en français
      daysOfWeekVisible: true,
      startingDayOfWeek: StartingDayOfWeek.monday,
      // Vous pouvez personnaliser le formatage des titres
      headerVisible: true,
      calendarBuilders: CalendarBuilders(
        // Vous pouvez personnaliser l'affichage du titre du mois
        headerTitleBuilder: (context, day) {
          final frenchMonths = [
            'Janvier',
            'Février',
            'Mars',
            'Avril',
            'Mai',
            'Juin',
            'Juillet',
            'Août',
            'Septembre',
            'Octobre',
            'Novembre',
            'Décembre',
          ];
          return Center(
            child: Text(
              '${frenchMonths[day.month - 1]} ${day.year}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        },
        // Vous pouvez personnaliser l'affichage des jours de la semaine
        dowBuilder: (context, day) {
          final frenchDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
          // Convertir la date en jour de la semaine (1 = lundi, 7 = dimanche)
          final dayIndex = day.weekday - 1;
          return Center(
            child: Text(
              frenchDays[dayIndex],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailableSlots() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          isLoading
              ? const CircularProgressIndicator()
              : availableSlots.isEmpty
              ? const Text(
                "Aucun horaire disponible",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
              : Wrap(
                spacing: 12,
                runSpacing: 10,
                children:
                    availableSlots.map((hour) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: OutlinedButton(
                          onPressed: () => _showConfirmationDialog(hour),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(
                              MyColors.color2,
                            ) /*const Color(0xFF4880D8)*/,
                            side: BorderSide(
                              color: Color(
                                MyColors.color2,
                              ) /* Color(0xFF4880D8)*/,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            elevation: 5, // Ajout d'ombre
                          ),
                          child: Text(
                            hour,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 221, 221),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 224, 221, 221),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
        title: const Text(
          'Réserver un rendez-vous',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCalendar(),
              const SizedBox(height: 20),
              Text(
                "Horaires disponibles pour ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildAvailableSlots(),
            ],
          ),
        ),
      ),
    );
  }
}
