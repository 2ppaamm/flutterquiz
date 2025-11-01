// lib/widgets/common_header.dart
import 'package:flutter/material.dart';
import '../screens/bottom_nav_screen.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavScreen()),
                (route) => false, // Removes all previous routes
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/logo.png',
                height: 35,
              ),
            ),
          ),
          // Hamburger menu removed - empty space to maintain layout
          const SizedBox(width: 48), // Matches IconButton width for symmetry
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}