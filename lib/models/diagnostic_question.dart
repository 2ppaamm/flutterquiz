import '../../config.dart';

class DiagnosticQuestion {
  final int id;
  final String question;
  final String? imageUrl;
  final List<DiagnosticOption> options;
  final int correctOptionId;

  DiagnosticQuestion({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctOptionId,
  });

  // Helper function to build full image URL
  static String? _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Otherwise prepend base URL with /media/ for CORS
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '${AppConfig.apiBaseUrl}/media/$cleanPath';
  }

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) {
    try {
      // The question data is nested under 'question' key
      final questionData = json['question'] as Map<String, dynamic>?;
      
      if (questionData == null) {
        throw Exception('Question data is null');
      }

      // Build options from answer0, answer1, answer2, answer3
      final options = <DiagnosticOption>[];
      for (int i = 0; i < 4; i++) {
        final answerKey = 'answer$i';
        final imageKey = '${answerKey}_image';
        
        final answerText = questionData[answerKey] as String?;
        final answerImage = questionData[imageKey] as String?;
        
        // ✅ Add option if text OR image exists (not just text)
        final hasText = answerText != null && answerText.isNotEmpty;
        final hasImage = answerImage != null && answerImage.isNotEmpty;
        
        if (hasText || hasImage) {
          options.add(DiagnosticOption(
            id: i,
            text: answerText ?? '', // Empty string if null
            imageUrl: _buildImageUrl(answerImage),
          ));
        }
      }

      // Get correct answer index with null check
      final correctAnswerValue = questionData['correct_answer'];
      if (correctAnswerValue == null) {
        throw Exception('correct_answer is null for question ${questionData['id']}');
      }
      final correctAnswerIndex = correctAnswerValue as int;

      // Get question ID with null check
      final questionId = questionData['id'];
      if (questionId == null) {
        throw Exception('Question id is null');
      }

      // Get question text with null check
      final questionText = questionData['question'];
      if (questionText == null || questionText.toString().isEmpty) {
        throw Exception('Question text is null or empty');
      }

      return DiagnosticQuestion(
        id: questionId as int,
        question: questionText as String,
        imageUrl: _buildImageUrl(questionData['question_image'] as String?),
        options: options,
        correctOptionId: correctAnswerIndex,
      );
    } catch (e) {
      print('❌ Error parsing question: $e');
      print('   JSON data: $json');
      rethrow;
    }
  }
}

class DiagnosticOption {
  final int id;
  final String text;
  final String? imageUrl;

  DiagnosticOption({
    required this.id,
    required this.text,
    this.imageUrl,
  });
}

class DiagnosticAnswer {
  final int questionId;
  final int selectedOptionId;
  final bool isCorrect;
  final DateTime answeredAt;

  DiagnosticAnswer({
    required this.questionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.answeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_option_id': selectedOptionId,
      'is_correct': isCorrect,
      'answered_at': answeredAt.toIso8601String(),
    };
  }
}