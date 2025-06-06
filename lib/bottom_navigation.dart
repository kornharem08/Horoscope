import 'package:flutter/material.dart';
import 'dart:ui';

class BottomNavigationWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'หน้าแรก',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                  label: 'ดูดวง',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'แผนที่',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.forum_outlined,
                  activeIcon: Icons.forum,
                  label: 'ชุมชน',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.account_circle_outlined,
                  activeIcon: Icons.account_circle,
                  label: 'โปรไฟล์',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = widget.currentIndex == index;
    
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[600],
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
} 