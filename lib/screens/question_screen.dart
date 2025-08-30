import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_math_fork/flutter_math.dart';
import 'results_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';
import '../widgets/platform_network_image.dart';
import 'bottom_nav_screen.dart';
import '../../config.dart';

class QuestionScreen extends StatefulWidget {
  final int trackId;
  final int testId;
  final String trackName;
  final List<dynamic> questions;

  const QuestionScreen({
    super.key,
    required this.trackId,
    required this.testId,
    required this.trackName,
    required this.questions,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with TickerProviderStateMixin {
  late DateTime startTime;
  int currentIndex = 0;
  int lives = 5;
  bool hasAnswered = false;
  bool isCorrect = false;
  String? selectedAnswer;
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
    _loadUserData();
    _resetQuestionState();
    _initializeQuestion();
  }

  void _setupAnimations() {
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _feedbackScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _feedbackAnimationController, curve: Curves.elasticOut),
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeOut),
    );
    
    _progressAnimationController.forward();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lives = prefs.getInt('lives') ?? 5;
    });
  }

  void _resetQuestionState() {
    currentIndex = 0;
    hasAnswered = false;
    isCorrect = false;
    selectedAnswer = null;
    fillInAnswers.clear();
    activeInputField = '';
    submittedQuestionIds.clear();
    submittedAnswers.clear();
  }

  void _initializeQuestion() {
    final currentQuestion = widget.questions[currentIndex];
    if (currentQuestion['type_id'] == 2) {
      activeInputField = 'input_0';
    }
  }

  void _showVideoDialog() {
    final question = widget.questions[currentIndex];
    final videos = question['videos'];
    
    if (videos == null || videos.toString().isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help Video', style: AppFontStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, size: 64, color: AppColors.darkRed),
            const SizedBox(height: 16),
            Text(
              'Watch this video to help understand the concept.',
              style: AppFontStyles.bodyMedium.copyWith(color: AppColors.darkGreyText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppFontStyles.buttonSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video player will be implemented')),
              );
            },
            style: AppButtonStyles.primary,
            child: const Text('Watch Video'),
          ),
        ],
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
            child: Text('Exit', style: AppFontStyles.buttonSecondary.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final progress = (currentIndex + 1) / widget.questions.length;
    final question = widget.questions[currentIndex];
    final hasVideo = question['videos'] != null && question['videos'].toString().isNotEmpty;
    
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, size: 24, color: AppColors.darkGrey),
                onPressed: _showExitDialog,
              ),
              if (hasVideo)
                IconButton(
                  icon: Icon(Icons.play_circle_outline, size: 28, color: AppColors.darkRed),
                  onPressed: _showVideoDialog,
                ),
              Row(
                children: List.generate(lives, (index) => 
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
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
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressActive),
                minHeight: 6,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${currentIndex + 1} of ${widget.questions.length}',
            style: AppFontStyles.caption.copyWith(color: AppColors.darkGreyText),
          ),
        ],
      ),
    );
  }

  Widget _renderQuestionText(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\$\$(.*?)\$\$|<input[^>]*>|<br\s*/?>|<hr\s*/?>|<hr>', dotAll: true);
    final matches = regex.allMatches(text);
    
    int lastEnd = 0;
    int inputCounter = 0;
    
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black),
        ));
      }
      
      final matchText = match.group(0) ?? '';
      
      if (matchText.startsWith(r'$$')) {
        final latex = match.group(1) ?? '';
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(latex, textStyle: AppFontStyles.bodyLarge),
        ));
      } else if (matchText.startsWith('<input')) {
        final inputId = 'input_$inputCounter';
        inputCounter++;
        
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () {
              setState(() {
                activeInputField = inputId;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: const BoxConstraints(minWidth: 60),
              decoration: BoxDecoration(
                color: activeInputField == inputId 
                  ? AppColors.inputActive.withOpacity(0.1) 
                  : AppColors.inputBackground,
                border: Border.all(
                  color: activeInputField == inputId 
                    ? AppColors.inputActive 
                    : AppColors.inputInactive,
                  width: activeInputField == inputId ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                fillInAnswers[inputId] ?? '____',
                style: AppFontStyles.bodyMedium.copyWith(
                  color: fillInAnswers[inputId]?.isEmpty ?? true 
                    ? AppColors.darkGreyText 
                    : AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
      } else if (matchText.contains('<br') || matchText.contains('<hr')) {
        spans.add(const TextSpan(text: '\n'));
      }
      
      lastEnd = match.end;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black),
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans.isEmpty 
        ? [TextSpan(text: text, style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black))]
        : spans),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildQuestion() {
    final question = widget.questions[currentIndex];
    final questionText = question['question'] ?? '';
    final hasImage = question['question_image'] != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: hasImage 
        ? _buildQuestionWithImage(question, questionText)
        : _buildQuestionWithoutImage(questionText),
    );
  }

  Widget _buildQuestionWithImage(Map<String, dynamic> question, String questionText) {
    final typeId = question['type_id'];
    
    if (typeId == 2) {
      return _buildFIBWithImageLayout(question, questionText);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputInactive),
            ),
            child: renderHtmlWithLatex(questionText),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: AppColors.white,
                width: double.infinity,
                child: PlatformNetworkImage(
                  imageUrl: "${AppConfig.apiBaseUrl}${question['question_image']}",
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFIBWithImageLayout(Map<String, dynamic> question, String questionText) {
    final inputMatches = RegExp(r'<input[^>]*>').allMatches(questionText);
    final inputCount = inputMatches.length;
    
    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
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
            child: PlatformNetworkImage(
              imageUrl: "${AppConfig.apiBaseUrl}${question['question_image']}",
              width: double.infinity,
              fit: BoxFit.contain,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderQuestionWithInlineAnswers(questionText, inputCount),
              
              if (inputCount > 1) ...[
                const SizedBox(height: 16),
                _buildAnswerProgress(inputCount),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFIBWithoutImageLayout(String questionText) {
    final inputMatches = RegExp(r'<input[^>]*>').allMatches(questionText);
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _renderQuestionWithInlineAnswers(questionText, inputCount),
          
          if (inputCount > 1) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkRed.withOpacity(0.2)),
              ),
              child: _buildAnswerProgress(inputCount),
            ),
          ],
        ],
      ),
    );
  }

  Widget _renderQuestionWithInlineAnswers(String questionText, int inputCount) {
    final regex = RegExp(r'(\$\$.+?\$\$|<input[^>]*>|<br\s*/?>|<hr>)', dotAll: true);
    final matches = regex.allMatches(questionText);

    List<Widget> widgets = [];
    int currentIndex = 0;
    int inputCounter = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = questionText.substring(start, end);

      if (start > currentIndex) {
        final text = questionText.substring(currentIndex, start);
        if (text.trim().isNotEmpty) {
          widgets.add(
            Text(
              text,
              style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black),
            ),
          );
        }
      }

      if (matchedText.startsWith('<input')) {
        final inputId = 'input_$inputCounter';
        inputCounter++;
        
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: _buildInlineAnswerField(inputId, inputCounter),
          ),
        );
        
        if (activeInputField.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              activeInputField = inputId;
            });
          });
        }
      } else if (matchedText.contains('<br') || matchedText.contains('<hr')) {
        widgets.add(const SizedBox(height: 8));
      }

      currentIndex = end;
    }

    if (currentIndex < questionText.length) {
      final trailing = questionText.substring(currentIndex).trim();
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
          color: isActive 
            ? AppColors.darkRed.withOpacity(0.1)
            : AppColors.white,
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

  Widget _buildAnswerProgress(int totalFields) {
    final completedCount = fillInAnswers.values.where((v) => v.isNotEmpty).length;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputInactive),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 16,
            color: AppColors.darkGreyText,
          ),
          const SizedBox(width: 8),
          Text(
            'Progress: $completedCount/$totalFields answers',
            style: AppFontStyles.caption.copyWith(
              color: AppColors.darkGreyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (completedCount == totalFields)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Complete!',
                style: AppFontStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionWithoutImage(String questionText) {
    final question = widget.questions[currentIndex];
    final typeId = question['type_id'];
    
    if (typeId == 2) {
      // FIB question without image - use clean layout similar to FIB with image
      return _buildFIBWithoutImageLayout(questionText);
    } else {
      // MCQ question without image - use existing layout
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
          child: AnimatedBuilder(
            animation: _feedbackScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _feedbackScaleAnimation.value,
                child: renderHtmlWithLatex(questionText),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildAnswerArea() {
    final question = widget.questions[currentIndex];
    final typeId = question['type_id'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: typeId == 1 ? _buildMultipleChoiceAnswers(question) : _buildFillInBlankAnswers(question),
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
      // Grid layout for answers with images
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
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
      // Vertical stack layout for text-only answers
      return Column(
        children: answers.map((answer) => _buildAnswerOption(answer)).toList(),
      );
    }
  }

  Widget _buildAnswerOption(String answer) {
    final isSelected = selectedAnswer == answer;
    final showResult = hasAnswered;
    final isCorrectAnswer = _isCorrectAnswer(answer);
    
    Color backgroundColor = AppColors.white;
    Color borderColor = AppColors.inputInactive;
    
    if (showResult && isSelected) {
      backgroundColor = isCorrect ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
    } else if (showResult && isCorrectAnswer && !isCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
    } else if (isSelected) {
      backgroundColor = AppColors.darkRed.withOpacity(0.1);
      borderColor = AppColors.darkRed;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasAnswered ? null : () => _selectAnswer(answer),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Expanded(child: _renderQuestionText(answer)),
                if (showResult && isSelected && isCorrect)
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
                if (showResult && isSelected && !isCorrect)
                  Icon(Icons.cancel, color: AppColors.error, size: 24),
                if (showResult && isCorrectAnswer && !isCorrect && !isSelected)
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageAnswerOption(String answer, String? answerImage, int optionIndex) {
    final isSelected = selectedAnswer == answer;
    final showResult = hasAnswered;
    final isCorrectAnswer = _isCorrectAnswer(answer);
    
    Color backgroundColor = AppColors.white;
    Color borderColor = AppColors.inputInactive;
    
    if (showResult && isSelected) {
      backgroundColor = isCorrect ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
    } else if (showResult && isCorrectAnswer && !isCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
    } else if (isSelected) {
      backgroundColor = AppColors.darkRed.withOpacity(0.1);
      borderColor = AppColors.darkRed;
    }
    
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasAnswered ? null : () => _selectAnswer(answer),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            children: [
              // Image section
              if (answerImage != null && answerImage.isNotEmpty)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      child: PlatformNetworkImage(
                        imageUrl: "${AppConfig.apiBaseUrl}$answerImage",
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              
              // Text/Label section
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            answer,
                            style: AppFontStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (showResult && isSelected && isCorrect)
                        Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      if (showResult && isSelected && !isCorrect)
                        Icon(Icons.cancel, color: AppColors.error, size: 20),
                      if (showResult && isCorrectAnswer && !isCorrect && !isSelected)
                        Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFillInBlankAnswers(Map<String, dynamic> question) {
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
                children: ['1', '2', '3', '⌫'].map((value) => 
                  Expanded(child: _buildKeypadButton(value))
                ).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['4', '5', '6', ':'].map((value) => 
                  Expanded(child: _buildKeypadButton(value))
                ).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['7', '8', '9', '.'].map((value) => 
                  Expanded(child: _buildKeypadButton(value))
                ).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildKeypadButton('0')),
                  const Expanded(child: SizedBox()),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
                ? Icon(Icons.backspace_outlined, size: 18, color: AppColors.darkGreyText)
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

  String _getInputFieldNumber(String fieldId) {
    final parts = fieldId.split('_');
    if (parts.length >= 2) {
      final number = int.tryParse(parts[1]) ?? 0;
      return (number + 1).toString();
    }
    return '1';
  }

  Widget renderHtmlWithLatex(String content) {
    final regex = RegExp(r'(\$\$.+?\$\$|<input[^>]*>|<br\s*/?>|<hr>)', dotAll: true);
    final matches = regex.allMatches(content);

    List<InlineSpan> spans = [];
    int currentIndex = 0;
    int inputCounter = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = content.substring(start, end);

      if (start > currentIndex) {
        spans.add(TextSpan(
          text: content.substring(currentIndex, start),
          style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black),
        ));
      }

      if (matchedText.startsWith(r'$') && matchedText.endsWith(r'$')) {
        final latex = matchedText.substring(2, matchedText.length - 2);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            latex,
            textStyle: AppFontStyles.bodyLarge,
          ),
        ));
      } else if (matchedText.startsWith('<input')) {
        final id = 'input_$inputCounter';
        inputCounter++;

        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () {
              setState(() {
                activeInputField = id;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: const BoxConstraints(minWidth: 60),
              decoration: BoxDecoration(
                color: activeInputField == id 
                  ? AppColors.inputActive.withOpacity(0.1) 
                  : AppColors.white,
                border: Border.all(
                  color: activeInputField == id 
                    ? AppColors.inputActive 
                    : AppColors.inputActive.withOpacity(0.3),
                  width: activeInputField == id ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                fillInAnswers[id]?.isEmpty ?? true 
                  ? '____' 
                  : fillInAnswers[id]!,
                style: AppFontStyles.bodyMedium.copyWith(
                  color: fillInAnswers[id]?.isEmpty ?? true 
                    ? AppColors.darkGreyText
                    : AppColors.darkRed,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
      } else if (matchedText == '<br>' || matchedText == '<br/>' || matchedText == '<br />') {
        spans.add(const TextSpan(text: '\n'));
      } else if (matchedText == '<hr>') {
        spans.add(const TextSpan(text: '\n'));
      }

      currentIndex = end;
    }

    if (currentIndex < content.length) {
      final trailing = content.substring(currentIndex).trim();
      if (trailing.isNotEmpty) {
        spans.add(TextSpan(
          text: trailing,
          style: AppFontStyles.bodyLarge.copyWith(color: AppColors.black),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildActionButton() {
    if (!hasAnswered) {
      final question = widget.questions[currentIndex];
      final typeId = question['type_id'];
      
      bool canSubmit = false;
      if (typeId == 1) {
        canSubmit = selectedAnswer != null;
      } else if (typeId == 2) {
        canSubmit = fillInAnswers.values.any((answer) => answer.isNotEmpty);
      }
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: canSubmit ? _submitAnswer : null,
          style: canSubmit 
            ? AppButtonStyles.questionPrimary 
            : AppButtonStyles.questionPrimary.copyWith(
                backgroundColor: MaterialStateProperty.all(AppColors.darkGreyText),
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
        style: isCorrect ? AppButtonStyles.questionCorrect : AppButtonStyles.questionNext,
        child: Text(_getNextButtonText()),
      ),
    );
  }

  bool _isCorrectAnswer(String answer) {
    final question = widget.questions[currentIndex];
    final correctIndex = question['correct_answer'] ?? 0;
    final correctAnswer = question['answer$correctIndex'];
    return answer == correctAnswer;
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _handleKeypadInput(String value) {
    if (activeInputField.isEmpty) return;
    
    setState(() {
      if (value == '⌫') {
        if (fillInAnswers[activeInputField]?.isNotEmpty == true) {
          fillInAnswers[activeInputField] = fillInAnswers[activeInputField]!.substring(
            0, fillInAnswers[activeInputField]!.length - 1
          );
        }
      } else {
        fillInAnswers[activeInputField] = (fillInAnswers[activeInputField] ?? '') + value;
      }
    });
  }

  void _submitAnswer() {
    final question = widget.questions[currentIndex];
    final typeId = question['type_id'];
    final questionId = question['id'];
    
    bool correct = false;
    dynamic userAnswer;
    
    if (typeId == 1) {
      correct = _isCorrectAnswer(selectedAnswer ?? '');
      final options = List.generate(4, (i) => question['answer$i']?.toString() ?? '');
      final selectedIndex = options.indexOf(selectedAnswer ?? '');
      userAnswer = selectedIndex >= 0 ? selectedIndex.toString() : '0';
    } else if (typeId == 2) {
      final indexedAnswers = <int, String?>{};
      for (final entry in fillInAnswers.entries) {
        final keyParts = entry.key.split('_');
        if (keyParts.length >= 2) {
          final index = int.tryParse(keyParts.last);
          if (index != null) {
            indexedAnswers[index] = entry.value?.trim();
          }
        }
      }
      
      final answerList = <String?>[null, null, null, null];
      for (int i = 0; i < 4; i++) {
        answerList[i] = indexedAnswers[i];
      }
      userAnswer = answerList;
      
      correct = fillInAnswers.values.any((answer) => answer.isNotEmpty);
    }
    
    setState(() {
      hasAnswered = true;
      isCorrect = correct;
    });
    
    if (isCorrect) {
      _feedbackAnimationController.forward();
    } else {
      _reduceLives();
    }
    
    submittedQuestionIds.add(questionId);
    if (typeId == 1) {
      submittedAnswers.add([userAnswer, null, null, null]);
    } else {
      submittedAnswers.add(userAnswer);
    }
  }

  void _reduceLives() async {
    final prefs = await SharedPreferences.getInstance();
    final currentLives = prefs.getInt('lives') ?? 5;
    if (currentLives > 0) {
      await prefs.setInt('lives', currentLives - 1);
      setState(() {
        lives = currentLives - 1;
      });
    }
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        hasAnswered = false;
        isCorrect = false;
        selectedAnswer = null;
        fillInAnswers.clear();
        activeInputField = '';
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

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/test/answers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'test': widget.testId,
        'question_id': submittedQuestionIds,
        'answer': answerMap,
      }),
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
          ),
        ),
      );
    } else if (result['code'] == 206) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            kudos: result['kudos'] ?? 0,
            maxile: (result['maxile'] as num?)?.toDouble() ?? 0.0,
            percentage: (result['percentage'] as num?)?.toDouble() ?? 0.0,
            name: name,
            token: token,
            isSubscriber: isSubscriberBool,
            durationInSeconds: DateTime.now().difference(startTime).inSeconds,
            encouragement: result['message'] ?? 'Keep it up!',
          ),
        ),
      );
    } else if (result['code'] == 204) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Track Completed', style: AppFontStyles.headingMedium),
          content: Text('You have completed all questions for this track.', 
                       style: AppFontStyles.bodyMedium),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (lives <= 0) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Out of Lives!',
                style: AppFontStyles.headingLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Take a break and come back later.',
                style: AppFontStyles.bodyMedium.copyWith(color: AppColors.darkGreyText),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => BottomNavScreen()),
                ),
                style: AppButtonStyles.primary,
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

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
                    _buildQuestion(),
                    const SizedBox(height: 24),
                    _buildAnswerArea(),
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