import 'package:flutter/material.dart';
import 'package:e_health_front/screens/appointment/bookAppointment.dart';
import 'package:e_health_front/screens/doctor/doctorProfilScreen.dart';
import 'package:e_health_front/services/api_service.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedValue = 'tous';
  List<Map<String, dynamic>> allDoctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      filterDoctors(_searchController.text);
    });
    _doctorsFuture = _loadDoctors(selectedValue);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Charger les docteurs en fonction du type de filtre sélectionné
  Future<List<Map<String, dynamic>>> _loadDoctors(String filterType) async {
    try {
      List<Map<String, dynamic>> doctors;
      if (filterType == 'tous') {
        doctors = await _apiService.fetchAllDoctors();
      } else if (filterType == 'mes') {
        doctors = await _apiService.fetchMyDoctors();
      } else {
        doctors = [];
      }

      setState(() {
        allDoctors = doctors;
        filterDoctors(_searchController.text);
      });
      
      return doctors;
    } catch (e) {
      // Propager l'erreur pour que FutureBuilder puisse la gérer
      throw e;
    }
  }

  // Filtrer les docteurs en fonction du texte de recherche
  void filterDoctors(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredDoctors = List.from(allDoctors);
      } else {
        filteredDoctors = allDoctors.where((doctor) {
          final firstName = doctor['firstName']?.toString().toLowerCase() ?? '';
          final lastName = doctor['lastName']?.toString().toLowerCase() ?? '';
          final speciality = doctor['speciality']?.toString().toLowerCase() ?? '';
          final fullName = '$firstName $lastName'.toLowerCase();
          final query = searchText.toLowerCase();

          return firstName.contains(query) ||
              lastName.contains(query) ||
              fullName.contains(query) ||
              speciality.contains(query);
        }).toList();
      }
    });
  }

  void _refreshDoctors() {
    setState(() {
      _doctorsFuture = _loadDoctors(selectedValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Docteurs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Liste des Docteurs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedValue,
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                      value: 'tous',
                      child: Text('Tous les docteurs'),
                    ),
                    DropdownMenuItem(value: 'mes', child: Text('Mes docteurs')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != selectedValue) {
                      setState(() {
                        selectedValue = newValue;
                        _doctorsFuture = _loadDoctors(newValue);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un docteur...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Erreur: ${snapshot.error}'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _refreshDoctors,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || filteredDoctors.isEmpty) {
                    return const Center(child: Text('Aucun docteur trouvé'));
                  } else {
                    return DoctorGrid(doctors: filteredDoctors);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorGrid extends StatelessWidget {
  final List<Map<String, dynamic>> doctors;

  const DoctorGrid({Key? key, required this.doctors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.8,
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return DoctorCard(
          index: index,
          doctor: doctors[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorProfilScreen(doctor: doctors[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class DoctorCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> doctor;
  final void Function() onTap;

  const DoctorCard({
    Key? key,
    required this.index,
    required this.doctor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: doctor['image'] != null
                  ? NetworkImage(doctor['image'])
                  : const AssetImage('images/avatar.jpg') as ImageProvider,
              radius: 35,
            ),
            const SizedBox(height: 10),
            Text(
              '${doctor['firstName']} ${doctor['lastName']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              doctor['speciality'] ?? 'N/A',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              doctor['address'] ?? 'N/A',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookAppointmentScreen(doctor: doctor),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Rendez-vous',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}