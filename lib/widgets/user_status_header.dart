// lib/widgets/user_status_header.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

class UserStatusHeader extends StatefulWidget {
  const UserStatusHeader({super.key});

  @override
  State<UserStatusHeader> createState() => _UserStatusHeaderState();
}

class _UserStatusHeaderState extends State<UserStatusHeader> {
  int _maxileLevel = 0;
  int _gameLevel = 0;
  int _lives = 0;
  int _level = 0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing values or apply defaults
    final savedMaxile = prefs.getInt('maxile_level') ?? 0;
    final savedGame = prefs.getInt('game_level') ?? 0;

    // Lives: default to 5 only if key not present at all
    int? savedLives = prefs.getInt('lives');
    if (savedLives == null) {
      savedLives = 5;
      await prefs.setInt('lives', savedLives);
    }

    setState(() {
      _maxileLevel = savedMaxile;
      _gameLevel = savedGame;
      _lives = savedLives!;
      _level = (_maxileLevel ~/ 100).clamp(1, 12);
    });

    // Register HTML image
    final imageUrl = '${AppConfig.apiBaseUrl}/images/houses/p$_level.png';
    ui.platformViewRegistry.registerViewFactory(
      'levelHouseImage',
      (int viewId) => html.ImageElement()
        ..src = imageUrl
        ..style.width = '28px'
        ..style.height = '28px'
        ..style.objectFit = 'contain'
        ..alt = 'Level Icon',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Level icon as HtmlElementView
        const SizedBox(
          width: 28,
          height: 28,
          child: HtmlElementView(viewType: 'levelHouseImage'),
        ),

        // Game level with icon
        Row(
          children: [
            Image.asset('assets/kudo.png', width: 24, height: 24),
            const SizedBox(width: 4),
            Text('$_gameLevel', style: const TextStyle(color: Colors.blue)),
          ],
        ),

        // Maxile level with icon
        Row(
          children: [
            Icon(Icons.hexagon, color: Colors.blue[300]),
            const SizedBox(width: 4),
            Text('$_maxileLevel', style: const TextStyle(color: Colors.black)),
          ],
        ),

        // Lives with heart icon
        Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 4),
            Text('$_lives', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ],
    );
  }
}
