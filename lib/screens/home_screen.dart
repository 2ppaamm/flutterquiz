import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_button_styles.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../services/user_service.dart';
import '../services/diagnostic_service.dart';
import '../services/question_service.dart';
import 'question_screen.dart';
import '../widgets/out_of_lives_modal.dart';
import 'upgrade_screen.dart';
import '../widgets/diagnostic_unavailable_dialog.dart'; 
import 'diagnostic/diagnostic_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  // ✅ NEW: Diagnostic eligibility state
  bool _canTakeDiagnostic = true;
  String _diagnosticMessage = '';
  int _daysRemaining = 0;
  bool _diagnosticPremium = false;

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
      await prefs.setBool(
          'has_started_kiasu_path',
          response['has_started_kiasu_path'] == 1 ||
              response['has_started_kiasu_path'] == true);
      await prefs.setString('first_name', response['first_name'] ?? 'Student');
      await prefs.setInt('lives', response['lives'] ?? 0);
      await prefs.setInt('kudos', response['kudos'] ?? 0);
      await prefs.setInt('streak', response['streak'] ?? 0);
      await prefs.setInt('total_questions', response['total_questions'] ?? 0);
      await prefs.setInt('topics_practiced', response['topics_practiced'] ?? 0);
      await prefs.setInt('overall_maxile', response['overall_maxile'] ?? 0);

      // ✅ NEW: Save diagnostic eligibility data
      if (response['diagnostic'] != null) {
        final diagnostic = response['diagnostic'];
        await prefs.setBool(
            'can_take_diagnostic', diagnostic['can_take'] ?? true);
        await prefs.setString(
            'diagnostic_message', diagnostic['message'] ?? '');
        await prefs.setInt(
            'diagnostic_days_remaining', diagnostic['days_remaining'] ?? 0);
        await prefs.setBool(
            'diagnostic_premium', diagnostic['is_premium'] ?? false);
      }

      // ✅ NEW: Save last diagnostic result if available
      if (response['last_diagnostic_result'] != null) {
        final lastResultJson = json.encode(response['last_diagnostic_result']);
        await prefs.setString('last_diagnostic_result', lastResultJson);
      }
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

      // ✅ NEW: Load diagnostic eligibility
      _canTakeDiagnostic = prefs.getBool('can_take_diagnostic') ?? true;
      _diagnosticMessage = prefs.getString('diagnostic_message') ?? '';
      _daysRemaining = prefs.getInt('diagnostic_days_remaining') ?? 0;
      _diagnosticPremium = prefs.getBool('diagnostic_premium') ?? false;

      _isLoading = false;
    });
  }

  // ✅ NEW: Handle diagnostic button tap
  void _handleDiagnosticTap() {
    if (!_canTakeDiagnostic) {
      _showDiagnosticRestrictionDialog();
      return;
    }

    // Proceed to diagnostic
    Navigator.pushNamed(context, '/diagnostic').then((_) {
      loadFromStorage(); // Refresh data after returning
    });
  }

  // ✅ UPDATED: Show improved diagnostic restriction dialog
  void _showDiagnosticRestrictionDialog() {
    // Calculate next available date from days remaining
    final nextDate = DateTime.now().add(Duration(days: _daysRemaining));

    showDiagnosticUnavailableDialog(
      context: context,
      nextAvailableDate: nextDate,
      
      // Button 1: View Last Results
      onViewLastResults: () async {
        // Show loading
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
                child: CircularProgressIndicator(color: AppColors.darkRed)));

        // Call your existing service
        final result = await DiagnosticService.getLastDiagnostic();
        Navigator.pop(context);

        if (result != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiagnosticResultScreen(result: result),
              ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No previous diagnostic results found')),
          );
        }
      },
      
      // Button 2: Explore Topics (Browse Topics)
      onExploreTopics: () {
        // Navigate to browse/explore topics screen
        Navigator.pushNamed(context, '/subject-select');
      },
      
      // Button 3: Upgrade to Premium
      onUpgradeToPremium: () {
        // Navigate to upgrade screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UpgradeScreen()),
        );
      },
    );
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
            sessionType: 'kiasu_path',
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
            style: AppButtonStyles.primary,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpgradeScreen(),
                ),
              );
            },
            child: Text('Upgrade Now', style: AppFontStyles.buttonPrimary),
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
            Icon(Icons.info_outline, color: AppColors.darkRed, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child:
                  Text('About Kiasu Path', style: AppFontStyles.headingMedium),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kiasu Path is an AI-powered adaptive learning system that creates a personalized practice plan just for you.',
              style: AppFontStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'How it works:',
              style: AppFontStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoPoint('📊 Analyzes your current skill level'),
            _buildInfoPoint('🎯 Identifies knowledge gaps'),
            _buildInfoPoint('🚀 Selects optimal questions for growth'),
            _buildInfoPoint('⚡ Adapts in real-time to your progress'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: AppFontStyles.buttonSecondary),
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
          Icon(Icons.check_circle, size: 16, color: AppColors.darkRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppFontStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Text('• $text', style: AppFontStyles.bodyMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightGreyBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.darkRed),
        ),
      );
    }

    final bool isKiasuLocked = !_isSubscriber;
    final String kiasuTitle =
        _hasStartedKiasuPath ? 'Continue Kiasu Path' : 'Start Kiasu Path';
    final String kiasuSubtitle =
        _hasStartedKiasuPath ? 'AI-powered practice' : 'AI learns your level';

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Avatar Placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.pink.withOpacity(0.3),
                ),
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

                    // ✅ UPDATED: Test Your Skills Button (with restriction handling)
                    Opacity(
                      opacity: _canTakeDiagnostic ? 1.0 : 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppButtonStyles.secondary,
                          onPressed: _handleDiagnosticTap, // ✅ NEW handler
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Test Your Skills",
                                      style: AppFontStyles.buttonSecondary,
                                    ),
                                    // ✅ Show lock icon if restricted
                                    if (!_canTakeDiagnostic) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: AppColors.darkGreyText,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  // ✅ Show days remaining if restricted
                                  _canTakeDiagnostic
                                      ? "Diagnostic Test"
                                      : "Available in $_daysRemaining ${_daysRemaining == 1 ? 'day' : 'days'}",
                                  style: AppFontStyles.buttonSecondarySubtitle,
                                ),
                              ],
                            ),
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
