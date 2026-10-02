import 'package:flutter/material.dart';

class AppColors {
  // Professional Trading Terminal Colors (TradingView / Zerodha Kite Style)
  static const Color primary = Color(0xFF2962FF); // TradingView Pro Blue
  static const Color primaryLight = Color(0xFF3872FF);
  static const Color primaryDark = Color(0xFF1E4BD8);
  static const Color secondary = Color(0xFF4B5563);
  static const Color accent = Color(0xFF00B4D8);

  // Trading Signal Colors (Clean Real-World Exchange Standards)
  static const Color bullGreen = Color(0xFF00C076); // Clean Terminal Green
  static const Color bullGreenDark = Color(0xFF00A364);
  static const Color bullGreenBg = Color(0x1A00C076);
  static const Color bullGreenGlow = Color(0x2600C076);

  static const Color bearRed = Color(0xFFFF3B53); // Clean Terminal Crimson
  static const Color bearRedDark = Color(0xFFE02840);
  static const Color bearRedBg = Color(0x1AFF3B53);
  static const Color bearRedGlow = Color(0x26FF3B53);

  // Terminal Dark Theme Backgrounds & Surfaces (TradingView Dark Mode)
  static const Color darkBg = Color(0xFF0B0E14); // Pure Deep Terminal Slate
  static const Color darkCard = Color(0xFF121722); // Trading Table Card
  static const Color darkCardHover = Color(0xFF171E2C);
  static const Color darkCardBorder = Color(0xFF1C2433); // Sharp Clean Gridline
  static const Color darkCardBorderGlow = Color(0xFF2A374D);
  static const Color darkInputBg = Color(0xFF0F141E);
  static const Color darkTextPrimary = Color(0xFFF0F3F8);
  static const Color darkTextSecondary = Color(0xFF9AA4B2);
  static const Color darkTextMuted = Color(0xFF627184);

  // Light Theme Backgrounds & Surfaces
  static const Color lightBg = Color(0xFFF4F6F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E6EC);
  static const Color lightInputBg = Color(0xFFEEF2F6);
  static const Color lightTextPrimary = Color(0xFF131722);
  static const Color lightTextSecondary = Color(0xFF434651);
  static const Color lightTextMuted = Color(0xFF787B86);

  // Badges & Meta
  static const Color gold = Color(0xFFF5A623);
  static const Color silver = Color(0xFF9AA4B2);
  static const Color bronze = Color(0xFFD97706);
  static const Color purple = Color(0xFF7C3AED);
  static const Color electricIndigo = Color(0xFF2962FF);
  static const Color cyberCyan = Color(0xFF00B4D8);
  static const Color neonGold = Color(0xFFF5A623);

  // Professional Terminal Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2962FF), Color(0xFF1E4BD8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bullGradient = LinearGradient(
    colors: [Color(0xFF00C076), Color(0xFF00A364)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bearGradient = LinearGradient(
    colors: [Color(0xFFFF3B53), Color(0xFFE02840)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF121722), Color(0xFF0F141E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
