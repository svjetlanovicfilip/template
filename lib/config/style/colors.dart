import 'dart:ui';

class AppColors {
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
}


// Login/Signup Background (Vertical gradient):
// Tailwind: `bg-gradient-to-b from-slate-900 to-slate-800`
// CSS: `linear-gradient(to bottom, #0F172A, #1E293B)`
// Flows from top to bottom

// Main App Header (Horizontal gradient):
// Tailwind: `bg-gradient-to-r from-slate-900 to-slate-800`
// CSS: `linear-gradient(to right, #0F172A, #1E293B)`
// Flows from left to right