import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../core/constants/app_colors.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    double percent = consumed / goal;
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;

    return CircularPercentIndicator(
      radius: 80.0,
      lineWidth: 12.0,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (goal - consumed).toInt().toString(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
          ),
          Text(
            'Remaining',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: AppColors.divider,
      progressColor: AppColors.primary,
      animation: true,
      animationDuration: 1000,
    );
  }
}

class MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;

  const MacroCard({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('${value.toInt()} / ${goal.toInt()}g', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 4.0,
            percent: (value / goal).clamp(0.0, 1.0),
            backgroundColor: AppColors.divider,
            progressColor: color,
            barRadius: const Radius.circular(2),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
