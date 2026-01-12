import 'dart:ui';

class AppColors {
  //Test git push
  static const Color primaryLight = Color(0xFF030213);
  static const Color secondaryLight = Color(0xFFF5F5F8);
  static const Color onSecondaryLight = Color(0xFF030213);
  static const Color onSurfaceLight = Color(0xFF232323);
  static const Color errorLight = Color(0xFFD4183D);
  static const Color inputBackgroundLight = Color(0xFFF3F3F5);
  static const Color inputBorderLight = Color(0x1A000000);
  static const Color elevatedButtonBackgroundLight = Color(0xFFFFB300);

  // Brand - Amber
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber200 = Color(0xFFFFE5B4);
  static const Color amber300 = Color(0xFFFFE8A6);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber900 = Color(0xFF78350F);

  // Slate - Backgrounds & Text
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Accent - Red (Destructive)
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);

  // Base
  static const Color white = Color(0xFFFFFFFF);

  //possible event colors
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color green500 = Color(0xFF22C55E);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color violet500 = Color(0xFF8B5CF6);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color orange500 = Color(0xFFF97316);
  static const Color fuchsia500 = Color(0xFFD946EF);
  static const Color lime500 = Color(0xFF84CC16);

  static const List<Color> possibleEventColors = [
    blue500,
    purple500,
    amber500,
    green500,
    cyan500,
    pink500,
    yellow500,
    indigo500,
    teal500,
    rose500,
    violet500,
    emerald500,
    orange500,
    fuchsia500,
    lime500,
  ];
}

// Login/Signup Background (Vertical gradient):
// Tailwind: `bg-gradient-to-b from-slate-900 to-slate-800`
// CSS: `linear-gradient(to bottom, #0F172A, #1E293B)`
// Flows from top to bottom

// Main App Header (Horizontal gradient):
// Tailwind: `bg-gradient-to-r from-slate-900 to-slate-800`
// CSS: `linear-gradient(to right, #0F172A, #1E293B)`
// Flows from left to right
