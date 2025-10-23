import 'package:flutter/material.dart';
import 'screens/startup_splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/subject_select_screen.dart';
import 'screens/diagnostic/diagnostic_screen.dart';
import 'screens/question_screen.dart';
import 'theme/app_theme.dart';

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
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/subject-select':
            return MaterialPageRoute(builder: (_) => SubjectSelectScreen());
          case '/diagnostic':
            return MaterialPageRoute(builder: (_) => const DiagnosticScreen());
          case '/question':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => QuestionScreen(
                  trackId: args['trackId'] as int?,
                  testId: args['testId'] as int?,
                  trackName: args['trackName'] as String?,
                  questions: args['questions'] as List<dynamic>,
                  sessionType: args['sessionType'] as String? ?? 'track',
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