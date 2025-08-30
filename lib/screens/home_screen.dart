import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_font_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _firstName = 'Student';
  String _token = '';
  bool _isSubscriber = false;
  int _gameLevel = 0;
  int _maxileLevel = 0;
  int _lives = 3;
  int _streak = 0;
  int _dailyGoal = 10;
  int _questionsToday = 0;
  String _currentSkill = 'Addition & Subtraction';
  int _currentLesson = 3;
  double _skillProgress = 0.6;

  @override
  void initState() {
    super.initState();
    loadFromStorage();
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('first_name') ?? 'Student';
      _token = prefs.getString('auth_token') ?? '';
      _isSubscriber = prefs.getBool('is_subscriber') ?? false;
      _gameLevel = prefs.getInt('game_level') ?? 1222;
      _maxileLevel = prefs.getInt('maxile_level') ?? 406;
      _lives = prefs.getInt('lives') ?? 5;
      _streak = prefs.getInt('streak') ?? 5;
      _questionsToday = prefs.getInt('questions_today') ?? 7;
      _currentSkill = prefs.getString('current_skill') ?? 'Addition & Subtraction';
      _currentLesson = prefs.getInt('current_lesson') ?? 3;
      _skillProgress = prefs.getDouble('skill_progress') ?? 0.6;
    });
  }

  Widget _buildCompactStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactStatItem(Icons.stars, _gameLevel.toString(), "XP", const Color(0xFF960000)),
          _buildCompactStatItem(Icons.favorite, _lives.toString(), "Lives", Colors.red),
          _buildCompactStatItem(Icons.trending_up, _maxileLevel.toString(), "Maxile", Colors.blue),
          _buildCompactStatItem(Icons.local_fire_department, _streak.toString(), "Streak", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGoalCompact() {
    final progress = _questionsToday / _dailyGoal;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 4,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : const Color(0xFF960000),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Goal",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progress >= 1.0 ? "Goal completed! Well done!" : "${_questionsToday}/${_dailyGoal} questions today",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: progress >= 1.0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Compact Stats Row
              _buildCompactStats(),

              const SizedBox(height: 8),

              // Welcome Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _firstName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Primary Continue Button - Now prominently placed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppButtonStyles.primary?.copyWith(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      elevation: MaterialStateProperty.all(3),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/question');
                    },
                    child: Column(
                      children: [
                        Text(
                          "Continue Learning",
                          style: AppFontStyles.buttonPrimary?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$_currentSkill - Lesson $_currentLesson",
                          style: AppFontStyles.buttonSubtitle?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: LinearProgressIndicator(
                            value: _skillProgress,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Compact Daily Goal
              _buildDailyGoalCompact(),

              const SizedBox(height: 20),

              // Secondary Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: AppButtonStyles.secondary?.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/test');
                        },
                        child: Column(
                          children: [
                            Text("Test Skills", style: AppFontStyles.buttonSecondary),
                            Text("Quick assessment", style: AppFontStyles.buttonSecondarySubtitle?.copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: AppButtonStyles.tertiary?.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/subject-select');
                        },
                        child: Column(
                          children: [
                            Text("Browse Topics", style: AppFontStyles.buttonSecondary),
                            Text("Explore subjects", style: AppFontStyles.buttonSecondarySubtitle?.copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}