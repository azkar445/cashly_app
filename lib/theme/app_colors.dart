import 'package:flutter/material.dart';

// Warna yang SELALU sama di dark & light
class StaticColors {
  static const Color headerDeep   = Color(0xFF060E2B);
  static const Color headerNavy   = Color(0xFF0B1F5C);
  static const Color headerBlue   = Color(0xFF1540A8);
  static const Color headerBright = Color(0xFF2563EB);
  static const Color glowBlue     = Color(0xFF60A5FA);
  static const Color accentCyan   = Color(0xFF38BDF8);

  static const Color incomeGreen  = Color(0xFF22C55E);
  static const Color incomeDeep   = Color(0xFF16A34A);
  static const Color incomeLight  = Color(0xFFDCFCE7);

  static const Color expenseRed   = Color(0xFFEF4444);
  static const Color expenseDeep  = Color(0xFFDC2626);
  static const Color expenseLight = Color(0xFFFFE4E4);

  static const Color white        = Colors.white;
  static const Color white70      = Color(0xB3FFFFFF);
}

// Warna yang BERUBAH sesuai tema
class DynamicColors {
  final bool isDark;
  const DynamicColors(this.isDark);

  Color get bgPage     => isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5FE);
  Color get bgCard     => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get bgInput    => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get cardBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE8EFFE);
  Color get divider    => isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  Color get inputBorder=> isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0);

  Color get textPrimary  => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get textSecondary=> isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get textMuted    => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  Color get navBg        => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get navBorder    => isDark ? const Color(0xFF334155) : const Color(0xFFE8EFFE);
}

// Extension supaya bisa dipanggil: context.colors.bgPage
extension AppColorsExtension on BuildContext {
  DynamicColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return DynamicColors(isDark);
  }

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}