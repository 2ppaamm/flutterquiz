import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';
import 'bottom_nav_screen.dart';

class TestResultScreen extends StatefulWidget {
  final int kudos;
  final double maxile;
  final String maxileLevelName; // ✅ Add this parameter from backend
  final double percentage;
  final String name;
  final String token;
  final bool isSubscriber;
  final int durationInSeconds;
  final String encouragement;

  const TestResultScreen({
    Key? key,
    required this.kudos,
    required this.maxile,
    required this.maxileLevelName, // ✅ Required from backend
    required this.percentage,
    required this.name,
    required this.token,
    required this.isSubscriber,
    required this.durationInSeconds,
    required this.encouragement,
  }) : super(key: key);

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _numberController;
  int _animatedKudos = 0;

  late String _confettiAnimation;
  final List<String> _confettiOptions = [
    'assets/animations/BalloonConfetti.json',
    'assets/animations/Confetti.json',
    'assets/animations/Confetti1.json',
    'assets/animations/Correct.json',
    'assets/animations/Fireworks.json',
  ];

  @override
  void initState() {
    super.initState();
    _confettiAnimation =
        _confettiOptions[math.Random().nextInt(_confettiOptions.length)];
    _setupAnimations();
  }

  void _setupAnimations() {
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final numberAnimation = Tween<double>(
      begin: 0,
      end: widget.kudos.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _numberController,
        curve: Curves.easeOutCubic,
      ),
    );

    numberAnimation.addListener(() {
      setState(() {
        _animatedKudos = numberAnimation.value.round();
      });
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _confettiController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _numberController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _getSpeedLabel(int seconds) {
    if (seconds < 60) return 'Lightning';
    if (seconds < 120) return 'Speedy';
    if (seconds < 180) return 'Quick';
    if (seconds < 300) return 'Steady';
    return 'Careful';
  }

  String _getAccuracyLabel(double percentage) {
    if (percentage >= 95) return 'Perfect';
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Great';
    if (percentage >= 70) return 'Good';
    if (percentage >= 60) return 'Decent';
    return 'Learning';
  }

  // ✅ REMOVED _getMaxileLevelName() - now from backend

  String _getMaxileTooltip(double maxile) {
    // Keep tooltip logic or get from backend too
    if (maxile >= 700) {
      return 'Advanced Level (700+): You\'ve mastered this topic! Outstanding work!';
    } else if (maxile >= 500) {
      return 'Growing Level (500-699): You\'re making excellent progress! Keep it up!';
    } else if (maxile >= 300) {
      return 'Building Level (300-499): You\'re developing solid foundations!';
    } else if (maxile >= 100) {
      return 'Beginner Level (100-299): You\'re starting your learning journey!';
    } else {
      return 'Starting Level (0-99): Every expert was once a beginner!';
    }
  }

  Color _getStatColor(String type) {
    switch (type) {
      case 'kudos':
        return AppColors.gold;
      case 'speed':
        return AppColors.speedBlue;
      case 'accuracy':
        return AppColors.accuracyGreen;
      case 'maxile':
        return AppColors.darkRed;
      default:
        return AppColors.darkRed;
    }
  }

  void _showMaxileInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school_outlined, color: AppColors.darkRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text('About Maxile', style: AppFontStyles.headingMedium),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Level Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.darkRed, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Level',
                            style: AppFontStyles.caption.copyWith(
                              color: AppColors.darkGreyText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.maxileLevelName,
                            style: AppFontStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkRed,
                            ),
                          ),
                          Text(
                            'Maxile: ${widget.maxile.round()}',
                            style: AppFontStyles.caption.copyWith(
                              color: AppColors.darkGreyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // What is Maxile
              Text(
                'What is Maxile?',
                style: AppFontStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Maxile is an Item Response Theory (IRT) measurement system invented by All Gifted (Pamela Lim) to assess mathematical ability.',
                style: AppFontStyles.bodyMedium.copyWith(height: 1.4),
              ),

              const SizedBox(height: 16),

              // What is IRT
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'IRT adapts questions to your skill level, making assessment more accurate than traditional tests.',
                        style: AppFontStyles.caption.copyWith(
                          color: AppColors.darkGreyText,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Your Maxile score ranges from 0 to 700+, showing your mathematical development from beginner to advanced levels.',
                style: AppFontStyles.bodyMedium.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!', style: AppFontStyles.buttonSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 24),

                      // ✅ Maxile display - using backend level name
                      GestureDetector(
                        onTap: _showMaxileInfo,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.darkRed.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppColors.darkRed,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Your Maxile',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkRed,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        widget.maxile.round().toString(),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkRed,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkRed
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          widget
                                              .maxileLevelName, // ✅ From backend
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.info_outline,
                                color: AppColors.darkRed,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      Text(
                        'Lesson complete!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 48),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            _buildStatCard(
                              label: 'TOTAL KUDOS',
                              value: _animatedKudos.toString(),
                              subLabel:
                                  widget.kudos > 0 ? 'Earned' : 'Try again',
                              color: _getStatColor('kudos'),
                              icon: Icons.stars_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildStatCard(
                              label: 'TIME',
                              value: _formatDuration(widget.durationInSeconds),
                              subLabel:
                                  _getSpeedLabel(widget.durationInSeconds),
                              color: _getStatColor('speed'),
                              icon: Icons.timer_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildStatCard(
                              label: 'ACCURACY',
                              value: '${widget.percentage.round()}%',
                              subLabel: _getAccuracyLabel(widget.percentage),
                              color: _getStatColor('accuracy'),
                              icon: Icons.check_circle_outline,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),
                    ],
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0, -0.2),
                      child: IgnorePointer(
                        child: Lottie.asset(
                          _confettiAnimation,
                          controller: _confettiController,
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.6,
                          repeat: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => BottomNavScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accuracyGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subLabel,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
