import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_math_fork/flutter_math.dart';
import 'results_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_font_styles.dart';
import '../services/answer_service.dart';
import '../../config.dart';
import '../widgets/platform_network_image.dart'; // make sure this import is added
import 'bottom_nav_screen.dart';
import '../widgets/question_header.dart';
import '../widgets/num_input_pad.dart';
import '../theme/app_input_styles.dart';

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

class _QuestionScreenState extends State<QuestionScreen> {
  late DateTime startTime;
  int lives = 5;
  bool noLivesLeft = false;

  @override
  void initState() {
    super.initState();
    if (widget.questions.isNotEmpty && widget.questions[0]['type_id'] == 2) {
      activeInputId = 'input_0';
    }
    startTime = DateTime.now();
    _loadKudos();
    _loadState();
  }

  void _loadKudos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      kudos = prefs.getInt('game_level') ?? 0;
    });
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      kudos = prefs.getInt('game_level') ?? 0;
      lives = prefs.getInt('lives') ?? 5;
      noLivesLeft = lives < 1;
    });
  }

  Future<void> _reduceLife() async {
    final prefs = await SharedPreferences.getInstance();
    int lives = prefs.getInt('lives') ?? 5; // Default to 5 if not found
    if (lives > 0) {
      lives--;
      await prefs.setInt('lives', lives);
      debugPrint('Life lost. Remaining: $lives');
    }
  }

  List<int> submittedQuestionIds = [];
  List<dynamic> submittedAnswers = [];
  int currentIndex = 0;
  bool submitted = false;
  bool isCorrect = false;
  int attempts = 0;
  String? selectedOption;
  List<Map<String, dynamic>> collectedAnswers = [];
  Map<String, String> fibAnswers = {};
  String activeInputId = '';

  String getPrimaryLevel(String trackName) {
    final match = RegExp(r'Primary\s?(\d+)').firstMatch(trackName);
    return match != null ? match.group(1) ?? '' : '';
  }

  int kudos = 0;
  final double answerAreaHeight = 320.0;

  String preprocessLatex(String content) {
    final regex = RegExp(r'\\$\\$(.+?)\\$\\$', dotAll: true);
    return content.replaceAllMapped(regex, (match) {
      final latex = match.group(1);
      return '<tex>${latex ?? ''}</tex>';
    });
  }

  Widget renderHtmlWithLatex(String content) {
    final regex =
        RegExp(r'(\$\$.+?\$\$|<input[^>]*>|<br\s*/?>|<hr>)', dotAll: true);
    final matches = regex.allMatches(content);

    List<InlineSpan> spans = [];
    int currentIndex = 0;
    int inputCounter = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = content.substring(start, end);

      // Add plain text before the match
      if (start > currentIndex) {
        spans.add(TextSpan(
          text: content.substring(currentIndex, start),
          style: AppFontStyles.questionText,
        ));
      }

      if (matchedText.startsWith(r'$$') && matchedText.endsWith(r'$$')) {
        // LaTeX math
        final latex = matchedText.substring(2, matchedText.length - 2);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            latex,
            textStyle: const TextStyle(fontSize: 18),
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
                activeInputId = id;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: const BoxConstraints(minWidth: 60),
              decoration:
                  AppInputStyles.type2Place(isActive: activeInputId == id),
              child: Text(
                fibAnswers[id] ?? '',
                style: AppFontStyles.questionText,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
      } else if (matchedText == '<br>' ||
          matchedText == '<br/>' ||
          matchedText == '<br />') {
        spans.add(TextSpan(
          text: '\n',
          style: TextStyle(height: 1.5), // Adjust height as needed
        ));
      } else if (matchedText == '<hr>') {
        spans.add(WidgetSpan(
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 1,
              color: AppColors.darkGreyText),
        ));
      }

      currentIndex = end;
    }

    // Add any trailing text
    if (currentIndex < content.length) {
      final trailing = content.substring(currentIndex).trim();
      if (trailing.isNotEmpty) {
        spans.add(TextSpan(
          text: trailing,
          style: AppFontStyles.questionText,
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  void submitAnswer() {
    final question = widget.questions[currentIndex];
    final typeId = question['type_id'];
    final questionId = question['id'];
    final options = List.generate(4, (i) => question['answer$i'] ?? '');
    final index = options.indexOf(selectedOption ?? '');
    bool correct = false;
    dynamic userAnswer;
    int difficulty = question['difficulty_id'] ?? 1;

    if (typeId == 1) {
      correct = AnswerService.checkMCQAnswer(question, selectedOption);
      userAnswer = index >= 0
          ? index.toString()
          : '0'; // default to '0' or 'null' string
    } else if (typeId == 2) {
      final indexedInputs = <int, String?>{};

      for (final entry in fibAnswers.entries) {
        final keyParts = entry.key.split('_');
        if (keyParts.length < 2) continue;

        final index = int.tryParse(keyParts.last);
        if (index != null) {
          indexedInputs[index] = entry.value?.trim();
        }
      }

      final result = AnswerService.checkFIBNumbers(
        question,
        indexedInputs,
      );
      correct = result['isCorrect'];
      userAnswer = result['answers'];
    }

    if (correct) {
      if (attempts == 0) {
        kudos += (difficulty == 3)
            ? 4
            : (difficulty == 2)
                ? 3
                : 2;
      } else {
        kudos += 1;
      }
    }
    submittedQuestionIds.add(questionId);
    submittedAnswers.add(userAnswer);

    setState(() {
      submitted = true;
      isCorrect = correct;
      attempts++;
    });

    if (correct || attempts >= 2) {
      if (!correct && attempts >= 2) {
        _reduceLife();
      }
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        if (currentIndex == widget.questions.length - 1) {
          sendAnswersAndNavigate();
        } else {
          setState(() {
            currentIndex++;
            submitted = false;
            isCorrect = false;
            selectedOption = null;
            fibAnswers.clear();
            activeInputId = '';
            attempts = 0;

            // 👇 Ensure FIB input is activated on new question
            final nextQuestion = widget.questions[currentIndex];
            if (nextQuestion['type_id'] == 2) {
              activeInputId = 'input_0';
            }
          });
        }
      });
    }
  }

  void resetForRetry() {
    setState(() {
      submitted = false;
      isCorrect = false;
      selectedOption = null;
      fibAnswers.clear(); // Clear AFTER answer was already recorded
      activeInputId = ''; // Also clear this mapping to prevent stale keys
    });
  }

  Future<void> sendAnswersAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final name = prefs.getString('first_name') ?? 'Student';
    final isSubscriberBool = prefs.getBool('is_subscriber') ?? false;

    // Build the answers map in the required format
    Map<String, List<String?>> answerMap = {};
    for (int i = 0; i < submittedQuestionIds.length; i++) {
      final qid = submittedQuestionIds[i].toString();
      final ans = submittedAnswers[i];

      // Ensure every answer is a list of 4 elements (even for MCQ)
      if (ans is List) {
        answerMap[qid] = List<String?>.from(ans);
      } else {
        // Assume MCQ: store answer as a list with answer[0] = ans
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
      // Show a simple alert and pop back to main menu
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Track Completed'),
          content:
              const Text('You have completed all questions for this track.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => BottomNavScreen()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget buildMCQOption(String? optionText, int index) {
    bool isSelected = selectedOption == optionText;
    bool isRight = submitted && isCorrect && isSelected;
    bool isWrong = submitted && !isCorrect && isSelected;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (submitted && !isCorrect && attempts >= 1)
          ? null
          : () => setState(() => selectedOption = optionText),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRight
              ? Colors.green[50]
              : isWrong
                  ? Colors.red[50]
                  : AppColors.tileGrey,
          borderRadius: BorderRadius.circular(8.65),
          border: Border.all(
            color: isRight
                ? Colors.green
                : isWrong
                    ? Colors.red
                    : isSelected
                        ? AppColors.darkRed
                        : AppColors.lightGreyBackground,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: renderHtmlWithLatex(preprocessLatex(optionText ?? '')),
            ),
            if (isRight) const Icon(Icons.check_circle, color: Colors.green),
            if (isWrong) const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget buildNumInputPad() {
    return NumInputPad(
      userInput: fibAnswers[activeInputId] ?? '',
      onChanged: (updatedValue) {
        setState(() {
          fibAnswers[activeInputId] = updatedValue;
        });
      },
    );
  }

  Widget buildSubmitButton(bool isLast) {
    return ElevatedButton(
      onPressed: () {
        if (!submitted) {
          submitAnswer();
        } else if (isCorrect) {
          if (isLast) {
            sendAnswersAndNavigate();
          } else {
            setState(() {
              currentIndex++;
              submitted = false;
              isCorrect = false;
              selectedOption = null;
              fibAnswers.clear();
              activeInputId = '';
              attempts = 0;
            });
          }
        }
      },
      style: isCorrect
          ? AppButtonStyles.questionCorrect
          : AppButtonStyles.questionPrimary,
      child: Text(
        !submitted
            ? 'Submit'
            : isCorrect
                ? 'Correct!'
                : '',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildRetrySkipButtons(bool isLast) {
    return Column(
      children: [
        ElevatedButton(
          style: AppButtonStyles.questionTryAgain,
          onPressed: resetForRetry,
          child: const Text('Try Again!'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: AppButtonStyles.questionSkip,
          onPressed: () async {
            await _reduceLife();
            if (isLast) {
              sendAnswersAndNavigate();
            } else {
              setState(() {
                currentIndex++;
                submitted = false;
                isCorrect = false;
                selectedOption = null;
                fibAnswers.clear();
                activeInputId = '';
                attempts = 0;
              });
            }
          },
          child: const Text('Skip Question'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (noLivesLeft) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Text(
            'No lives left. Please try again later.',
            style: AppFontStyles.questionText,
          ),
        ),
      );
    }
    final q = widget.questions[currentIndex];
    final typeId = q['type_id'];
    final isLast = currentIndex == widget.questions.length - 1;

    Widget buildMCQGrid(Map<String, dynamic> question, bool isWide) {
      final options = question.entries
          .where(
              (entry) => entry.key.startsWith('answer') && entry.value != null)
          .toList();

      return SizedBox(
        height: answerAreaHeight,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 2 : 1.5, // adjust as needed
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: EdgeInsets.zero,
          children: options.map<Widget>((entry) {
            final index = int.tryParse(entry.key.replaceAll('answer', '')) ?? 0;
            return buildMCQOption(entry.value, index);
          }).toList(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final horizontalPadding = screenWidth < 400
            ? 8.0
            : (screenWidth > 800 ? screenWidth * 0.15 : 16.0);

        return Scaffold(
          backgroundColor: AppColors.white,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // 1. Header
                QuestionHeader(
                  currentIndex: currentIndex,
                  totalQuestions: widget.questions.length,
                  onClose: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BottomNavScreen()),
                  ),
                  videos: q['videos'],
                  skill: q['skill'],
                ),

                const SizedBox(height: 0),

                // 2. Main scrollable content: Question, Image, and Answer Input
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: renderHtmlWithLatex(
                              preprocessLatex(q['question'] ?? '')),
                        ),
                        const SizedBox(height: 12),

                        if (q['question_image'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final imageWidth = constraints.maxWidth;
                                return PlatformNetworkImage(
                                  imageUrl:
                                      "${AppConfig.apiBaseUrl}${q['question_image']}",
                                  width: imageWidth,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Answer area
                        typeId == 1
                            ? buildMCQGrid(q, isWide)
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: buildNumInputPad(),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Submit / Retry
                if (!submitted || isCorrect) buildSubmitButton(isLast),
                if (submitted && !isCorrect && attempts < 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: buildRetrySkipButtons(isLast),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
