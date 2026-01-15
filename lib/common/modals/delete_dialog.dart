import 'package:flutter/material.dart';

class RemoveDialog extends StatelessWidget {
  const RemoveDialog({
    required this.title,
    required this.description,
    required this.onDelete,
    super.key,
  });

  final String title;
  final String description;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.black),
      ),
      content: Text(
        description,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.black),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Odustani'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: onDelete,
              child: const Text('Izbrisi'),
            ),
          ],
        ),
      ],
    );
  }
}

Future<bool> showDeleteDialog({
  required BuildContext context,
  required String title,
  required String description,
  required VoidCallback onDelete,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return RemoveDialog(
        title: title,
        description: description,
        onDelete: onDelete,
      );
    },
  );

  return result ?? false;
}
