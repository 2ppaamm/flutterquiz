import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

/// Utility class for rendering text with LaTeX math support
class MathTextUtils {
  /// Check if content looks like actual math (not just currency or numbers)
  static bool looksLikeMath(String content) {
    final mathIndicators = RegExp(
      r'[+\-*/=<>^_\\{}[\]()]|\\[a-zA-Z]+|frac|sqrt|sum|int|times|div|cdot'
    );
    return mathIndicators.hasMatch(content);
  }

  /// Render text with LaTeX math support
  /// Supports $$...$$ for display math, $...$ for inline math
  /// Also handles <br>, <hr> tags
  static Widget renderMathText(
    String content, {
    TextStyle? textStyle,
    TextStyle? mathStyle,
  }) {
    final defaultTextStyle = textStyle ?? 
      (AppFontStyles.bodyLarge.copyWith(color: AppColors.black) ??
        TextStyle(fontSize: 18, color: AppColors.black));
    final defaultMathStyle = mathStyle ?? 
      (AppFontStyles.bodyLarge ?? TextStyle(fontSize: 18));

    // Strict regex to avoid treating currency as LaTeX
    final regex = RegExp(
      r'(\$\$[^\$]+\$\$|\$[^\s\$][^\$]*[^\s\$]\$|\\\[[^\]]+\\\]|\\\([^\)]+\\\)|<br\s*/?>|<hr>)',
      dotAll: true,
    );
    final matches = regex.allMatches(content);

    List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = content.substring(start, end);

      // Add plain text before the match
      if (start > currentIndex) {
        spans.add(TextSpan(
          text: content.substring(currentIndex, start),
          style: defaultTextStyle,
        ));
      }

      // Handle display math: $$...$$ or \[...\]
      if ((matchedText.startsWith(r'$$') &&
              matchedText.endsWith(r'$$') &&
              matchedText.length > 4) ||
          (matchedText.startsWith(r'\[') &&
              matchedText.endsWith(r'\]') &&
              matchedText.length > 4)) {
        String latex;
        if (matchedText.startsWith(r'$$')) {
          latex = matchedText.substring(2, matchedText.length - 2).trim();
        } else {
          latex = matchedText.substring(2, matchedText.length - 2).trim();
        }

        if (looksLikeMath(latex)) {
          try {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(latex, textStyle: defaultMathStyle),
            ));
          } catch (e) {
            print('LaTeX render error (display): $e');
            spans.add(TextSpan(text: matchedText, style: defaultTextStyle));
          }
        } else {
          spans.add(TextSpan(text: matchedText, style: defaultTextStyle));
        }
      }
      // Handle inline math: $...$ or \(...\)
      else if ((matchedText.startsWith(r'$') &&
              matchedText.endsWith(r'$') &&
              matchedText.length > 2) ||
          (matchedText.startsWith(r'\(') &&
              matchedText.endsWith(r'\)') &&
              matchedText.length > 4)) {
        String latex;
        if (matchedText.startsWith(r'$')) {
          latex = matchedText.substring(1, matchedText.length - 1).trim();
        } else {
          latex = matchedText.substring(2, matchedText.length - 2).trim();
        }

        if (looksLikeMath(latex)) {
          try {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(latex, textStyle: defaultMathStyle),
            ));
          } catch (e) {
            print('LaTeX render error (inline): $e');
            spans.add(TextSpan(text: matchedText, style: defaultTextStyle));
          }
        } else {
          spans.add(TextSpan(text: matchedText, style: defaultTextStyle));
        }
      }
      // Handle line breaks
      else if (matchedText == '<br>' ||
          matchedText == '<br/>' ||
          matchedText == '<br />') {
        spans.add(const TextSpan(text: '\n'));
      } else if (matchedText == '<hr>') {
        spans.add(const TextSpan(text: '\n'));
      }

      currentIndex = end;
    }

    // Add remaining text
    if (currentIndex < content.length) {
      final trailing = content.substring(currentIndex).trim();
      if (trailing.isNotEmpty) {
        spans.add(TextSpan(text: trailing, style: defaultTextStyle));
      }
    }

    return RichText(
      text: TextSpan(
        children: spans.isEmpty ? [TextSpan(text: content)] : spans,
      ),
    );
  }

  /// Build option/answer text with LaTeX support
  static Widget buildOptionText(
    String text, {
    double fontSize = 16,
    bool isBold = false,
    Color? color,
  }) {
    final textColor = color ?? AppColors.darkText;
    final fontWeight = isBold ? FontWeight.w600 : FontWeight.normal;

    // Check if text contains any LaTeX delimiters
    if (!text.contains(r'$') &&
        !text.contains(r'\(') &&
        !text.contains(r'\[')) {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      );
    }

    // Strict regex for options
    final regex = RegExp(
      r'\$\$([^\$]+)\$\$|\$([^\s\$][^\$]*[^\s\$])\$|\\\[([^\]]+)\\\]|\\\(([^\)]+)\\\)'
    );
    final parts = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the math
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ));
      }

      final mathContent = (match.group(1) ??
              match.group(2) ??
              match.group(3) ??
              match.group(4) ??
              '')
          .trim();

      // Only render as math if it looks like math
      if (looksLikeMath(mathContent)) {
        try {
          parts.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              mathContent,
              textStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ));
        } catch (e) {
          print('LaTeX render error: $e');
          parts.add(TextSpan(
            text: match.group(0),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ));
        }
      } else {
        // Not math, keep as plain text
        parts.add(TextSpan(
          text: match.group(0),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: parts.isEmpty ? [TextSpan(text: text)] : parts,
      ),
    );
  }
}