class Appointment {
  Appointment({
    required this.id,
    required this.title,
    required this.event,
    required this.color,
    required this.startDateTime,
    required this.endDateTime,
  });

  final String id;
  final String title;
  final String event;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String color;
}
