import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// For web-specific imports
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

class PlatformNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;

  const PlatformNetworkImage({
    Key? key,
    required this.imageUrl,
    this.height = 200,
    this.width,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Register a unique view type for this image
      final viewId = imageUrl.hashCode.toString();
      // Only register once
      ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
        final image = html.ImageElement()
          ..src = imageUrl
          ..style.height = '${height}px'
          ..style.width = width != null ? '${width}px' : 'auto'
          ..style.objectFit = fit.name;
        return image;
      });

      return SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: HtmlElementView(viewType: viewId),
      );
    } else {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
      );
    }
  }
}