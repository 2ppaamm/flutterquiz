import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../services/user_service.dart';
import '../services/question_service.dart';
import '../services/upgrade_service.dart';
import 'question_screen.dart';
import '../widgets/out_of_lives_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _firstName = 'Student';
  int _streak = 0;
  int _totalQuestions = 0;
  int _topicsPracticed = 0;
  int _overallMaxile = 0;
  int _kudos = 0;
  bool _isSubscriber = false;
  bool _hasStartedKiasuPath = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFromStorage();
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Fetch fresh data from backend
    final response = await UserService.getSubscriptionStatus();

    if (response != null && response['ok'] == true) {
      // Check access_type to determine if user is premium
      bool isSubscriber = response['access_type'] == "premium";

      // Save to SharedPreferences
      await prefs.setBool('is_subscriber', isSubscriber);
      await prefs.setBool('has_started_kiasu_path',
          response['has_started_kiasu_path'] == 1 || response['has_started_kiasu_path'] == true);
      await prefs.setString('first_name', response['first_name'] ?? 'Student');
      await prefs.setInt('lives', response['lives'] ?? 0);
      await prefs.setInt('kudos', response['kudos'] ?? 0);
      await prefs.setInt('streak', response['streak'] ?? 0);
      await prefs.setInt('total_questions', response['total_questions'] ?? 0);
      await prefs.setInt('topics_practiced', response['topics_practiced'] ?? 0);
      await prefs.setInt('overall_maxile', response['overall_maxile'] ?? 0);
    }

    // Update state
    setState(() {
      _firstName = prefs.getString('first_name') ?? 'Student';
      _streak = prefs.getInt('streak') ?? 0;
      _totalQuestions = prefs.getInt('total_questions') ?? 0;
      _topicsPracticed = prefs.getInt('topics_practiced') ?? 0;
      _overallMaxile = prefs.getInt('overall_maxile') ?? 0;
      _kudos = prefs.getInt('kudos') ?? 0;
      _isSubscriber = prefs.getBool('is_subscriber') ?? false;
      _hasStartedKiasuPath = prefs.getBool('has_started_kiasu_path') ?? false;
      _isLoading = false;
    });
  }

  void _handleKiasuPathTap() async {
    if (!_isSubscriber) {
      _showPremiumFeatureDialog();
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.darkRed),
      ),
    );

    // Call API to start Kiasu Path
    final response = await QuestionService.startKiasuPath();

    // Close loading
    Navigator.pop(context);

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start Kiasu Path. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if access denied
    if (response['code'] == 403 || response['ok'] == false) {
      _showPremiumFeatureDialog();
      return;
    }

    // Check for out of lives
    if (response['code'] == 205) {
      OutOfLivesModal.show(
        context,
        nextLifeInSeconds: response['next_life_in_seconds'] ?? 1800,
        onGoBack: () {},
        customMessage: response['message'],
      );
      return;
    }

    // Success! Navigate to question screen
    if (response['questions'] is List &&
        (response['questions'] as List).isNotEmpty) {
      final List<dynamic> questions = response['questions'];
      final int testId = int.tryParse(response['test_id']?.toString() ??
              response['test']?.toString() ??
              '0') ??
          0;

      // SYNC: Update lives from API response to local storage
      if (response['lives'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lives', response['lives'] as int);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(
            trackId: 0,
            trackName: 'Kiasu Path',
            testId: testId,
            questions: questions,
            sessionType: 'kiasu_path', // ← ADDED THIS LINE
          ),
        ),
      ).then((_) {
        loadFromStorage();
      });
    }
  }

  void _showPremiumFeatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.stars, color: AppColors.darkRed, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child:
                  Text('Premium Feature', style: AppFontStyles.headingMedium),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kiasu Path uses AI to create a personalized practice plan optimized for your level and learning goals.',
              style: AppFontStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Premium includes:',
                    style: AppFontStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBenefit('AI-powered Kiasu Path'),
                  _buildBenefit('Unlimited practice (no lives)'),
                  _buildBenefit('Unlimited diagnostic tests'),
                  _buildBenefit('Ad-free experience'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now', style: AppFontStyles.buttonSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              UpgradeService.showSubscriptionOptions(context);
            },
            style: AppButtonStyles.primary,
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  void _showKiasuInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('🇸🇬', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child:
                  Text('What is "Kiasu"?', style: AppFontStyles.headingMedium),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kiasu (怕输) is a Singlish term from Hokkien meaning "fear of losing out."',
              style: AppFontStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'In Singapore and Malaysia, being kiasu means you\'re always striving to be ahead - never wanting to fall behind!',
              style: AppFontStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppColors.darkRed, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kiasu Path uses AI to:',
                        style: AppFontStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildBenefit('Identify your knowledge gaps'),
                  _buildBenefit('Create personalized practice plans'),
                  _buildBenefit('Adapt difficulty to your progress'),
                  _buildBenefit('Ensure you never fall behind!'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!_isSubscriber)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                UpgradeService.showSubscriptionOptions(context);
              },
              style: AppButtonStyles.primary,
              child: const Text('Unlock Kiasu Path'),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Got it!', style: AppFontStyles.buttonSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppFontStyles.caption),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.darkRed),
        ),
      );
    }

    // Determine button title and state
    final kiasuTitle =
        _hasStartedKiasuPath ? "Continue Kiasu Path" : "Kiasu Path";
    final kiasuSubtitle =
        _isSubscriber ? "AI-optimized practice" : "Unlock with Premium";
    final isKiasuLocked = !_isSubscriber;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Kudos display in top right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_kudos',
                      style: AppFontStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreyText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Mascot Character Placeholder
              Container(
                height: 180,
                child: Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 120,
                    color: AppColors.pink,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Welcome Text
              Text('Welcome back,', style: AppFontStyles.greeting),
              const SizedBox(height: 4),
              Text(_firstName, style: AppFontStyles.name),

              const SizedBox(height: 40),

              // Main Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Kiasu Path Button (Premium)
                    Opacity(
                      opacity: isKiasuLocked ? 0.5 : 1.0,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: isKiasuLocked
                              ? AppButtonStyles.primary
                              : ElevatedButton.styleFrom(
                                  // ✅ Override when unlocked
                                  backgroundColor: AppColors.darkRed,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                          onPressed: _handleKiasuPathTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            kiasuTitle,
                                            style: AppFontStyles.buttonPrimary,
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () {
                                              _showKiasuInfoDialog();
                                            },
                                            child: Icon(
                                              Icons.info_outline,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (isKiasuLocked) ...[
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.lock,
                                              size: 16,
                                              color: AppColors.white,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        kiasuSubtitle,
                                        style: AppFontStyles.buttonSubtitle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Test Your Skills Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppButtonStyles.secondary,
                        onPressed: () {
                          Navigator.pushNamed(context, '/diagnostic');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              Text(
                                "Test Your Skills",
                                style: AppFontStyles.buttonSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Diagnostic Test",
                                style: AppFontStyles.buttonSecondarySubtitle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subject Select Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppButtonStyles.tertiary,
                        onPressed: () {
                          Navigator.pushNamed(context, '/subject-select');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              Text(
                                "Browse Topics",
                                style: AppFontStyles.buttonSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Practice any subject",
                                style: AppFontStyles.buttonSecondarySubtitle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Stats Footer - Always visible
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    if (_streak > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_streak day streak',
                            style: AppFontStyles.bodyMedium.copyWith(
                              color: AppColors.darkGreyText,
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        [
                          if (_totalQuestions > 0)
                            '✓ $_totalQuestions questions',
                          if (_topicsPracticed > 0)
                            '📚 $_topicsPracticed topics',
                          if (_overallMaxile > 0) '📊 Maxile $_overallMaxile',
                        ].join(' • '),
                        style: AppFontStyles.buttonSubtitle.copyWith(
                          color: AppColors.darkGreyText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}