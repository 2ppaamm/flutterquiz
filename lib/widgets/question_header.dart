import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import 'video_player_screen.dart';
import 'package:lottie/lottie.dart';

class QuestionHeader extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final VoidCallback onClose;
  final List<dynamic>? videos;
  final Map<String, dynamic>? skill;

  const QuestionHeader({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onClose,
    this.videos,
    this.skill,
  });

  Future<int> _getLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lives') ?? 3;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getLives(),
      builder: (context, snapshot) {
        final lives = snapshot.data ?? 3;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              IconButton(
                icon: const Icon(Icons.menu_book_outlined, color: Colors.grey),
                tooltip: "Watch Skill Video",
                onPressed: () {
                  final videoLinks = (skill?['links'] as List?)
                      ?.where((link) => link['type'] == 'video')
                      .toList();

                  if (videoLinks != null && videoLinks.isNotEmpty) {
                    final videoLink = videoLinks.first['link'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(
                          title: 'Skill Video',
                          videoUrl: '$videoLink',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No video available for this skill')),
                    );
                  }
                },

              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.tileGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor:
                            totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.darkRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: Lottie.asset(
                      'assets/animations/heart.json',
                      repeat: true,
                      animate: true,
                    ),
                  ),
                  Text('$lives', style: AppFontStyles.heading4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
