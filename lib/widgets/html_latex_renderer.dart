import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

class HtmlLatexRenderer {
  static final Map<String, TextEditingController> fibControllers = {};
  static final Map<int, String> answerKeyMap = {};

  static void resetState() {
    fibControllers.clear();
    answerKeyMap.clear();
  }

  static Map<int, String> getAnswers() {
    return Map.fromEntries(
      answerKeyMap.entries.map(
        (e) => MapEntry(e.key, fibControllers[e.value]?.text ?? ''),
      ),
    );
  }

  static Widget renderInlineHtml(String content) {
    final regex = RegExp(r'(\$\$.+?\$\$|<input[^>]*>|<br\s*/?>|<hr>)', dotAll: true);
    final matches = regex.allMatches(content);

    List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = content.substring(start, end);

      if (start > currentIndex) {
        spans.add(TextSpan(
          text: content.substring(currentIndex, start),
          style: AppFontStyles.questionText,
        ));
      }

      if (matchedText.startsWith(r'$$') && matchedText.endsWith(r'$$')) {
        final latex = matchedText.substring(2, matchedText.length - 2);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            latex,
            textStyle: const TextStyle(fontSize: 18),
          ),
        ));
      } else if (matchedText.startsWith('<input')) {
        final idMatch = RegExp(r'id\s*=\s*["\`]([^"\`]+)["\`]').firstMatch(matchedText);
        final rawId = idMatch?.group(1) ?? '';
        final id = rawId.isNotEmpty && !fibControllers.containsKey(rawId)
            ? rawId
            : 'input_${fibControllers.length}_${DateTime.now().microsecondsSinceEpoch}';

        if (!fibControllers.containsKey(id)) {
          fibControllers[id] = TextEditingController();
          answerKeyMap[answerKeyMap.length] = id;
        }

        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(
            width: 120,
            child: TextField(
              controller: fibControllers[id],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppFontStyles.questionText,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.tileGrey,
                hintText: 'Answer',
                hintStyle: AppFontStyles.inputPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.56),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            ),
          ),
        ));
      } else if (matchedText.contains('<br')) {
        spans.add(const WidgetSpan(
          child: SizedBox(height: 24),
        ));
      } else if (matchedText == '<hr>') {
        spans.add(WidgetSpan(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 1,
            color: AppColors.darkGreyText,
          ),
        ));
      }

      currentIndex = end;
    }

    // Add trailing text
    if (currentIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(currentIndex),
        style: AppFontStyles.questionText,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}