import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';
import '../painters/circular_progress_painter.dart';

class TotalSlotsIndicator extends StatefulWidget {
  const TotalSlotsIndicator({required this.totalSlots, super.key});

  final int totalSlots;

  @override
  State<TotalSlotsIndicator> createState() => _TotalSlotsIndicatorState();
}

class _TotalSlotsIndicatorState extends State<TotalSlotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final progress = _animation.value; // 0..1
          final animatedValue = (widget.totalSlots * progress).clamp(
            0,
            widget.totalSlots,
          );
          return SizedBox.square(
            dimension: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(180),
                  painter: CircularProgressPainter(progress: progress),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      animatedValue.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber500,
                        fontSize: 44,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.totalSlots > 1 ? 'Termina' : 'Termin',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.slate400,
                        letterSpacing: 0.5,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
