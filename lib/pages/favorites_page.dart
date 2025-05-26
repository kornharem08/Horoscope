import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Search 🔎',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find what you\'re looking for',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type to search...',
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: const Color(0xFFFF6B35),
                    ),
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildSearchItem(
                      title: 'Flutter Development',
                      subtitle: 'Mobile app development',
                      time: '2 hours ago',
                      icon: Icons.code_rounded,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchItem(
                      title: 'UI Design Trends',
                      subtitle: 'Modern design patterns',
                      time: '1 day ago',
                      icon: Icons.design_services_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchItem(
                      title: 'Travel Photography',
                      subtitle: 'Beautiful destinations',
                      time: '3 days ago',
                      icon: Icons.camera_alt_rounded,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchItem(
                      title: 'Healthy Recipes',
                      subtitle: 'Nutritious meal ideas',
                      time: '1 week ago',
                      icon: Icons.restaurant_menu_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchItem(
                      title: 'Productivity Tips',
                      subtitle: 'Work efficiency guides',
                      time: '2 weeks ago',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF8B5CF6),
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

  Widget _buildSearchItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.history_rounded,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    );
  }
} 