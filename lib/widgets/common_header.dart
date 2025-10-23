// lib/widgets/common_header.dart
import 'package:flutter/material.dart';

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
          Padding(
            padding: const EdgeInsets.all(12.0), // ✅ Added margins around logo
            child: Image.asset(
              'assets/logo.png',
              height: 35,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF960000)),
            onPressed: () {
              // TODO: Menu logic
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}