import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

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

// Build a deterministic palette of at least 50 colors derived from brand accents.
// We derive lightened variants of the base colors to reach >= 50 unique colors.
List<Color> buildDeterministicPalette() {
  // Use the first 15 colors exactly as defined in possibleEventColors.
  // Note: possibleEventColors currently lists 16 colors; we take the first 15.
  const allBases = AppColors.possibleEventColors;
  final first15 = allBases.take(15).toList(growable: false);

  // For the remaining 35, generate distinct darker variants to avoid washed-out look.
  // Avoid factor = 0.0 to not duplicate original colors.
  final darkenSteps = <double>[0.1, 0.2, 0.3, 0.4];
  final rest = <Color>[];
  outer:
  for (final base in allBases) {
    for (final t in darkenSteps) {
      rest.add(_darken(base, t));
      if (first15.length + rest.length >= 50) {
        break outer;
      }
    }
  }

  final palette = <Color>[...first15, ...rest];
  return palette.length >= 50 ? palette.sublist(0, 50) : palette;
}

Color _darken(Color color, double t) {
  // Linear interpolation towards black by factor t
  final r = (color.red * (1 - t)).clamp(0, 255).toInt();
  final g = (color.green * (1 - t)).clamp(0, 255).toInt();
  final b = (color.blue * (1 - t)).clamp(0, 255).toInt();
  return Color.fromARGB(color.alpha, r, g, b);
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
