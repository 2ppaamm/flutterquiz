import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';
import '../utils/smooth_page_transitions.dart';
import 'bottom_nav_screen.dart';

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
  late AnimationController _dialController;

  @override
  void initState() {
    super.initState();
    _dialController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _dialController.forward();
    });
  }

  @override
  void dispose() {
    _dialController.dispose();
    super.dispose();
  }

  List<dynamic> _getResults() {
    return widget.result['results'] as List<dynamic>? ?? [];
  }

  Map<String, dynamic>? _getSummary() {
    return widget.result['summary'] as Map<String, dynamic>?;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'advanced':
        return AppColors.levelAdvanced;
      case 'on_track':
        return AppColors.levelGrowing;
      case 'developing':
        return AppColors.levelBuilding;
      case 'needs_support':
        return AppColors.levelBeginner;
      default:
        return AppColors.darkGreyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _getResults();
    final summary = _getSummary();
    final averageMaxile = summary?['average_maxile'] ?? 0;

    return Scaffold(
      backgroundColor: Color(0xFF0a0a12),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1a1a24), Color(0xFF0a0a12)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FLIGHT DIAGNOSTICS',
                        style: TextStyle(
                          color: Color(0xFF00ff88).withOpacity(0.8),
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF00ff88).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Color(0xFF00ff88), width: 1),
                        ),
                        child: Text(
                          'ALL SYSTEMS GO',
                          style: TextStyle(
                            color: Color(0xFF00ff88),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'AVG ALTITUDE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.easeOutCubic,
                        tween: IntTween(begin: 0, end: averageMaxile.round()),
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: TextStyle(
                              color: Color(0xFF00ff88),
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              shadows: [
                                Shadow(
                                  color: Color(0xFF00ff88).withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MXL',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Cockpit Panel
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Color(0xFF1a1a24),
                      Color(0xFF0a0a12),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INSTRUMENT PANEL',
                        style: TextStyle(
                          color: Color(0xFF00ff88).withOpacity(0.6),
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Grid of Dials
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              return _buildCockpitDial(results[index], index);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0a0a12), Color(0xFF1a1a24)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CLEAR FOR TAKEOFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.flight_takeoff, color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCockpitDial(Map<String, dynamic> field, int index) {
    final fieldName = field['field_name'] ?? 'Unknown';
    final maxile = field['maxile_level'] ?? 0;
    final ageComp = field['age_comparison'] as Map<String, dynamic>?;
    final status = ageComp?['status'] ?? 'unknown';
    
    final progress = (maxile / 700).clamp(0.0, 1.0);
    final color = _getStatusColor(status);

    return AnimatedBuilder(
      animation: _dialController,
      builder: (context, child) {
        final animProgress = Curves.easeOutCubic.transform(_dialController.value);
        final delay = index * 0.08;
        final adjustedProgress = ((animProgress - delay) / (1 - delay)).clamp(0.0, 1.0);

        return Opacity(
          opacity: adjustedProgress,
          child: Transform.scale(
            scale: 0.85 + (0.15 * adjustedProgress),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF2a2a3a),
                    Color(0xFF1a1a24),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Metallic texture overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Aircraft Dial
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CustomPaint(
                              painter: AircraftDialPainter(
                                progress: progress * adjustedProgress,
                                maxile: maxile,
                                color: color,
                                animationProgress: adjustedProgress,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Field Name Label
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              fieldName.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Status Indicator Light
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'advanced':
        return 'OPTIMAL';
      case 'on_track':
        return 'NOMINAL';
      case 'developing':
        return 'STABLE';
      case 'needs_support':
        return 'CAUTION';
      default:
        return 'STANDBY';
    }
  }
}

// Aircraft-style Dial Painter
class AircraftDialPainter extends CustomPainter {
  final double progress;
  final int maxile;
  final Color color;
  final double animationProgress;

  AircraftDialPainter({
    required this.progress,
    required this.maxile,
    required this.color,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Outer bezel - metallic rim
    final bezelPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF4a4a5a),
          Color(0xFF2a2a3a),
          Color(0xFF1a1a24),
        ],
        stops: [0.8, 0.95, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    
    canvas.drawCircle(center, size.width / 2, bezelPaint);

    // Glass reflection effect
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 1.5,
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius + 5, glassPaint);

    // Inner dial face
    final dialFacePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF1a1a28),
          Color(0xFF0d0d14),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, dialFacePaint);

    // Draw tick marks and numbers
    _drawTickMarks(canvas, center, radius);

    // Progress arc (green zone indicator)
    if (progress > 0) {
      final arcPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        -math.pi * 0.75,
        math.pi * 1.5 * progress,
        false,
        arcPaint,
      );
    }

    // Needle
    if (animationProgress > 0) {
      _drawNeedle(canvas, center, radius, progress);
    }

    // Center hub
    final hubPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF3a3a4a),
          Color(0xFF1a1a24),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 8));
    
    canvas.drawCircle(center, 8, hubPaint);
    
    canvas.drawCircle(
      center,
      6,
      Paint()..color = color.withOpacity(0.8),
    );

    // Digital readout at bottom
    _drawDigitalReadout(canvas, center, radius, maxile, color);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final majorTickPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw 0-700 scale around the dial
    for (int i = 0; i <= 10; i++) {
      final angle = -math.pi * 0.75 + (math.pi * 1.5 * i / 10);
      final isMajor = i % 2 == 0;
      
      final paint = isMajor ? majorTickPaint : minorTickPaint;
      final tickLength = isMajor ? 15.0 : 8.0;
      
      final outerPoint = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      
      final innerPoint = Offset(
        center.dx + (radius - 5 - tickLength) * math.cos(angle),
        center.dy + (radius - 5 - tickLength) * math.sin(angle),
      );
      
      canvas.drawLine(outerPoint, innerPoint, paint);

      // Draw numbers for major ticks
      if (isMajor) {
        final value = (i * 70).toString();
        textPainter.text = TextSpan(
          text: value,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        );
        
        textPainter.layout();
        
        final textOffset = Offset(
          center.dx + (radius - 30) * math.cos(angle) - textPainter.width / 2,
          center.dy + (radius - 30) * math.sin(angle) - textPainter.height / 2,
        );
        
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius, double progress) {
    final needleAngle = -math.pi * 0.75 + (math.pi * 1.5 * progress);
    
    // Needle shadow
    final shadowPath = Path();
    shadowPath.moveTo(center.dx - 5, center.dy);
    shadowPath.lineTo(
      center.dx + (radius - 25) * math.cos(needleAngle) + 2,
      center.dy + (radius - 25) * math.sin(needleAngle) + 2,
    );
    shadowPath.lineTo(center.dx + 5, center.dy);
    shadowPath.close();
    
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main needle
    final needlePath = Path();
    needlePath.moveTo(center.dx - 4, center.dy);
    needlePath.lineTo(
      center.dx + (radius - 25) * math.cos(needleAngle),
      center.dy + (radius - 25) * math.sin(needleAngle),
    );
    needlePath.lineTo(center.dx + 4, center.dy);
    needlePath.close();
    
    final needlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          color,
        ],
      ).createShader(needlePath.getBounds());
    
    canvas.drawPath(needlePath, needlePaint);

    // Needle highlight
    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawDigitalReadout(Canvas canvas, Offset center, double radius, int maxile, Color color) {
    final readoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.5),
        width: 70,
        height: 24,
      ),
      Radius.circular(4),
    );
    
    // Readout background
    canvas.drawRRect(
      readoutRect,
      Paint()..color = Colors.black.withOpacity(0.8),
    );
    
    canvas.drawRRect(
      readoutRect,
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Digital number
    final textPainter = TextPainter(
      text: TextSpan(
        text: maxile.toString().padLeft(3, '0'),
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          shadows: [
            Shadow(
              color: color.withOpacity(0.8),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius * 0.5 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}