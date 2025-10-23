import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

class LivesHeader extends StatefulWidget {
  final int lives;
  final int maxLives;
  final bool unlimited;
  final int? nextLifeInSeconds;
  final Function(int)? onTimerUpdate;

  const LivesHeader({
    Key? key,
    required this.lives,
    required this.maxLives,
    this.unlimited = false,
    this.nextLifeInSeconds,
    this.onTimerUpdate,
  }) : super(key: key);

  @override
  State<LivesHeader> createState() => _LivesHeaderState();
}

class _LivesHeaderState extends State<LivesHeader> {
  int? _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.nextLifeInSeconds;
    if (_remainingSeconds != null && _remainingSeconds! > 0) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(LivesHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nextLifeInSeconds != oldWidget.nextLifeInSeconds) {
      _remainingSeconds = widget.nextLifeInSeconds;
      if (_remainingSeconds != null && _remainingSeconds! > 0) {
        _startCountdown();
      } else {
        _countdownTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds != null && _remainingSeconds! > 0) {
          _remainingSeconds = _remainingSeconds! - 1;
          
          // Notify parent of timer update
          if (widget.onTimerUpdate != null) {
            widget.onTimerUpdate!(_remainingSeconds!);
          }
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _formatTimeRemaining(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Hide completely for unlimited lives users (Premium/SIMBA)
    if (widget.unlimited) {
      return const SizedBox.shrink();
    }

    // Show lives header for free users
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hearts display (individual doodle hearts)
          Row(
            children: List.generate(widget.maxLives, (index) {
              final isFilled = index < widget.lives;
              return Padding(
                padding: EdgeInsets.only(right: index < widget.maxLives - 1 ? 6 : 0),
                child: CustomPaint(
                  size: const Size(28, 28),
                  painter: DoodleHeartPainter(
                    isFilled: isFilled,
                    fillColor: AppColors.darkRed,
                    emptyColor: AppColors.lightGrey,
                  ),
                ),
              );
            }),
          ),

          // Next life timer
          if (_remainingSeconds != null && _remainingSeconds! > 0 && widget.lives < widget.maxLives)
            Row(
              children: [
                Icon(Icons.timer_outlined, color: AppColors.mediumGrey, size: 20),
                const SizedBox(width: 4),
                Text(
                  '+1 in ${_formatTimeRemaining(_remainingSeconds!)}',
                  style: AppFontStyles.bodyMedium.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ✅ Custom Doodle-Style Heart Painter
class DoodleHeartPainter extends CustomPainter {
  final bool isFilled;
  final Color fillColor;
  final Color emptyColor;

  DoodleHeartPainter({
    required this.isFilled,
    required this.fillColor,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = isFilled ? fillColor : emptyColor;

    // Doodle-style hand-drawn heart path (slightly imperfect curves)
    final path = Path();
    
    // Start at bottom point
    path.moveTo(size.width * 0.5, size.height * 0.95);
    
    // Right side of heart (with slight wobble for doodle effect)
    path.cubicTo(
      size.width * 0.7, size.height * 0.75,
      size.width * 0.9, size.height * 0.55,
      size.width * 0.88, size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.86, size.height * 0.15,
      size.width * 0.7, size.height * 0.05,
      size.width * 0.5, size.height * 0.2,
    );
    
    // Left side of heart (with slight wobble for doodle effect)
    path.cubicTo(
      size.width * 0.3, size.height * 0.05,
      size.width * 0.14, size.height * 0.15,
      size.width * 0.12, size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.1, size.height * 0.55,
      size.width * 0.3, size.height * 0.75,
      size.width * 0.5, size.height * 0.95,
    );
    
    canvas.drawPath(path, paint);
    
    // Add slight outline even when filled for doodle effect
    if (isFilled) {
      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = fillColor.withOpacity(0.8);
      canvas.drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(DoodleHeartPainter oldDelegate) =>
      oldDelegate.isFilled != isFilled ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.emptyColor != emptyColor;
}