import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        title: Text('Compete', style: AppFontStyles.headingLarge),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Leaderboards',
              style: AppFontStyles.headingLarge.copyWith(
                color: AppColors.darkGreyText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: AppFontStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Compete with students worldwide',
              style: AppFontStyles.buttonSecondarySubtitle.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}