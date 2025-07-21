import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const RiveDemoApp());
}

class RiveDemoApp extends StatelessWidget {
  const RiveDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: RiveAnimation.asset(
              'assets/vehicles.riv',
              fit: BoxFit.contain,
              onInit: _onRiveInit,
            ),
          ),
        ),
      ),
    );
  }

  static void _onRiveInit(Artboard artboard) {
    final controller = SimpleAnimation('idle'); // ✅ This plays the timeline animation
    artboard.addController(controller);
  }
}