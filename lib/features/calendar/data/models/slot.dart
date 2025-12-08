import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

class Slot {
  Slot({
    required this.startDateTime,
    required this.endDateTime,
    required this.title,
    this.color,
    this.id,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'],
      title: json['title'],
      color: json['color'],
      startDateTime: (json['startDateTime'] as Timestamp).toDate(),
      endDateTime: (json['endDateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
    };
  }

  CalendarEventData toCalendarEventData() {
    return CalendarEventData(
      date: startDateTime,
      startTime: startDateTime,
      endTime: endDateTime,
      endDate: endDateTime,
      title: title,
      event: this,
      color: color != null ? Color(int.parse(color!)) : AppColors.amber500,
    );
  }

  final String? id;
  final String title;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? color;
}
