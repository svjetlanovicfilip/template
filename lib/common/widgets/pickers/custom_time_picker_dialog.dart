import 'package:flutter/material.dart';

import '../../../config/style/colors.dart';

class CustomTimePickerDialog extends StatefulWidget {
  const CustomTimePickerDialog({
    required this.initialHour,
    required this.initialMinuteIndex,
    super.key,
  });

  final int initialHour; // 0-23
  final int initialMinuteIndex; // 0-11 for 0..55 step 5

  @override
  State<CustomTimePickerDialog> createState() => CustomTimePickerDialogState();
}

class CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  int _hour = 0;
  int _minuteIndex = 0;

  @override
  void initState() {
    super.initState();
    // Restrict selectable hours to 05..23
    _hour = widget.initialHour.clamp(5, 23);
    _minuteIndex = widget.initialMinuteIndex;
    final initialHourIndex = _hour - 5; // map hour (5..23) -> index (0..18)
    _hourController = FixedExtentScrollController(
      initialItem: initialHourIndex,
    );
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          width: 320,
          height: 260,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Odaberite vrijeme',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.slate800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: AppColors.slate200.withValues(alpha: 1)),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NumberWheel(
                      controller: _hourController,
                      itemCount: 19, // 05..23 inclusive
                      display: (i) => _twoDigits(i + 5),
                      onSelectedItemChanged:
                          (i) => setState(() => _hour = i + 5),
                    ),
                    Text(
                      ':',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppColors.slate700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _NumberWheel(
                      controller: _minuteController,
                      itemCount: 12,
                      display: (i) => _twoDigits(i * 5),
                      onSelectedItemChanged:
                          (i) => setState(() => _minuteIndex = i),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.slate200.withValues(alpha: 1)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Odustani'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final minutes = _minuteIndex * 5;
                          Navigator.of(
                            context,
                          ).pop(TimeOfDay(hour: _hour, minute: minutes));
                        },
                        child: const Text('Potvrdi'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _NumberWheel extends StatelessWidget {
  const _NumberWheel({
    required this.controller,
    required this.itemCount,
    required this.display,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) display;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppColors.slate800,
      fontWeight: FontWeight.w600,
    );
    return SizedBox(
      width: 90,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        physics: const FixedExtentScrollPhysics(),
        itemExtent: 44,
        onSelectedItemChanged: onSelectedItemChanged,
        perspective: 0.00001, // remove wheel distortion for a flat look
        overAndUnderCenterOpacity: 0.25,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index >= itemCount) return null;
            return Center(child: Text(display(index), style: textStyle));
          },
        ),
      ),
    );
  }
}

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  // Round minutes to nearest 5 for initial position
  final initialHour = initialTime.hour.clamp(5, 23);
  final initialMinute = (initialTime.minute / 5).round() * 5;
  final initialMinuteIndex = (initialMinute % 60) ~/ 5;

  return showGeneralDialog<TimeOfDay>(
    context: context,
    barrierLabel: 'Odaberite vrijeme',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, anim, _, __) {
      final scale = Tween<double>(
        begin: 0.95,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(anim);
      final opacity = Tween<double>(
        begin: 0,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(anim);
      return FadeTransition(
        opacity: opacity,
        child: ScaleTransition(
          scale: scale,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: CustomTimePickerDialog(
                initialHour: initialHour,
                initialMinuteIndex: initialMinuteIndex,
              ),
            ),
          ),
        ),
      );
    },
  );
}
