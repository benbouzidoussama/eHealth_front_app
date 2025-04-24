import 'package:e_health_front/screens/speciality/DoctorsBySpecialityScreen.dart';
import 'package:flutter/material.dart';
import '../screens/styles/colors.dart'; // Importez les couleurs si nécessaire

class SpecialitiesList extends StatelessWidget {
  const SpecialitiesList({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: specialities.length,
        itemBuilder: (context, index) {
          return SpecialityCard(speciality: specialities[index], onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    DoctorsBySpecialityScreen(specialityName: specialities[index].name),
          ),
        );
      },);
        },
      ),
    );
  }
}

class SpecialityCard extends StatelessWidget {
  final Speciality speciality;
  final void Function() onTap;

  const SpecialityCard({
    Key? key,
    required this.speciality,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 110,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Color(MyColors.bleuPrincipal),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(blurRadius: 4, spreadRadius: 2, color: Colors.black12),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getSpecialityIcon(speciality.name),
            const SizedBox(height: 10),
            Text(
              speciality.name,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class Speciality {
  final String name;
  final IconData img;

  Speciality({required this.name, required this.img});
}

List<Speciality> specialities = [
  Speciality(name: 'Cardiologue', img: Icons.favorite),
  Speciality(name: 'Dentiste', img: Icons.local_hospital),
  Speciality(name: 'Dermatologue', img: Icons.face),
  Speciality(name: 'Generaliste', img: Icons.medical_services),
  Speciality(name: 'Gynecologue', img: Icons.medical_information),
  Speciality(name: 'Neurologue', img: Icons.medical_services),
  Speciality(name: 'Ophtalmologiste', img: Icons.medical_services),
  Speciality(name: 'Orthopedique', img: Icons.medical_services),
  Speciality(name: 'Pediatre', img: Icons.medical_services),
  Speciality(name: 'Psychiatre', img: Icons.medical_services),
  Speciality(name: 'Radiologue', img: Icons.medical_services),
  Speciality(name: 'Urologue', img: Icons.medical_services),
  Speciality(name: 'Sexologue', img: Icons.medical_services),
  Speciality(name: 'Orl', img: Icons.medical_services),
  Speciality(name: 'Gastro', img: Icons.medical_services),
  Speciality(name: 'Rhumatologue', img: Icons.medical_services),
  Speciality(name: 'Nephrologie', img: Icons.medical_services),
  Speciality(name: 'Pneumologue', img: Icons.medical_services),
  Speciality(name: 'Nutritionniste', img: Icons.medical_services),
];

Map<String, String> specialityIcons = {
  'Cardiologue': 'images/icons/Cardiologue.png',
  'Dentiste': 'images/icons/Dentiste.png',
  'Dermatologue': 'images/icons/Dermatologue.png',
  'Generalisteiste': 'images/icons/Generaliste.png',
  'Gynecologue': 'images/icons/Gynecologue.png',
  'Neurologue': 'images/icons/Neurologue.png',
  'Ophtalmologiste': 'images/icons/Ophtalmologiste.png',
  'Orthopedique': 'images/icons/Orthopedique.png',
  'Pediatre': 'images/icons/Pediatre.png',
  'Psychiatre': 'images/icons/Psychiatre.png',
  'Radiologue': 'images/icons/Radiologue.png',
  'Urologue': 'images/icons/Urologue.png',
  'Sexologue': 'images/icons/Sexologue.png',
  'Orl': 'images/icons/Orl.png',
  'Gastro': 'images/icons/Gastro.png',
  'Rhumatologue': 'images/icons/Rhumatologue.png',
  'Nephrologie': 'images/icons/Nephrologie.png',
  'Pneumologue': 'images/icons/Pneumologue.png',
  'Nutritionniste': 'images/icons/Nutritionniste.png',
};

Widget getSpecialityIcon(String speciality) {
  return Image.asset(
    specialityIcons[speciality] ?? 'images/icons/Generaliste.png',
    width: 50,
    height: 50,
    color: Colors.white,
  );
}
