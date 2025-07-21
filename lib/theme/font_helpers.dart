import 'package:flutter/material.dart';

TextStyle responsiveTextStyle(BuildContext context, TextStyle baseStyle,
    {double minWidth = 320, double maxWidth = 600}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final baseFontSize = baseStyle.fontSize ?? 14;

  double scale;

  if (screenWidth <= minWidth) {
    scale = 0.75; // smaller screen → shrink
  } else if (screenWidth >= maxWidth) {
    scale = 1.2; // larger screen → increase
  } else {
    // interpolate between 0.75 and 1.2
    final t = (screenWidth - minWidth) / (maxWidth - minWidth);
    scale = 0.75 + (1.2 - 0.75) * t;
  }

  return baseStyle.copyWith(fontSize: baseFontSize * scale);
}

