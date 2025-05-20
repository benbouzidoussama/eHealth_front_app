// ignore_for_file: use_key_in_widget_constructors
import 'package:e_health_front/screens/article/allArticle.dart';
import 'package:e_health_front/screens/article/articleDetail.dart';
import 'package:e_health_front/screens/doctor/doctorProfilScreen.dart';
import 'package:e_health_front/screens/notification/notifications_screen.dart';
import 'package:e_health_front/screens/speciality/allSpecialityScreen.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'styles/colors.dart';
import 'package:provider/provider.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/providers/article_provider.dart';
import '../widgets/speciality.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  Future<Map<String, dynamic>?> _getNextAppointment() async {
    final apiService = ApiService();
    List<Map<String, dynamic>> nextAppointments =
        await apiService.fetchNextAppointment();
    return nextAppointments.isNotEmpty ? nextAppointments.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final articleProvider = Provider.of<ArticleProvider>(context);
    final String userName =
        '${userProvider.user?['firstName'] ?? ''} ${userProvider.user?['lastName'] ?? ''}';
    final Map<String, dynamic>? userData = userProvider.user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 221, 221),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Supprime l'icône de retour
        backgroundColor: const Color.fromARGB(255, 224, 221, 221),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  userData?['image'] != null
                      ? NetworkImage(userData?['image'])
                      : AssetImage('images/avatar.jpg'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData?['address'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 224, 221, 221),
        child: ListView(
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: _getNextAppointment(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink(); //Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return SizedBox.shrink();
                } else {
                  var appointment = snapshot.data!;
                  var doctor = appointment['doctor'] ?? {};

                  // Convertir la date au format souhaité
                  String dateDay = formatDateToDayMonth(
                    appointment['date'].split("T")[0],
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 16,
                        ),
                        child: Text(
                          "Rendez-vous prochain",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 16,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: AppointmentCard(
                              onTap: () {},
                              image:
                                  doctor['image'] != null
                                      ? NetworkImage(doctor['image'])
                                      : AssetImage('images/avatar.jpg'),
                              name: doctor['doctorName'] ?? 'Inconnu',
                              speciality:
                                  doctor['speciality'] ?? 'Non spécifié',
                              dateDay: dateDay, // Date formatée
                              dateTime: appointment['time'] ?? 'Heure inconnue',
                              type: appointment['type'] ?? 'Type inconnu',
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 10),

            // **********Spécialités********** //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    'Spécialités',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(
                        color: Color(MyColors.color2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllSpecialitiesScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // **********Spécialités Widjet (Icons & Name)********** //
            SpecialitiesList(),
            // **********Article********** //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    'Article',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    child: Text(
                      'Voir Tout',
                      style: TextStyle(
                        color: Color(MyColors.color2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllArticleScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Add the ArticlesList widget here
            ArticlesList(articles: articleProvider.articles, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final void Function() onTap;
  final String name;
  final String speciality;
  final String dateDay;
  final String dateTime;
  final String type;
  final ImageProvider image;
  const AppointmentCard({
    Key? key,
    required this.image,
    required this.onTap,
    required this.speciality,
    required this.dateDay,
    required this.dateTime,
    required this.name,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(MyColors.color2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: image,
                          // doctor['image'] != null
                          //     ? NetworkImage(doctor['image'])
                          //     : AssetImage('images/avatar.jpg'),
                        ),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dr. $name",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 2),
                            Text(
                              speciality,
                              style: TextStyle(color: Color(0xffbec2fc)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ScheduleCard(
                        dateDay: dateDay,
                        dateTime: dateTime,
                        type: type,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: Color(MyColors.color2).withOpacity(0.5),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: Color(0xffe8eafe),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String dateDay;
  final String dateTime;
  final String type;
  const ScheduleCard({
    Key? key,
    required this.dateDay,
    required this.dateTime,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF0098e9),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, color: Colors.white, size: 15),
          SizedBox(width: 5),
          Text(dateDay, style: TextStyle(color: Colors.white)),
          SizedBox(width: 20),
          Icon(Icons.access_alarm, color: Colors.white, size: 17),
          SizedBox(width: 5),
          Flexible(
            child: Text(dateTime, style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 20),
          Icon(Icons.check_circle, color: Colors.white, size: 17),
          SizedBox(width: 5),
          Flexible(child: Text(type, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class Article {
  final String title;
  final String description;
  final String nameDoctor;
  final String specialite;
  final String date;
  final String urlImg;

  Article({
    required this.title,
    required this.description,
    required this.nameDoctor,
    required this.specialite,
    required this.date,
    required this.urlImg,
  });
}

String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  initializeDateFormatting('fr_FR', null); // Initialisation des données locales
  String formattedDate = DateFormat('d MMMM y', 'fr_FR').format(parsedDate);
  return formattedDate;
}

String formatDateToDayMonth(String date) {
  initializeDateFormatting('fr_FR', null); // Initialisation des données locales
  DateTime parsedDate = DateTime.parse(date);
  return DateFormat('EEEE d MMMM', 'fr_FR').format(parsedDate);
}

class ArticlesList extends StatelessWidget {
  final List<Map<String, dynamic>> articles;
  final void Function() onTap;
  const ArticlesList({Key? key, required this.articles, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Material(
          color: Colors.transparent,
          child: Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ArticleDetailScreen(
                          articleId: articles[index]['_id'],
                        ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            articles[index]['idDoctor']['image'] != null
                                ? NetworkImage(
                                  articles[index]['idDoctor']['image'],
                                )
                                : AssetImage('images/avatar.jpg'),
                      ),
                      title: GestureDetector(
                        onTap: () async {
                          try {
                            final apiService = ApiService();
                            final doctorData = await apiService.fetchDoctorById(
                              articles[index]['idDoctor']['_id'],
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DoctorProfilScreen(doctor: doctorData),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur : Impossible de charger les données du docteur',
                                ),
                              ),
                            );
                          }
                        },

                        child: Text(
                          articles[index]['doctorName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text(articles[index]['categorie']),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            articles[index]['titre'].length > 25
                                ? '${articles[index]['titre'].substring(0, 25)}...'
                                : articles[index]['titre'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            formatDate(articles[index]['createdAt']),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        articles[index]['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
