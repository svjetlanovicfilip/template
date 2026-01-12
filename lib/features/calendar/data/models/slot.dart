import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

class Slot extends Equatable {
  const Slot({
    required this.startDateTime,
    required this.title,
    this.endDateTime,
    this.color,
    this.id,
    this.serviceIds = const [],
  });

  factory Slot.fromJson(Map<String, dynamic> json, String id) {
    return Slot(
      id: id,
      title: json['title'],
      color: json['color'],
      startDateTime: (json['startDateTime'] as Timestamp).toDate(),
      endDateTime: (json['endDateTime'] as Timestamp).toDate(),
      serviceIds:
          (json['serviceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'serviceIds': serviceIds,
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
      color:
          color != null && color!.isNotEmpty
              ? Color(int.parse(color!))
              : AppColors.amber500,
    );
  }

  Slot copyWith({
    String? id,
    List<String>? serviceIds,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? color,
    String? title,
  }) {
    return Slot(
      id: id ?? this.id,
      title: title ?? this.title,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      color: color ?? this.color,
      serviceIds: serviceIds ?? this.serviceIds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    startDateTime,
    endDateTime,
    color,
    serviceIds,
  ];

  final String? id;
  final String title;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? color;
  final List<String> serviceIds;
}
