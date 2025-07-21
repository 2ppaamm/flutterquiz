import 'dart:math';
import 'package:flutter/material.dart';

class FireworksWidget extends StatefulWidget {
  final List<Color> colors;
  final bool loop;
  final Offset offset; // Absolute position (x, y)
  final double size; // Radius of explosion

  const FireworksWidget({
    super.key,
    required this.colors,
    this.loop = true,
    this.offset = const Offset(200, 600),
    this.size = 120,
  });

  @override
  State<FireworksWidget> createState() => _FireworksWidgetState();
}

class _FireworksWidgetState extends State<FireworksWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.offset.dx - widget.size,
      top: widget.offset.dy - widget.size,
      child: SizedBox(
        width: widget.size * 2,
        height: widget.size * 2,
        child: CustomPaint(
          painter: _FireworksPainter(
            animation: _controller,
            colors: widget.colors,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  final double size;
  final int numParticles = 25;

  _FireworksPainter({
    required this.animation,
    required this.colors,
    required this.size,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final progress = animation.value;

    for (int i = 0; i < numParticles; i++) {
      final angle = 2 * pi * i / numParticles;
      final radius = Curves.easeOut.transform(progress) * size;

      final dx = radius * cos(angle);
      final dy = radius * sin(angle);
      final color = colors[i % colors.length].withOpacity(1 - progress);
      final paint = Paint()..color = color;

      canvas.drawCircle(center + Offset(dx, -dy), 5.0 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}