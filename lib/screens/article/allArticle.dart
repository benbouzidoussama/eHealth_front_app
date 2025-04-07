import 'package:e_health_front/providers/article_provider.dart';
import 'package:e_health_front/screens/article/articleDetail.dart';
import 'package:e_health_front/screens/doctor/doctorProfilScreen.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllArticleScreen extends StatefulWidget {
  const AllArticleScreen({super.key});

  @override
  _AllArticleScreenState createState() => _AllArticleScreenState();
}

class _AllArticleScreenState extends State<AllArticleScreen> {
  int _currentPage = 0;
  final int _articlesPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final articles = articleProvider.articles;
    final int totalPages = (articles.length / _articlesPerPage).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Articles',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child:
            articles.isEmpty
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E7D32),
                    ),
                  ),
                )
                : Column(
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                            (_currentPage + 1) * _articlesPerPage <=
                                    articles.length
                                ? _articlesPerPage
                                : articles.length % _articlesPerPage,
                        itemBuilder: (context, index) {
                          final articleIndex =
                              _currentPage * _articlesPerPage + index;
                          final article = articles[articleIndex];
                          return ArticleCard(
                            article: article,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ArticleDetailScreen(
                                        articleId: article['_id'],
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 28,
                              color: Colors.grey,
                            ),
                            onPressed:
                                _currentPage > 0
                                    ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                    : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              "${_currentPage + 1} / $totalPages",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              size: 28,
                              color: Colors.grey,
                            ),
                            onPressed:
                                _currentPage < totalPages - 1
                                    ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    }
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  initializeDateFormatting('fr_FR', null);
  return DateFormat('d MMMM y', 'fr_FR').format(parsedDate);
}

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final VoidCallback onTap;

  const ArticleCard({Key? key, required this.article, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.06,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: const AssetImage('images/profil.jpeg'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            try {
                              final apiService = ApiService();
                              final doctorData = await apiService
                                  .fetchDoctorById(article['idDoctor']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DoctorProfilScreen(
                                        doctor: doctorData,
                                      ),
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
                            article['doctorName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          article['categorie'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatDate(article['createdAt']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                article['titre'],
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                article['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
