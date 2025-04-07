import 'package:flutter/material.dart';
import 'package:e_health_front/services/api_service.dart';

class DoctorProvider with ChangeNotifier {
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  final ApiService _apiService = ApiService();
  String _selectedValue = 'filter';

  List<Map<String, dynamic>> get doctors => _doctors;
  List<Map<String, dynamic>> get filteredDoctors => _filteredDoctors;
  String get selectedValue => _selectedValue;

  set selectedValue(String value) {
    _selectedValue = value;
    notifyListeners();
  }

  Future<void> fetchDoctors(String filter) async {
    try {
      List<Map<String, dynamic>> fetchedDoctors;
      if (filter == 'tous') {
        fetchedDoctors = await _apiService.fetchAllDoctors();
      } else if (filter == 'mes') {
        // Replace 'userId' with the actual user ID
        fetchedDoctors = await _apiService.fetchMyDoctors();
      } else {
        fetchedDoctors = [];
      }

      _doctors = fetchedDoctors;
      _filteredDoctors = fetchedDoctors;
      notifyListeners();

      // Print the list of doctors to the Debug Console
      print('Fetched Doctors: $_doctors');
    } catch (e) {
      print('Failed to load doctors: $e');
    }
  }

  void filterDoctors(String query) {
    query = query.toLowerCase();
    _filteredDoctors =
        _doctors.where((doctor) {
          final firstName = doctor['firstName']!.toLowerCase();
          final lastName = doctor['lastName']!.toLowerCase();
          final speciality = doctor['speciality']!.toLowerCase();
          return firstName.contains(query) ||
              lastName.contains(query) ||
              speciality.contains(query);
        }).toList();
    notifyListeners();
  }

  Map<String, dynamic>? findDoctorById(String id) {
    try {
      // Rechercher le docteur par ID dans la liste des docteurs
      return _doctors.firstWhere((doctor) => doctor['_id'] == id);
    } catch (e) {
      print('Erreur lors de la recherche du docteur par ID : $e');
      return null;
    }
  }
}
