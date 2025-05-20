import 'package:e_health_front/screens/doctor/doctorProfilScreen.dart';
import 'package:e_health_front/screens/medicalFile/imageViewerScreen.dart';
import 'package:e_health_front/screens/styles/colors.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/providers/article_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final article = articleProvider.getArticleById(articleId);
  //final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar avec image en fond
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de couverture avec dégradé
                  if (article['image'] != null)
                    Image.network(article['image'], fit: BoxFit.cover),
                  // Dégradé pour améliorer la lisibilité
                  GestureDetector(
                    onTap: () {
                      if (article['image'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ImageViewerScreen(
                                  url: article['image'],
                                  title: "Image",
                                ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Contenu de l'article
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Catégorie
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(MyColors.color2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article['categorie'] ?? 'Santé',
                          style: TextStyle(
                            color: Color(MyColors.color2),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Titre
                      Text(
                        article['titre'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info auteur et date
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(MyColors.color2).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage:
                                  article['idDoctor']['image'] != null
                                      ? NetworkImage(
                                        article['idDoctor']['image'],
                                      )
                                      : const AssetImage('images/avatar.jpg')
                                          as ImageProvider,
                              radius: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      final apiService = ApiService();
                                      final doctorData = await apiService
                                          .fetchDoctorById(
                                            article['idDoctor']['_id'],
                                          );
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat.yMMMMd('fr_FR').format(
                                        DateTime.parse(article['createdAt']),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Contenu de l'article
                      Text(
                        article['description'],
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.7,
                          color: Color(0xFF303030),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Bouton flottant pour commentaires supprimé
    );
  }
}
