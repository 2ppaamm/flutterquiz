import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_font_styles.dart';
import '../../theme/app_button_styles.dart';
import '../../utils/smooth_page_transitions.dart';
import '../bottom_nav_screen.dart';

class DiagnosticResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const DiagnosticResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<DiagnosticResultScreen> createState() => _DiagnosticResultScreenState();
}

class _DiagnosticResultScreenState extends State<DiagnosticResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _numberController;
  late AnimationController _gaugeController;
  late AnimationController _confettiController;
  int _animatedMaxile = 0;
  double _animatedGaugeProgress = 0.0;
  bool _showDetailedResults = false;
  String _getFormattedDate() {
    final completedAt = widget.result['completed_at'] as String?;
    if (completedAt == null) return 'Recently';

    try {
      final date = DateTime.parse(completedAt);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return 'Completed on ${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Recently';
    }
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    final summary = _getSummary();
    final targetMaxile = (summary?['average_maxile'] ?? 0).toDouble();
    final targetProgress = (targetMaxile / 700).clamp(0.0, 1.0);

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Gauge progress animation (separate from number)
    _gaugeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    final gaugeAnimation = Tween<double>(
      begin: 0.0,
      end: targetProgress,
    ).animate(
      CurvedAnimation(
        parent: _gaugeController,
        curve: Curves.easeOutCubic,
      ),
    );

    gaugeAnimation.addListener(() {
      setState(() {
        _animatedGaugeProgress = gaugeAnimation.value;
      });
    });

    // Number animation
    _numberController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    final numberAnimation = Tween<double>(
      begin: 0,
      end: targetMaxile,
    ).animate(
      CurvedAnimation(
        parent: _numberController,
        curve: Curves.easeOutCubic,
      ),
    );

    numberAnimation.addListener(() {
      setState(() {
        _animatedMaxile = numberAnimation.value.round();
      });
    });

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _confettiController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _gaugeController.forward();
        _numberController.forward();
      }
    });

    // Auto-show detailed results after 3 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _showDetailedResults = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _gaugeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  List<dynamic> _getResults() {
    return widget.result['results'] as List<dynamic>? ?? [];
  }

  Map<String, dynamic>? _getSummary() {
    return widget.result['summary'] as Map<String, dynamic>?;
  }

  Color _getLevelColor(int maxile) {
    if (maxile >= 500) return AppColors.levelAdvanced;
    if (maxile >= 300) return AppColors.levelGrowing;
    if (maxile >= 200) return AppColors.levelBuilding;
    return AppColors.levelBeginner;
  }

  // Get level name from API response (don't hardcode)
  String _getLevelName() {
    return widget.result['level_name'] as String? ?? 'Learning';
  }

  @override
  Widget build(BuildContext context) {
    final results = _getResults();
    final summary = _getSummary();
    final averageMaxile = summary?['average_maxile'] ?? 0;
    final totalFields = summary?['total_fields'] ?? 0;
    final totalQuestions = summary?['total_questions'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                // Hero Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white,
                          AppColors.darkRed.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Confetti Animation
                        SizedBox(
                          height: 120,
                          child: Lottie.asset(
                            'assets/animations/Confetti.json',
                            controller: _confettiController,
                            fit: BoxFit.contain,
                            repeat: false,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Title
// Title
                        Text(
                          'Assessment Complete!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),

// ADD THIS DATE SECTION
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getFormattedDate(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        const SizedBox(height: 32),

                        // Big Circular Gauge - FIXED
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Animated Circle - now uses separate gauge controller
                              CustomPaint(
                                size: const Size(200, 200),
                                painter: CircularGaugePainter(
                                  progress: _animatedGaugeProgress,
                                  color: Colors.white,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  strokeWidth: 18,
                                ),
                              ),
                              // Number in center
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$_animatedMaxile',
                                    style: TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your Maxile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getLevelName(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Quick Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickStat(
                                icon: Icons.grid_view_rounded,
                                value: '$totalFields',
                                label: 'Fields',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickStat(
                                icon: Icons.quiz_rounded,
                                value: '$totalQuestions',
                                label: 'Questions',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Swipe indicator
                        AnimatedOpacity(
                          opacity: _showDetailedResults ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 32,
                              ),
                              Text(
                                'Scroll for detailed results',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assessment_rounded,
                          color: AppColors.darkGreyText,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Results by Field',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Field Results
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final field = results[index];
                        return _buildFieldCard(field, index);
                      },
                      childCount: results.length,
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                        SmoothPageTransitions.scaleFade(
                          const BottomNavScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: AppButtonStyles.primary,
                    child: Text(
                      'Continue Learning Journey 🚀',
                      style: AppFontStyles.buttonPrimary.copyWith(fontSize: 18),
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

  Widget _buildQuickStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(Map<String, dynamic> field, int index) {
    final fieldName = field['field_name'] ?? 'Unknown';
    final maxile = field['maxile_level'] ?? 0;
    final levelDesc = field['level_description'] ?? '';
    final levelName =
        field['level_name'] ?? 'Learning'; // Get level name from API
    final ageComp = field['age_comparison'] as Map<String, dynamic>?;
    final nextMilestone = field['next_milestone'] as Map<String, dynamic>?;

    final color = _getLevelColor(maxile);
    final progress = (maxile / 700).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Circular Gauge
                      SizedBox(
                        width: 85,
                        height: 85,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(85, 85),
                              painter: CircularGaugePainter(
                                progress: progress * animValue,
                                color: color,
                                backgroundColor: color.withOpacity(0.15),
                                strokeWidth: 10,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(maxile * animValue).round()}',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  levelName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: color.withOpacity(0.7),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fieldName,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (levelDesc.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                levelDesc,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.darkGreyText,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Age Comparison
                  if (ageComp != null) ...[
                    const SizedBox(height: 14),
                    _buildAgeComparisonChip(ageComp),
                  ],

                  // Next Milestone
                  if (nextMilestone != null) ...[
                    const SizedBox(height: 14),
                    _buildNextMilestone(nextMilestone, color, animValue),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgeComparisonChip(Map<String, dynamic> ageComp) {
    final status = ageComp['status'] ?? 'unknown';
    final message = ageComp['message'] ?? '';
    final icon = ageComp['icon'] ?? '📚';

    Color bgColor;
    Color textColor;

    switch (status) {
      case 'advanced':
        bgColor = AppColors.levelAdvanced.withOpacity(0.12);
        textColor = AppColors.levelAdvanced;
        break;
      case 'on_track':
        bgColor = AppColors.levelGrowing.withOpacity(0.12);
        textColor = AppColors.levelGrowing;
        break;
      case 'developing':
        bgColor = AppColors.levelBuilding.withOpacity(0.12);
        textColor = AppColors.levelBuilding;
        break;
      default:
        bgColor = AppColors.lightGrey;
        textColor = AppColors.darkGreyText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMilestone(
      Map<String, dynamic> milestone, Color cardColor, double animValue) {
    final name = milestone['name'] ?? 'Next Level';
    final pointsAway = milestone['points_away'] ?? 0;

    if (pointsAway <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withOpacity(0.15),
              Colors.orange.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber[700], size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Highest Level Achieved! 🎉',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor.withOpacity(0.05),
            cardColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.flag_rounded, color: cardColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Goal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreyText.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<int>(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  tween:
                      IntTween(begin: 0, end: (pointsAway * animValue).round()),
                  builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$value points away',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cardColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: cardColor,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// Circular Gauge Painter
class CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CircularGaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
