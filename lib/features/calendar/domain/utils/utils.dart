import 'package:flutter/material.dart';

const weekdays = [
  'Ponedeljak',
  'Utorak',
  'Srijeda',
  'Četvrtak',
  'Petak',
  'Subota',
  'Nedjelja',
];

const months = [
  'Januar',
  'Februar',
  'Mart',
  'April',
  'Maj',
  'Jun',
  'Jul',
  'Avgust',
  'Septembar',
  'Oktobar',
  'Novembar',
  'Decembar',
];

String formatWeekday(int weekDay) {
  return weekdays[weekDay];
}

String formatDateLong(DateTime d) {
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
}

String formatDateRange(DateTime from, DateTime to) {
  String fmt(int v) => v.toString().padLeft(2, '0');
  final startStr = '${fmt(from.hour)}:${fmt(from.minute)}';
  final endStr = '${fmt(to.hour)}:${fmt(to.minute)}';
  return '$startStr - $endStr';
}

Size textSize(String text, TextStyle style, {int maxLines = 2}) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.size;
}

// Vraća ~30 jasno različitih boja. Boje su generisane ravnomjernim rasporedom po HSL nijansi,
// uz fiksnu saturaciju i svjetlinu – izbjegavamo nijanse iste boje.
List<Color> buildDeterministicPalette() {
  const count = 32; // ~30 boja
  const saturation = 0.70;
  const lightness = 0.52;
  final colors = <Color>[];
  // Golden ratio raspored daje dobro razdvajanje boja
  double h = 0;
  const goldenRatioConjugate = 0.61803398875;
  for (var i = 0; i < count; i++) {
    h = (h + goldenRatioConjugate) % 1.0;
    final color =
        HSLColor.fromAHSL(1, h * 360.0, saturation, lightness).toColor();
    colors.add(color);
  }
  return colors;
}

int stableIndex(String key, int modulo) {
  // FNV-1a 32-bit hash yields stable mapping across sessions
  const fnvPrime = 0x01000193;
  const fnvOffset = 0x811C9DC5;
  var hash = fnvOffset;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash % modulo;
}
