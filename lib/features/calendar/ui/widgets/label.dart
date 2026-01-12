import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  const Label({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
