import 'package:flutter/material.dart';

/// Smooth page transitions for AG Math app
class SmoothPageTransitions {
  /// Fade transition - subtle and professional
  static Route<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Slide from right - directional and clear
  static Route<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Scale + Fade - elegant and premium feeling
  static Route<T> scaleFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        var scaleTween = Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve));
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        
        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Slide up - good for modal-style transitions
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.3);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// No animation - instant transition
  static Route<T> instant<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
    );
  }
}

/// Extension methods for easier navigation
extension SmoothNavigation on BuildContext {
  /// Push with fade transition
  Future<T?> pushFade<T>(Widget page) {
    return Navigator.push<T>(this, SmoothPageTransitions.fadeTransition(page));
  }

  /// Push replacement with fade transition
  Future<T?> pushReplacementFade<T>(Widget page) {
    return Navigator.pushReplacement<T, void>(
      this,
      SmoothPageTransitions.fadeTransition(page),
    );
  }

  /// Push with slide from right transition
  Future<T?> pushSlide<T>(Widget page) {
    return Navigator.push<T>(this, SmoothPageTransitions.slideFromRight(page));
  }

  /// Push replacement with slide from right transition
  Future<T?> pushReplacementSlide<T>(Widget page) {
    return Navigator.pushReplacement<T, void>(
      this,
      SmoothPageTransitions.slideFromRight(page),
    );
  }

  /// Push with scale + fade transition
  Future<T?> pushScaleFade<T>(Widget page) {
    return Navigator.push<T>(this, SmoothPageTransitions.scaleFade(page));
  }

  /// Push replacement with scale + fade transition
  Future<T?> pushReplacementScaleFade<T>(Widget page) {
    return Navigator.pushReplacement<T, void>(
      this,
      SmoothPageTransitions.scaleFade(page),
    );
  }

  /// Push with slide up transition
  Future<T?> pushSlideUp<T>(Widget page) {
    return Navigator.push<T>(this, SmoothPageTransitions.slideUp(page));
  }
}