import 'dart:ui';

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
