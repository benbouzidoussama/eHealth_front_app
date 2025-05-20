import 'package:e_health_front/screens/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/screens/appointment/bookAppointment.dart';
import 'package:e_health_front/screens/doctor/doctorProfilScreen.dart';
import 'package:e_health_front/services/api_service.dart';

class DoctorsBySpecialityScreen extends StatefulWidget {
  final String specialityName;

  const DoctorsBySpecialityScreen({Key? key, required this.specialityName})
    : super(key: key);

  @override
  State<DoctorsBySpecialityScreen> createState() =>
      _DoctorsBySpecialityScreenState();
}

class _DoctorsBySpecialityScreenState extends State<DoctorsBySpecialityScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_filterDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final ApiService apiService = ApiService();
      final List<Map<String, dynamic>> result = await apiService
          .getDoctorsBySpeciality(specialityName: widget.specialityName);

      setState(() {
        doctors = result;
        filteredDoctors = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'Erreur lors du chargement des médecins: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _filterDoctors() {
    if (_searchController.text.isEmpty) {
      setState(() {
        filteredDoctors = doctors;
      });
    } else {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredDoctors =
            doctors.where((doctor) {
              final String fullName =
                  '${doctor['firstName']} ${doctor['lastName']}'.toLowerCase();
              return fullName.contains(query) ||
                  (doctor['address'] != null &&
                      doctor['address'].toString().toLowerCase().contains(
                        query,
                      ));
            }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Médecins ${widget.specialityName}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des ${widget.specialityName}s',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un médecin...',
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
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : filteredDoctors.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Aucun ${widget.specialityName} trouvé',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : DoctorGrid(doctors: filteredDoctors),
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
                builder:
                    (context) => DoctorProfilScreen(doctor: doctors[index]),
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
              backgroundImage:
                  doctor['image'] != null
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
                backgroundColor: Color(MyColors.color2) /*Colors.blueAccent*/,
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
