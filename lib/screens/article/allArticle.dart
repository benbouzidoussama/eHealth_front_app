import 'package:e_health_front/providers/article_provider.dart';
import 'package:e_health_front/screens/article/articleDetail.dart';
import 'package:e_health_front/screens/doctor/doctorProfilScreen.dart';
import 'package:e_health_front/screens/styles/colors.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  String _selectedCategory = 'tout';

  // Liste des catégories disponibles
  final List<String> _categories = [
    'tout',
    'general',
    'pediatrics',
    'cardiology',
    'neurology',
    'orthopedics',
    'dermatology',
    'Médecine alternative',
    'Recherche biomédicale',
    'Actualités COVID-19',
    'Alimentation et nutrition',
    'Santé numérique',
    'Soins aux handicapés',
    'Exercice et fitness',
    'Génétique',
    'Pratiques infirmières',
    'Néonatologie',
    'autre',
  ];

  // Icônes pour les catégories
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return Icons.medical_services;
      case 'pediatrics':
        return Icons.child_care;
      case 'cardiology':
        return Icons.favorite;
      case 'neurology':
        return Icons.psychology;
      case 'orthopedics':
        return Icons.accessibility_new;
      case 'dermatology':
        return Icons.face;
      case 'médecine alternative':
        return Icons.spa;
      case 'recherche biomédicale':
        return Icons.science;
      case 'actualités covid-19':
        return Icons.coronavirus;
      case 'alimentation et nutrition':
        return Icons.restaurant_menu;
      case 'santé numérique':
        return Icons.devices;
      case 'soins aux handicapés':
        return Icons.accessible;
      case 'exercice et fitness':
        return Icons.fitness_center;
      case 'génétique':
        return FontAwesomeIcons.dna;
      case 'pratiques infirmières':
        return Icons.local_hospital;
      case 'néonatologie':
        return Icons.baby_changing_station;
      case 'tout':
        return Icons.all_inclusive;
      default:
        return Icons.article;
    }
  }

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

    // Filtrage des articles par recherche et catégorie
    final filteredArticles =
        articles.where((article) {
          // Filtrage par recherche
          bool matchesSearch =
              !_isSearching ||
              article['titre'].toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ) ||
              article['description'].toLowerCase().contains(
                _searchController.text.toLowerCase(),
              );

          // Filtrage par catégorie
          bool matchesCategory =
              _selectedCategory == 'tout' ||
              article['categorie'] == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

    final int totalPages = (filteredArticles.length / _articlesPerPage).ceil();

    // Réinitialiser la pagination quand les filtres changent
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 221, 221),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(MyColors.color2), Color(MyColors.color2)],
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
                    setState(() {
                      _currentPage =
                          0; // Réinitialiser la pagination lors d'une recherche
                    });
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
                  _currentPage = 0; // Réinitialiser la pagination
                }
              });
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Interface de filtrage (dropdown pour catégories et compteur)
            Row(
              children: [
                // Dropdown pour le filtre par catégorie
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(MyColors.color2),
                        ),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              _currentPage =
                                  0; // Réinitialiser la pagination lors d'un changement de catégorie
                            });
                          }
                        },
                        items:
                            _categories.map<DropdownMenuItem<String>>((
                              String category,
                            ) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(category),
                                      size: 20,
                                      color: Color(MyColors.color2),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontWeight:
                                            _selectedCategory == category
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Affichage du nombre d'articles trouvés

            // Liste des articles
            Expanded(
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
                      : ListView.builder(
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

            if (totalPages > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPaginationButton(
                      icon: Icons.chevron_left,
                      onPressed:
                          _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                    ),

                    // Pagination avec max 3 numéros visibles
                    for (int i = 0; i < totalPages; i++)
                      if (totalPages <= 3 ||
                          (i >= _currentPage - 1 && i <= _currentPage + 1))
                        _buildPageNumber(i),

                    _buildPaginationButton(
                      icon: Icons.chevron_right,
                      onPressed:
                          _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
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
          color: onPressed != null ? Color(MyColors.color2) : Colors.grey,
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
          color: isCurrentPage ? Color(MyColors.color2) : Colors.white,
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
                          height: 180,
                          width: double.infinity,
                          color: Color(MyColors.color2).withOpacity(0.1),
                          child: Image(
                            image: NetworkImage(article['image']),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
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
                padding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.03,
                  horizontal: screenWidth * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          article['titre'].length > 15
                              ? '${article['titre'].substring(0, 15)}...'
                              : article['titre'],

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
                            color: Color(MyColors.color2).withOpacity(0.6),
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
                                        : null,
                                child:
                                    article['idDoctor']['image'] == null
                                        ? Icon(
                                          Icons.person,
                                          size: screenWidth * 0.05,
                                          color: Colors.grey[400],
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                article['doctorName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(MyColors.color2),
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
}
