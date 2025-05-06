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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final articles = articleProvider.articles;

    // Filtrage des articles par recherche
    final filteredArticles =
        _isSearching
            ? articles.where((article) {
              return article['titre'].toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ||
                  article['description'].toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  );
            }).toList()
            : articles;

    final int totalPages = (filteredArticles.length / _articlesPerPage).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey, Colors.white],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un article...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                )
                : const Text(
                  'Articles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child:
            filteredArticles.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.article_outlined,
                        size: 60,
                        color: Color(0xff575de3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        articles.isEmpty
                            ? "Chargement des articles..."
                            : "Aucun article trouvé",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
                                    filteredArticles.length
                                ? _articlesPerPage
                                : filteredArticles.length % _articlesPerPage ==
                                    0
                                ? _articlesPerPage
                                : filteredArticles.length % _articlesPerPage,
                        itemBuilder: (context, index) {
                          final articleIndex =
                              _currentPage * _articlesPerPage + index;
                          if (articleIndex >= filteredArticles.length) {
                            return null;
                          }
                          final article = filteredArticles[articleIndex];
                          return AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(
                              milliseconds: 500 + (index * 100),
                            ),
                            child: ArticleCard(
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
                            ),
                          );
                        },
                      ),
                    ),

                    // Pagination améliorée
                    if (totalPages > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPaginationButton(
                              icon: Icons.first_page,
                              onPressed:
                                  _currentPage > 0
                                      ? () => setState(() => _currentPage = 0)
                                      : null,
                            ),
                            _buildPaginationButton(
                              icon: Icons.chevron_left,
                              onPressed:
                                  _currentPage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                            ),
                            for (int i = 0; i < totalPages; i++)
                              if (i == _currentPage ||
                                  i == 0 ||
                                  i == totalPages - 1 ||
                                  (i >= _currentPage - 1 &&
                                      i <= _currentPage + 1))
                                _buildPageNumber(i),
                            _buildPaginationButton(
                              icon: Icons.chevron_right,
                              onPressed:
                                  _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                            ),
                            _buildPaginationButton(
                              icon: Icons.last_page,
                              onPressed:
                                  _currentPage < totalPages - 1
                                      ? () => setState(
                                        () => _currentPage = totalPages - 1,
                                      )
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

  Widget _buildPaginationButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 20,
          color: onPressed != null ? Color(0xff575de3) : Colors.grey,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPageNumber(int pageIndex) {
    final isCurrentPage = pageIndex == _currentPage;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = pageIndex;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCurrentPage ? Color(0xff575de3) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "${pageIndex + 1}",
            style: TextStyle(
              color: isCurrentPage ? Colors.white : Colors.black87,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    article['image'] != null
                        ? Container(
                          height:
                              180, // Augmentation de la hauteur pour mieux voir l'image
                          width: double.infinity,
                          color: Color(0xff575de3).withOpacity(0.1),
                          child: Image(
                            image: NetworkImage(article['image']),
                            fit:
                                BoxFit.contain, // Changement de cover à contain
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              // Gestion des erreurs de chargement d'image
                              return Container(
                                height: 180,
                                color: Color(0xff575de3).withOpacity(0.2),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : const SizedBox.shrink(),
              ),

              // Contenu de l'article
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          article['titre'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff575de3).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article['categorie'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            try {
                              final apiService = ApiService();
                              final doctorData = await apiService
                                  .fetchDoctorById(article['idDoctor']['_id']);
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
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenWidth * 0.04,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    article['idDoctor']['image'] != null
                                        ? NetworkImage(
                                          article['idDoctor']['image'],
                                        )
                                        : AssetImage('images/avatar.jpg'),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                article['doctorName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xff575de3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            formatDate(article['createdAt']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // IconData _getCategoryIcon(String category) {
  //   switch (category.toLowerCase()) {
  //     case 'santé':
  //       return Icons.medical_services;
  //     case 'nutrition':
  //       return Icons.restaurant_menu;
  //     case 'fitness':
  //       return Icons.fitness_center;
  //     case 'bien-être':
  //       return Icons.spa;
  //     default:
  //       return Icons.article;
  //   }
  // }
}
