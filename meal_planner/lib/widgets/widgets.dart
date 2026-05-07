import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;

  const CalorieRing({super.key, required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: AppColors.primaryLight,
            color: AppColors.primary,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              consumed.toInt().toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'kcal',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
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
    final progress = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${value.toInt()}g', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: color.withOpacity(0.1),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
