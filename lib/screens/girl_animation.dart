import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const RiveTestApp());
}

class RiveTestApp extends StatelessWidget {
  const RiveTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: RiveAnimation.asset(
              'assets/girl_animation.riv',
              artboard: 'Artboard',
              stateMachines: ['State Machine 1'],
              onInit: _onRiveInit,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  static void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    if (controller != null) {
      artboard.addController(controller);
      final trigger = controller.findInput<bool>('Mouse enter');
      if (trigger != null && trigger is SMITrigger) {
        trigger.fire();
      }
    }
  }
}
