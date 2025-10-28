import 'package:flutter/material.dart';
import 'screens/startup_splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/subject_select_screen.dart';
import 'screens/diagnostic/diagnostic_screen.dart';
import 'screens/question_screen.dart';
import 'theme/app_theme.dart';
import 'screens/diagnostic/diagnostic_result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Gifted Math',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      
      onGenerateRoute: (settings) {
        // ✅ On first load, always go to splash regardless of URL
        if (!_hasInitialized) {
          _hasInitialized = true;
          return MaterialPageRoute(
            builder: (_) => const StartupSplashScreen(),
          );
        }
        
        // After initialization, handle routes normally
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const StartupSplashScreen());
          
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen());
          
          case '/subject-select':
            return MaterialPageRoute(builder: (_) => SubjectSelectScreen());
          
          // ✅ WRAP DIAGNOSTIC - Back button goes to home
          case '/diagnostic':
            return MaterialPageRoute(
              builder: (_) => const BackToHomeWrapper(
                child: DiagnosticScreen(),
              ),
            );
          
          // ✅ WRAP DIAGNOSTIC RESULT - Back button goes to home
          case '/diagnostic-result':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => BackToHomeWrapper(
                child: DiagnosticResultScreen(
                  result: args?['result'] ?? {},
                ),
              ),
            );
          
          case '/question':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              // ✅ WRAP QUESTION SCREEN - Back button goes to home
              return MaterialPageRoute(
                builder: (_) => BackToHomeWrapper(
                  child: QuestionScreen(
                    trackId: args['trackId'] as int?,
                    testId: args['testId'] as int?,
                    trackName: args['trackName'] as String?,
                    questions: args['questions'] as List<dynamic>,
                    sessionType: args['sessionType'] as String? ?? 'track',
                  ),
                ),
              );
            }
            break;
        }
        
        // Unknown route - go to splash
        return MaterialPageRoute(
          builder: (_) => const StartupSplashScreen(),
        );
      },
    );
  }
}

// ========================================
// ✅ ADD THIS WIDGET - Back Button Handler
// ========================================

class BackToHomeWrapper extends StatelessWidget {
  final Widget child;

  const BackToHomeWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          // Navigate to home instead of popping
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false, // Clear all previous routes
          );
        }
      },
      child: child,
    );
  }
}