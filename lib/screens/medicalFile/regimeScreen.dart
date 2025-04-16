// REGIME SCREEN
import 'package:flutter/material.dart';

class RegimeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dietPlans;

  const RegimeScreen({super.key, required this.dietPlans});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Régimes alimentaires',
          style: TextStyle(
            color: Color(0xFF2E3C42),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A6572)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body:
          dietPlans.isEmpty
              ? _buildEmptyState()
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: dietPlans.length,
                  itemBuilder: (context, index) {
                    final diet = dietPlans[index];
                    return _buildDietCard(diet, index);
                  },
                ),
              ),
    );
  }

  Widget _buildDietCard(Map<String, dynamic> diet, int index) {
    final dietType = diet['dietType'] ?? 'Sans type';
    final description = diet['description'] ?? 'Pas de description';
    final duration = diet['duration'] ?? 'Non spécifié';
    final restrictions = diet['restrictions'] ?? [];

    // Different pastel colors for different cards
    final List<Color> cardColors = [
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFE0F7FA), // Light Cyan
    ];

    // Different icon types for different diet types
    IconData getIconForDietType(String type) {
      switch (type.toLowerCase()) {
        case 'végétarien':
          return Icons.eco;
        case 'sans gluten':
          return Icons.no_food;
        case 'keto':
          return Icons.fitness_center;
        case 'méditerranéen':
          return Icons.restaurant;
        case 'paleo':
          return Icons.grass;
        default:
          return Icons.restaurant_menu;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with diet type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColors[index % cardColors.length],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getIconForDietType(dietType),
                    color: Color(0xFF4A6572),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dietType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF2E3C42),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
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
          ),
          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF4A6572),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                // Restrictions if available
                if (restrictions is List && restrictions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Restrictions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4A6572),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (restrictions as List).map<Widget>((restriction) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.not_interested,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restriction,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucun régime disponible',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les régimes prescrits apparaîtront ici',
            style: TextStyle(fontSize: 16, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
