import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF0F111A);
  static const Color cardDark = Color(0xFF1A1D2D);
  static const Color accentNeon = Color(0xFF00F0FF);
  static const Color accentPink = Color(0xFFFF007F);
  static const Color textMain = Colors.white;
  static const Color textMuted = Color(0xFF6E7490);
  
  static const Color danger = Color(0xFFFF3366);
  static const Color warning = Color(0xFFFFB300);
  static const Color success = Color(0xFF00E676);

  static List<BoxShadow> get shadow3D => [
    BoxShadow(color: Colors.black.withOpacity(0.6), offset: const Offset(8, 8), blurRadius: 20),
    BoxShadow(color: Colors.white.withOpacity(0.03), offset: const Offset(-5, -5), blurRadius: 15),
  ];

  static List<BoxShadow> get shadowNeon => [
    BoxShadow(color: accentNeon.withOpacity(0.4), offset: const Offset(0, 8), blurRadius: 25),
  ];
}
