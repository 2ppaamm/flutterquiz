import 'package:flutter/material.dart';

class StartupSplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const StartupSplashScreen({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<StartupSplashScreen> createState() => _StartupSplashScreenState();
}

class _StartupSplashScreenState extends State<StartupSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.nextScreen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/animations/octo2.gif'),
      ),
    );
  }
}
