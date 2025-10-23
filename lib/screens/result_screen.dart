import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_colors.dart';
import 'bottom_nav_screen.dart';

class ResultScreen extends StatefulWidget {
  final int kudos;
  final double maxile;
  final double percentage;
  final String name;
  final String token;
  final bool isSubscriber;
  final int durationInSeconds;
  final String encouragement;

  const ResultScreen({
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

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _updateUserStats();
  }

  void _setupAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.percentage / 100).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeOut),
    );
    
    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsAnimationController, curve: Curves.elasticOut),
    );

    // Start animations
    _progressAnimationController.forward();
    _statsAnimationController.forward();
  }

  Future<void> _updateUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('game_level', widget.kudos);
    await prefs.setInt('maxile_level', widget.maxile.toInt());
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getMessage(double percentage) {
    if (percentage >= 90) return 'Outstanding';
    if (percentage >= 80) return 'Great Job';
    if (percentage >= 70) return 'Well Done';
    if (percentage >= 60) return 'Good Work';
    if (percentage >= 50) return 'Nice Try';
    return 'Keep Practicing';
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Header Section
              Text(
                '${_getMessage(widget.percentage)},',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF960000),
                ),
              ),
              
              const SizedBox(height: 40),

              // Score Display
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${(_progressAnimation.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF960000),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Questions Correct',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.percentage >= 80 ? Colors.green : 
                              widget.percentage >= 60 ? Colors.orange : 
                              const Color(0xFF960000),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Stats Row
              AnimatedBuilder(
                animation: _statsAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _statsAnimation.value,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.timer_outlined,
                            _formatTime(widget.durationInSeconds),
                            'Time',
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.stars,
                            widget.kudos.toString(),
                            'Kudos',
                            const Color(0xFF960000),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.trending_up,
                            widget.maxile.toInt().toString(),
                            'Maxile',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Single Clear Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => BottomNavScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF960000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}