import 'package:flutter/material.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_colors.dart';
import 'bottom_nav_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int kudos;
  final double maxile;
  final double percentage;
  final String name;
  final String token;
  final bool isSubscriber;
  final int durationInSeconds;
  final String encouragement;

  const ResultsScreen({
    super.key,
    required this.kudos,
    required this.maxile,
    required this.percentage,
    required this.name,
    required this.token,
    required this.isSubscriber,
    required this.durationInSeconds,
    required this.encouragement,
  });

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  static final List<String> praiseWords = [
    'Nice Work',
    'Excellent',
    'Well Done',
    'You Rock',
    'Amazing Effort',
    'Great Job',
    'Bravo',
    'You Did It',
    'Awesome',
    'Superb',
    'Fantastic',
    'Brilliant',
    'Impressive',
    'Kudos!',
    'Terrific',
    'Way to Go',
    'Outstanding',
    'Keep It Up',
    'Top Notch',
    'Magnificent'
  ];

  static final List<String> encouragementWords = [
    'Good Try',
    'Keep Practicing',
    'Don’t Give Up',
    'Progress Takes Time',
    'You’re Getting There',
    'Stay Focused',
    'Keep Working At It',
    'Challenge Makes You Stronger',
    'Every Step Counts',
    'Room to Improve',
    'Almost There',
    'Keep Going',
    'Practice More',
    'Stay Positive',
    'You Can Do Better',
    'Let’s Try Again',
    'Small Wins Matter',
    'Learn and Grow',
    'Keep Moving Forward',
    'Try Another Round'
  ];

  String getMessage(double percentage) {
    final index = DateTime.now().second % 20;
    return percentage >= 50 ? praiseWords[index] : encouragementWords[index];
  }

  @override
  Widget build(BuildContext context) {
    final double progress = percentage / 100;
    final String message = getMessage(percentage);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset('assets/character2.png', height: 284),
                ),
                const SizedBox(height: 24),
                Text(
                  '$message,',
                  style: AppFontStyles.greeting,
                ),
                Text(
                  '$name!',
                  style: AppFontStyles.name,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF7C2D12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('You got ${percentage.toStringAsFixed(1)}% right',
                    style: AppFontStyles.heading3),
                const SizedBox(height: 24),

                // Animated Row: Time, Kudos, Maxile
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: kudos.toDouble()),
                  duration: const Duration(seconds: 2),
                  builder: (context, double animatedKudos, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Time
                        Flexible(
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(
                                begin: 0, end: durationInSeconds.toDouble()),
                            duration: const Duration(seconds: 2),
                            builder: (context, double animatedTime, child) {
                              return Column(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    formatDuration(animatedTime.toInt()),
                                    style: AppFontStyles.heading4,
                                  ),
                                  const Text('Time taken'),
                                ],
                              );
                            },
                          ),
                        ),

                        // Kudos (center with image)
                        Flexible(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/kudo.png',
                                    height: 72,
                                    width: 72,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    '${animatedKudos.toInt()}',
                                    style: AppFontStyles.heading2,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Kudos earned',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        // Maxile
                        Flexible(
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: maxile),
                            duration: const Duration(seconds: 2),
                            builder: (context, double animatedMaxile, child) {
                              return Column(
                                children: [
                                  const Icon(Icons.leaderboard_outlined,
                                      size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    animatedMaxile.toStringAsFixed(2),
                                    style: AppFontStyles.heading4,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    encouragement,
                                    style: AppFontStyles.greeting,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BottomNavScreen(),
                      ),
                    );
                  },
                  style: AppButtonStyles.primary,
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: AppButtonStyles.secondary,
                  child: const Text('Finish'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/subject-select');
                  },
                  style: AppButtonStyles.tertiary,
                  child: const Text('Subject Select'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
