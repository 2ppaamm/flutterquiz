import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'test_result_screen.dart';
import '../widgets/out_of_lives_modal.dart';
import '../widgets/lives_header.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';
import '../utils/math_text_utils.dart';
import '../utils/question_blank_utils.dart';
import '../widgets/common_question_widgets.dart';
import 'bottom_nav_screen.dart';
import '../../config.dart';
import '../widgets/question_feedback_widget.dart';

class QuestionScreen extends StatefulWidget {
  final int? trackId;
  final int? testId;
  final String? trackName;
  final List<dynamic> questions;
  final String sessionType;

  const QuestionScreen({
    super.key,
    this.trackId,
    this.testId,
    this.trackName,
    required this.questions,
    required this.sessionType,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
  late DateTime startTime;
  int currentIndex = 0;
  int lives = 5;
  int maxLives = 5;
  bool unlimited = false;
  int? nextLifeInSeconds;
  bool hasAnswered = false;
  bool isCorrect = false;
  String? selectedAnswer;

  final Map<int, TextEditingController> _blankControllers = {};
  int? _activeBlank;

  Map<String, String> fillInAnswers = {};
  String activeInputField = '';

  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackScaleAnimation;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  List<int> submittedQuestionIds = [];
  List<dynamic> submittedAnswers = [];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _setupAnimations();
    _resetQuestionState();
    _initializeQuestion();
    _loadUserData();
  }

  void _reduceLives() async {
  final prefs = await SharedPreferences.getInstance();

  // ✅ Check unlimited FIRST
  final isUnlimited = prefs.getBool('unlimited') ?? false;
  final isSubscriber = prefs.getBool('is_subscriber') ?? false;

  // ✅ Exit immediately if unlimited or subscriber
  if (isUnlimited || isSubscriber) {
    return; // Don't reduce lives at all
  }

  // Only reduce lives for non-unlimited users
  final currentLives = prefs.getInt('lives') ?? 5;
  if (currentLives > 0) {
    final newLives = currentLives - 1;
    await prefs.setInt('lives', newLives);
    setState(() {
      lives = newLives;
      unlimited = isUnlimited || isSubscriber;
    });

    // ✅ CRITICAL: If lives hit 0 AND this is a track test, submit results immediately
    if (newLives <= 0 && widget.sessionType == 'track') {
      // Send results to backend - this will handle showing modal or navigating
      await _sendResults();
    }
  }
}
  int _calculateNextLifeTime() {
    return 1800;
  }

  // ✅ FIXED: Simplified to return the question directly
  Map<String, dynamic> _getQuestionData(int index) {
    return widget.questions[index] as Map<String, dynamic>;
  }

  // ✅ NEW: Helper to check if user is unlimited/subscriber
  Future<bool> _isUnlimitedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_subscriber') ?? false;
  }

  void _setupAnimations() {
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _feedbackScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
          parent: _feedbackAnimationController, curve: Curves.elasticOut),
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _progressAnimationController, curve: Curves.easeOut),
    );

    _progressAnimationController.forward();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lives = prefs.getInt('lives') ?? 5;
      maxLives = prefs.getInt('max_lives') ?? 5;
      unlimited = prefs.getBool('unlimited') ?? false;
      nextLifeInSeconds = prefs.getInt('next_life_in_seconds');
    });
  }

  void _resetQuestionState() {
    currentIndex = 0;
    hasAnswered = false;
    isCorrect = false;
    selectedAnswer = null;
    _clearBlankControllers();
    submittedQuestionIds.clear();
    submittedAnswers.clear();
  }

  void _clearBlankControllers() {
    for (var controller in _blankControllers.values) {
      controller.dispose();
    }
    _blankControllers.clear();
    _activeBlank = null;
    fillInAnswers.clear();
    activeInputField = '';
  }

  void _initializeQuestion() {
    final currentQuestion = _getQuestionData(currentIndex);
    final questionText = currentQuestion['question'] ?? '';
    final typeId = currentQuestion['type_id'];

    // ✅ Only initialize input fields for type 2 (fill-in-blank)
    if (typeId == 2) {
      // Handle [0], [1], [2], [3] style blanks
      if (QuestionBlankUtils.hasBlanks(questionText)) {
        final blanks = QuestionBlankUtils.extractBlanks(questionText);
        for (var blank in blanks) {
          _blankControllers[blank] = TextEditingController();
        }
        if (blanks.isNotEmpty) {
          _activeBlank = blanks.first;
        }
      }
      // Handle <input> style (from database conversion)
      else if (questionText.contains('<input')) {
        activeInputField = 'input_0';
      }
    }
  }

  void _showReportDialog() {
    final reportTypes = {
      'Wrong answer': 'wrong_answer',
      'Typo in question': 'typo',
      'Unclear question': 'unclear_question',
      'Image issue': 'image_issue',
      'Other': 'other'
    };

    String? selectedDisplayType;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Report Issue', style: AppFontStyles.headingMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What\'s wrong with this question?',
                    style: AppFontStyles.bodyMedium),
                const SizedBox(height: 12),
                ...reportTypes.keys.map((displayType) => RadioListTile<String>(
                      title: Text(displayType, style: AppFontStyles.bodyMedium),
                      value: displayType,
                      groupValue: selectedDisplayType,
                      onChanged: (val) =>
                          setState(() => selectedDisplayType = val),
                      dense: true,
                    )),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Additional details (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Tell us more...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFontStyles.buttonSecondary),
            ),
            ElevatedButton(
              onPressed: selectedDisplayType != null
                  ? () {
                      final apiValue = reportTypes[selectedDisplayType]!;
                      _submitReport(apiValue, commentController.text);
                    }
                  : null,
              style: AppButtonStyles.primary,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(String reportType, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final response = await http.post(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/api/questions/${_getQuestionData(currentIndex)['id']}/report'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'report_type': reportType,
        'comment': comment,
      }),
    );

    Navigator.pop(context);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your report!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showVideoDialog() {
    final question = _getQuestionData(currentIndex);
    final skill = question['skill'];
    final videos = skill != null ? skill['videos'] : null;

    if (videos == null || videos is! List || videos.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school, color: AppColors.darkRed, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Help Videos', style: AppFontStyles.headingMedium),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.topic, size: 20, color: AppColors.darkRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        skill['skill'] ?? 'This Topic',
                        style: AppFontStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _playVideo(video['video_link'],
                              video['video_title'] ?? 'Help Video');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.darkRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.play_circle_filled,
                                  color: AppColors.darkRed,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video['video_title'] ??
                                          'Video ${index + 1}',
                                      style: AppFontStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (video['description'] != null &&
                                        video['description']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        video['description'],
                                        style: AppFontStyles.caption.copyWith(
                                          color: AppColors.darkGreyText,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.darkGreyText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppFontStyles.buttonSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _playVideo(String? videoLink, String videoTitle) async {
    if (videoLink == null || videoLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video link not available')),
      );
      return;
    }

    String fullUrl = videoLink;
    if (!videoLink.startsWith('http://') && !videoLink.startsWith('https://')) {
      fullUrl = '${AppConfig.apiBaseUrl}/$videoLink';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VideoPlayerScreen(
          videoUrl: fullUrl,
          title: videoTitle,
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Practice?', style: AppFontStyles.headingMedium),
        content: Text('Your progress will be lost if you exit now.',
            style: AppFontStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Stay', style: AppFontStyles.buttonSecondary),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BottomNavScreen()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Exit',
                style: AppFontStyles.buttonSecondary
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: LivesHeader inline (where flag was)
  Widget _buildHeader() {
    final progress = (currentIndex + 1) / widget.questions.length;
    final question = _getQuestionData(currentIndex);

    final skill = question['skill'];
    final videos = skill != null ? skill['videos'] : null;
    final hasVideo = videos != null && videos is List && videos.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close, size: 24, color: AppColors.darkGrey),
                onPressed: _showExitDialog,
              ),
              const Spacer(),
              // ✅ LivesHeader inline (replaces flag button)
              if (!unlimited)
                LivesHeader(
                  lives: lives,
                  maxLives: maxLives,
                  unlimited: unlimited,
                  nextLifeInSeconds: nextLifeInSeconds,
                  onTimerUpdate: (remaining) {
                    setState(() {
                      nextLifeInSeconds = remaining;
                    });
                  },
                ),
              const SizedBox(width: 8),
              if (hasVideo)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(Icons.play_circle_outline,
                          size: 28, color: AppColors.darkRed),
                      onPressed: _showVideoDialog,
                    ),
                    if (videos.length > 1)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              videos.length.toString(),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress * _progressAnimation.value,
                backgroundColor: AppColors.progressInactive,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.progressActive),
                minHeight: 6,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${currentIndex + 1} of ${widget.questions.length}',
            style:
                AppFontStyles.caption.copyWith(color: AppColors.darkGreyText),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _getQuestionData(currentIndex);
    final questionText = question['question'] ?? '';
    final hasImage = question['question_image'] != null;
    final typeId = question['type_id'];

    // Check question format
    final hasBlanks = QuestionBlankUtils.hasBlanks(questionText);
    final hasInputTags = questionText.contains('<input');

    // ✅ FIXED: For type 1 (MCQ), render as regular question even if it has <input> tags
    // Only type 2 (fill-in-blank) uses the special input layouts
    final shouldRenderAsRegular = typeId == 1 || (!hasBlanks && !hasInputTags);

    // For MCQ with <input> tags, replace them with underscores for display
    String displayText = questionText;
    if (typeId == 1 && hasInputTags) {
      displayText = questionText.replaceAll(RegExp(r'<input[^>]*>'), '_____');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (typeId == 2 && hasBlanks && !hasImage)
            Container(
              constraints: const BoxConstraints(minHeight: 300),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputInactive, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: CommonQuestionWidgets.buildQuestionWithBlanks(
                  questionText: questionText,
                  controllers: _blankControllers,
                  activeBlank: _activeBlank,
                  onBlankTap: (blankNum) {
                    setState(() => _activeBlank = blankNum);
                  },
                ),
              ),
            )
          else if (typeId == 2 && hasBlanks && hasImage)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonQuestionWidgets.buildQuestionCard(
                  child: CommonQuestionWidgets.buildQuestionWithBlanks(
                    questionText: questionText,
                    controllers: _blankControllers,
                    activeBlank: _activeBlank,
                    onBlankTap: (blankNum) {
                      setState(() => _activeBlank = blankNum);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CommonQuestionWidgets.buildNetworkImage(
                    imageUrl:
                        "${AppConfig.apiBaseUrl}/media${question['question_image']}",
                    maxHeight: 300,
                  ),
                ),
              ],
            )
          else if (typeId == 2 && hasInputTags && hasImage)
            _buildFIBWithImageLayout(question, questionText)
          else if (typeId == 2 && hasInputTags && !hasImage)
            _buildFIBWithoutImageLayout(questionText)
          else if (!hasImage)
            Container(
              constraints: const BoxConstraints(minHeight: 300),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputInactive, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _feedbackScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _feedbackScaleAnimation.value,
                      child: MathTextUtils.renderMathText(displayText),
                    );
                  },
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonQuestionWidgets.buildQuestionCard(
                  child: AnimatedBuilder(
                    animation: _feedbackScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _feedbackScaleAnimation.value,
                        child: MathTextUtils.renderMathText(displayText),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CommonQuestionWidgets.buildNetworkImage(
                    imageUrl:
                        "${AppConfig.apiBaseUrl}/media${question['question_image']}",
                    maxHeight: 300,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerArea() {
    final question = _getQuestionData(currentIndex);
    final questionText = question['question'] ?? '';
    final typeId = question['type_id'];

    // ✅ CRITICAL FIX: Type 1 is ALWAYS MCQ, even if question has <input> tags
    // Only type 2 is fill-in-blank
    final isFillInBlank = typeId == 2;

    print('🎯 Answer Area - typeId: $typeId, isFillInBlank: $isFillInBlank');
    print('🎯 Question text: $questionText');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isFillInBlank
          ? _buildFillInBlankAnswers()
          : _buildMultipleChoiceAnswers(question),
    );
  }

  Widget _buildMultipleChoiceAnswers(Map<String, dynamic> question) {
    final answers = <String>[];
    final answerImages = <String?>[];
    bool hasAnyImages = false;

    for (int i = 0; i < 4; i++) {
      final answer = question['answer$i'];
      final answerImage = question['answer${i}_image'];

      if (answer != null && answer.toString().isNotEmpty) {
        answers.add(answer.toString());
        answerImages.add(answerImage?.toString());
        if (answerImage != null && answerImage.toString().isNotEmpty) {
          hasAnyImages = true;
        }
      }
    }

    if (hasAnyImages) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: answers.length,
        itemBuilder: (context, index) => _buildImageAnswerOption(
          answers[index],
          answerImages[index],
          index,
        ),
      );
    } else {
      return Column(
        children: answers.map((answer) => _buildAnswerOption(answer)).toList(),
      );
    }
  }

  Widget _buildAnswerOption(String answer) {
    final isSelected = selectedAnswer == answer;
    final isCorrectAnswer = _isCorrectAnswer(answer);

    return CommonQuestionWidgets.buildAnswerOption(
      answer: answer,
      isSelected: isSelected,
      hasAnswered: hasAnswered,
      isCorrect: isCorrect,
      isCorrectAnswer: isCorrectAnswer,
      onTap: () => _selectAnswer(answer),
    );
  }

  Widget _buildImageAnswerOption(
      String answer, String? answerImage, int optionIndex) {
    final isSelected = selectedAnswer == answer;
    final isCorrectAnswer = _isCorrectAnswer(answer);

    return CommonQuestionWidgets.buildImageAnswerOption(
      answer: answer,
      answerImage: answerImage,
      apiBaseUrl: '${AppConfig.apiBaseUrl}/media',
      isSelected: isSelected,
      hasAnswered: hasAnswered,
      isCorrect: isCorrect,
      isCorrectAnswer: isCorrectAnswer,
      onTap: () => _selectAnswer(answer),
    );
  }

  // ✅ UPDATED: Removed progress boxes
  Widget _buildFIBWithImageLayout(
      Map<String, dynamic> question, String questionText) {
    // ✅ ADD THESE 5 LINES:
    String textToRender = questionText;
    if (question.containsKey('processed_html')) {
      textToRender = question['processed_html'];
      print('📝 Using processed HTML in FIBWithImage');
    }

    final inputMatches = RegExp(r'<input[^>]*>')
        .allMatches(textToRender); // ✅ CHANGE questionText to textToRender
    final inputCount = inputMatches.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            height: 250,
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CommonQuestionWidgets.buildNetworkImage(
                imageUrl:
                    "${AppConfig.apiBaseUrl}/media${question['question_image']}",
                maxHeight: 250,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkRed.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkRed.withOpacity(0.2)),
          ),
          child: _renderQuestionWithInlineAnswers(textToRender,
              inputCount), // ✅ CHANGE questionText to textToRender
        ),
      ],
    );
  }

  // ✅ UPDATED: Removed progress boxes
  Widget _buildFIBWithoutImageLayout(String questionText) {
    // ✅ ADD THESE 6 LINES:
    final currentQuestion = _getQuestionData(currentIndex);
    String textToRender = questionText;
    if (currentQuestion.containsKey('processed_html')) {
      textToRender = currentQuestion['processed_html'];
      print('📝 Using processed HTML in FIBWithoutImage');
    }

    final inputMatches = RegExp(r'<input[^>]*>')
        .allMatches(textToRender); // ✅ CHANGE questionText to textToRender
    final inputCount = inputMatches.length;

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputInactive, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: _renderQuestionWithInlineAnswers(
            textToRender, inputCount), // ✅ CHANGE questionText to textToRender
      ),
    );
  }

  Widget _renderQuestionWithInlineAnswers(String questionText, int inputCount) {
    final regex =
        RegExp(r'(\$\$.+?\$\$|<input[^>]*>|<br\s*/?>|<hr>)', dotAll: true);
    final matches = regex.allMatches(questionText);

    List<Widget> widgets = [];
    int currentIdx = 0;
    int inputCounter = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = questionText.substring(start, end);

      // Add text before the match
      if (start > currentIdx) {
        final text = questionText.substring(currentIdx, start);
        if (text.trim().isNotEmpty) {
          widgets.add(
            Text(
              text,
              style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black),
            ),
          );
        }
      }

      // Handle <input> tags
      if (matchedText.startsWith('<input')) {
        final inputId = 'input_$inputCounter';
        inputCounter++;

        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: _buildInlineAnswerField(inputId, inputCounter),
          ),
        );

        // Set first input as active
        if (activeInputField.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              activeInputField = inputId;
            });
          });
        }
      }
      // Handle line breaks
      else if (matchedText.contains('<br') || matchedText.contains('<hr')) {
        widgets.add(const SizedBox(height: 8));
      }

      currentIdx = end;
    }

    // Add trailing text
    if (currentIdx < questionText.length) {
      final trailing = questionText.substring(currentIdx).trim();
      if (trailing.isNotEmpty) {
        widgets.add(
          Text(
            trailing,
            style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black),
          ),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widgets,
    );
  }

  Widget _buildInlineAnswerField(String inputId, int fieldNumber) {
    final isActive = activeInputField == inputId;
    final hasAnswer = fillInAnswers[inputId]?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: () => setState(() => activeInputField = inputId),
      child: Container(
        constraints: const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.darkRed.withOpacity(0.1) : AppColors.white,
          border: Border.all(
            color: hasAnswer
                ? AppColors.success
                : isActive
                    ? AppColors.darkRed
                    : AppColors.inputInactive,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: hasAnswer
                    ? AppColors.success
                    : isActive
                        ? AppColors.darkRed
                        : AppColors.inputInactive,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  fieldNumber.toString(),
                  style: AppFontStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              fillInAnswers[inputId]?.isEmpty ?? true
                  ? '?'
                  : fillInAnswers[inputId]!,
              style: AppFontStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: hasAnswer
                    ? AppColors.success
                    : isActive
                        ? AppColors.darkRed
                        : AppColors.darkGreyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInputFieldNumber(String fieldId) {
    final parts = fieldId.split('_');
    if (parts.length >= 2) {
      final number = int.tryParse(parts[1]) ?? 0;
      return (number + 1).toString();
    }
    return '1';
  }

  Widget _buildKeypadButton(String value) {
    final isBackspace = value == '⌫';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isBackspace ? AppColors.tileGrey : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _handleKeypadInput(value),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputInactive, width: 0.5),
            ),
            child: Center(
              child: isBackspace
                  ? Icon(Icons.backspace_outlined,
                      size: 18, color: AppColors.darkGreyText)
                  : Text(
                      value,
                      style: AppFontStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeypadInput(String value) {
    if (activeInputField.isEmpty) return;

    setState(() {
      if (value == '⌫') {
        if (fillInAnswers[activeInputField]?.isNotEmpty == true) {
          fillInAnswers[activeInputField] = fillInAnswers[activeInputField]!
              .substring(0, fillInAnswers[activeInputField]!.length - 1);
        }
      } else {
        fillInAnswers[activeInputField] =
            (fillInAnswers[activeInputField] ?? '') + value;
      }
    });
  }

  Widget _buildFillInBlankAnswers() {
    final question = _getQuestionData(currentIndex);
    final questionText = question['question'] ?? '';

    print('🎯 Building Fill-in-blank answers');
    print(
        '🎯 Has blanks (new style): ${QuestionBlankUtils.hasBlanks(questionText)}');
    print('🎯 Active input field: $activeInputField');

    if (QuestionBlankUtils.hasBlanks(questionText)) {
      print('🎯 Using NEW style number pad');
      return CommonQuestionWidgets.buildNumberPad(
        onNumberPressed: (num) {
          if (_activeBlank != null &&
              _blankControllers.containsKey(_activeBlank)) {
            setState(() {
              _blankControllers[_activeBlank]!.text += num;
            });
          }
        },
        onBackspace: () {
          if (_activeBlank != null &&
              _blankControllers.containsKey(_activeBlank)) {
            final controller = _blankControllers[_activeBlank]!;
            if (controller.text.isNotEmpty) {
              setState(() {
                controller.text =
                    controller.text.substring(0, controller.text.length - 1);
              });
            }
          }
        },
        onClear: () {
          if (_activeBlank != null &&
              _blankControllers.containsKey(_activeBlank)) {
            setState(() {
              _blankControllers[_activeBlank]!.clear();
            });
          }
        },
      );
    }

    print('🎯 Using OLD style keypad');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputInactive),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeInputField.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.darkRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getInputFieldNumber(activeInputField),
                        style: AppFontStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Answer ${_getInputFieldNumber(activeInputField)}:',
                          style: AppFontStyles.caption.copyWith(
                            color: AppColors.darkGreyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          fillInAnswers[activeInputField]?.isEmpty ?? true
                              ? 'Tap numbers to enter'
                              : fillInAnswers[activeInputField]!,
                          style: AppFontStyles.bodyMedium.copyWith(
                            color: AppColors.darkRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        fillInAnswers[activeInputField] = '';
                      });
                    },
                    child: Text('Clear', style: AppFontStyles.caption),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: ['1', '2', '3', '⌫']
                    .map((value) => Expanded(child: _buildKeypadButton(value)))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['4', '5', '6', '+']
                    .map((value) => Expanded(child: _buildKeypadButton(value)))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['7', '8', '9', '-']
                    .map((value) => Expanded(child: _buildKeypadButton(value)))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['0', '.', '×', '÷']
                    .map((value) => Expanded(child: _buildKeypadButton(value)))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (!hasAnswered) {
      final question = _getQuestionData(currentIndex);
      final typeId = question['type_id'];
      final questionText = question['question'] ?? '';

      // ✅ FIXED: Check type_id, not question text format
      final isFillInBlank = typeId == 2;
      final hasBlanks = QuestionBlankUtils.hasBlanks(questionText);

      bool canSubmit = false;
      if (isFillInBlank) {
        // Type 2: Fill-in-blank
        if (hasBlanks) {
          // NEW [0] style - check if any blank has content
          canSubmit = _blankControllers.values
              .any((controller) => controller.text.trim().isNotEmpty);

          print('🎯 FIB NEW style - canSubmit: $canSubmit');
          print(
              '🎯 Blank controllers: ${_blankControllers.map((k, v) => MapEntry(k, v.text))}');
        } else {
          // OLD <input> style - check if any answer is filled
          canSubmit = fillInAnswers.values
              .any((answer) => answer.trim().isNotEmpty ?? false);

          print('🎯 FIB OLD style - canSubmit: $canSubmit');
          print('🎯 Fill in answers: $fillInAnswers');
        }
      } else {
        // Type 1: Multiple choice
        canSubmit = selectedAnswer != null;
        print('🎯 MCQ - canSubmit: $canSubmit, selected: $selectedAnswer');
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: canSubmit
              ? () {
                  print('🎯 Check Answer button pressed!');
                  _submitAnswer();
                }
              : null,
          style: canSubmit
              ? AppButtonStyles.questionPrimary
              : AppButtonStyles.questionPrimary.copyWith(
                  backgroundColor:
                      WidgetStateProperty.all(AppColors.darkGreyText),
                ),
          child: const Text('Check Answer'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: isCorrect
            ? AppButtonStyles.questionCorrect
            : AppButtonStyles.questionNext,
        child: Text(_getNextButtonText()),
      ),
    );
  }

  bool _isCorrectAnswer(String answer) {
    final question = _getQuestionData(currentIndex);
    final correctIndex = question['correct_answer'] ?? 0;
    final correctAnswer = question['answer$correctIndex'];
    return answer == correctAnswer;
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        hasAnswered = false;
        isCorrect = false;
        selectedAnswer = null;
        _clearBlankControllers();
      });

      _feedbackAnimationController.reset();
      _initializeQuestion();
      _progressAnimationController.reset();
      _progressAnimationController.forward();
    } else {
      _finishQuestions();
    }
  }

  String _getNextButtonText() {
    return isCorrect ? 'Correct! Continue' : 'Continue';
  }

  void _finishQuestions() {
    _sendResults();
  }

  Future<void> _sendResults() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final name = prefs.getString('first_name') ?? 'Student';
    final isSubscriberBool = prefs.getBool('is_subscriber') ?? false;

    Map<String, List<String?>> answerMap = {};
    for (int i = 0; i < submittedQuestionIds.length; i++) {
      final qid = submittedQuestionIds[i].toString();
      final ans = submittedAnswers[i];

      if (ans is List) {
        answerMap[qid] = List<String?>.from(ans);
      } else {
        answerMap[qid] = [ans.toString(), null, null, null];
      }
    }

    final String endpoint;
    final Map<String, dynamic> payload;

    if (widget.sessionType == 'kiasu_path') {
      endpoint = '${AppConfig.apiBaseUrl}/api/kiasu-path/submit';
      payload = {
        'test': widget.testId,
        'question_id': submittedQuestionIds,
        'answer': answerMap,
      };
    } else {
      endpoint = '${AppConfig.apiBaseUrl}/api/tracks/${widget.trackId}/answers';
      payload = {
        'test': widget.testId,
        'question_id': submittedQuestionIds,
        'answer': answerMap,
      };
    }

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final result = jsonDecode(response.body);

    if (result['code'] == 201 && result['questions'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionScreen(
            trackId: widget.trackId,
            testId: widget.testId,
            trackName: widget.trackName,
            questions: result['questions'],
            sessionType: widget.sessionType,
          ),
        ),
      );
    } else if (result['code'] == 206 || result['code'] == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultScreen(
            // ✅ Use new screen
            kudos: result['kudos_earned'] ?? result['kudos'] ?? 0,
            maxile: (result['maxile'] as num?)?.toDouble() ?? 0.0,
            maxileLevelName: result['maxile_level_name'] ?? 'Starting',
            percentage: (result['score'] as num?)?.toDouble() ??
                (result['percentage'] as num?)?.toDouble() ??
                0.0,
            name: name,
            token: token,
            isSubscriber: isSubscriberBool,
            durationInSeconds: DateTime.now().difference(startTime).inSeconds,
            encouragement: result['message'] ?? 'Great job!',
          ),
        ),
      );
    } else if (result['code'] == 205) {
      OutOfLivesModal.show(
        context,
        nextLifeInSeconds:
            result['next_life_in_seconds'] ?? _calculateNextLifeTime(),
        onGoBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottomNavScreen()),
          );
        },
      );
    } else if (result['code'] == 204) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            widget.sessionType == 'kiasu_path'
                ? 'Session Complete'
                : 'Track Completed',
            style: AppFontStyles.headingMedium,
          ),
          content: Text(
            widget.sessionType == 'kiasu_path'
                ? 'Great job! You\'ve completed this practice session.'
                : 'You have completed all questions for this track.',
            style: AppFontStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => BottomNavScreen()),
                  (route) => false,
                );
              },
              child: Text('OK', style: AppFontStyles.buttonSecondary),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    _progressAnimationController.dispose();
    _clearBlankControllers();
    super.dispose();
  }

  void _submitAnswer() {
    final question = _getQuestionData(currentIndex);
    final questionText = question['question'] ?? '';
    final typeId = question['type_id'];
    final questionId = question['id'];

    bool correct = false;
    dynamic userAnswer;

    // ✅ FIXED: Use type_id to determine question type
    if (typeId == 2) {
      // Type 2: Fill-in-blank
      final hasBlanks = QuestionBlankUtils.hasBlanks(questionText);

      if (hasBlanks) {
        // NEW [0] style blanks
        final userAnswers = <int, String>{};
        _blankControllers.forEach((key, controller) {
          userAnswers[key] = controller.text.trim();
        });

        correct = QuestionBlankUtils.validateAnswers(
          userAnswers,
          {
            'answer0': question['answer0']?.toString(),
            'answer1': question['answer1']?.toString(),
            'answer2': question['answer2']?.toString(),
            'answer3': question['answer3']?.toString(),
          },
        );

        final answerList = <String?>[null, null, null, null];
        for (int i = 0; i < 4; i++) {
          answerList[i] = userAnswers[i];
        }
        userAnswer = answerList;
      } else {
        // OLD <input> style
        final indexedAnswers = <int, String?>{};
        for (final entry in fillInAnswers.entries) {
          final keyParts = entry.key.split('_');
          if (keyParts.length >= 2) {
            final index = int.tryParse(keyParts.last);
            if (index != null) {
              indexedAnswers[index] = entry.value.trim();
            }
          }
        }

        final answerList = <String?>[null, null, null, null];
        for (int i = 0; i < 4; i++) {
          answerList[i] = indexedAnswers[i];
        }
        userAnswer = answerList;

        correct = false;
        for (int i = 0; i < 4; i++) {
          final correctAns = question['answer$i']?.toString().trim();
          final userAns = answerList[i]?.trim();
          if (correctAns != null &&
              correctAns.isNotEmpty &&
              userAns == correctAns) {
            correct = true;
            break;
          }
        }
      }
    } else {
      // Type 1: Multiple choice
      correct = _isCorrectAnswer(selectedAnswer ?? '');
      final options =
          List.generate(4, (i) => question['answer$i']?.toString() ?? '');
      final selectedIndex = options.indexOf(selectedAnswer ?? '');
      userAnswer = selectedIndex >= 0 ? selectedIndex.toString() : '0';
    }

    setState(() {
      hasAnswered = true;
      isCorrect = correct;
    });

    _feedbackAnimationController.forward().then((_) {
      _feedbackAnimationController.reverse();
    });

    if (!correct) {
      _reduceLives();
    }

    submittedQuestionIds.add(questionId);
    submittedAnswers.add(userAnswer);
  }

  String _getUserAnswerDisplay() {
    final question = _getQuestionData(currentIndex);
    final typeId = question['type_id'];

    if (typeId == 1 || typeId == 3) {
      // Multiple choice or True/False
      return selectedAnswer ?? 'No answer provided';
    } else if (typeId == 2) {
      // Fill-in-the-blank
      if (_blankControllers.isNotEmpty) {
        final answers = _blankControllers.values
            .map((c) => c.text)
            .where((text) => text.isNotEmpty)
            .toList();
        return answers.isNotEmpty ? answers.join(', ') : 'No answer provided';
      } else if (fillInAnswers.isNotEmpty) {
        final answers =
            fillInAnswers.values.where((v) => v.isNotEmpty).toList();
        return answers.isNotEmpty ? answers.join(', ') : 'No answer provided';
      }
    }
    return 'No answer provided';
  }

  Widget _buildFeedbackArea() {
  if (!hasAnswered) {
    return const SizedBox.shrink();
  }

  final question = _getQuestionData(currentIndex);
  final correctAnswerIndex = question['correct_answer'] as int? ?? 0; // Get the index
  final explanation = question['explanation']?.toString();
  final userAnswer = _getUserAnswerDisplay();
  final questionType = question['type_id'] as int? ?? 1; // ✅ Use type_id

  // ✅ FIXED: Get the correct answer text for MCQ
  String? correctOptionText;
  if (questionType == 1) {
    // For MCQ, get the actual text of the correct answer
    correctOptionText = question['answer$correctAnswerIndex']?.toString();
  }

  // For Type 2: Get all acceptable answers
  List<String>? acceptableAnswers;
  if (questionType == 2) {
    acceptableAnswers = [
      if (question['answer0']?.toString().isNotEmpty ?? false)
        question['answer0'].toString(),
      if (question['answer1']?.toString().isNotEmpty ?? false)
        question['answer1'].toString(),
      if (question['answer2']?.toString().isNotEmpty ?? false)
        question['answer2'].toString(),
      if (question['answer3']?.toString().isNotEmpty ?? false)
        question['answer3'].toString(),
    ];
  }

  return QuestionFeedbackWidget(
    isCorrect: isCorrect,
    userAnswer: userAnswer,
    correctAnswer: correctAnswerIndex.toString(), // Still pass the index for compatibility
    explanation: explanation,
    onReportIssue: _showReportDialog,
    questionType: questionType,
    correctOptionText: correctOptionText, // ✅ Now has the actual text!
    acceptableAnswers: acceptableAnswers,
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildQuestion(),
                    const SizedBox(height: 24),
                    _buildAnswerArea(),
                    _buildFeedbackArea(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const _VideoPlayerScreen({
    required this.videoUrl,
    required this.title,
  });

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error playing video', style: AppFontStyles.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: AppFontStyles.caption
                      .copyWith(color: AppColors.darkGreyText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: AppColors.darkRed)
            : _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load video',
                          style: AppFontStyles.headingMedium
                              .copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: AppFontStyles.bodyMedium
                              .copyWith(color: AppColors.darkGreyText),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : CircularProgressIndicator(color: AppColors.darkRed),
      ),
    );
  }
}
