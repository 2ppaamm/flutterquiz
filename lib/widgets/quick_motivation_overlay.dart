import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QuickMotivationOverlay extends StatefulWidget {
  const QuickMotivationOverlay({super.key});

  @override
  State<QuickMotivationOverlay> createState() => _QuickMotivationOverlayState();
}

class _QuickMotivationOverlayState extends State<QuickMotivationOverlay> 
    with SingleTickerProviderStateMixin {
  final _random = Random();
  
  // Animation assets - only confetti effects
  static const _animations = [
    'assets/animations/Confetti.json',
    'assets/animations/Confetti1.json',
  ];

  late String _selectedAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pick random animation
    _selectedAnimation = _animations[_random.nextInt(_animations.length)];
    
    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    // Start fade in
    _fadeController.forward();
    
    // Auto-dismiss after animation completes (about 1.5-2 seconds)
    Future.delayed(const Duration(milliseconds: 1800), () async {
      if (mounted) {
        await _fadeController.reverse();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent, // Transparent so home screen shows through
        child: IgnorePointer( // Don't block taps, just show animation
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0, // Force square aspect ratio
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Lottie.asset(
                  _selectedAnimation,
                  repeat: false,
                  fit: BoxFit.contain, // Contain within the square
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Lottie load error: $error');
                    // Return empty container if animation fails
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to show the overlay
Future<void> showQuickMotivation(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent, // No dark overlay
    builder: (context) => const QuickMotivationOverlay(),
  );
}