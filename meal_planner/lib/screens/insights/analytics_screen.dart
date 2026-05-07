import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/providers.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeRange = 'Week';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MealProvider>().fetchWeeklyLogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer2<MealProvider, UserProfileProvider>(
        builder: (context, mealProv, userProv, child) {
          final weeklyData = _processWeeklyData(mealProv.weeklyLogs);
          final avgKcal = weeklyData.values.isEmpty ? 0 : weeklyData.values.reduce((a, b) => a + b) / 7;
          final daysOnTrack = weeklyData.values.where((v) => v > 0 && v <= userProv.calorieGoal).length;
          final goalAchievement = (daysOnTrack / 7 * 100).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeToggle(),
                const SizedBox(height: 24),
                _buildGoalSummaryGrid(goalAchievement, avgKcal.toInt(), daysOnTrack, mealProv.totalDailyProtein.toInt()),
                const SizedBox(height: 32),
                const Text('Weekly calorie intake', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBarChart(weeklyData, userProv.calorieGoal),
                const SizedBox(height: 32),
                const Text('Macro split (avg)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildMacroSplitBar(mealProv),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<int, double> _processWeeklyData(List<dynamic> logs) {
    final Map<int, double> dayTotals = {0:0, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0};
    final now = DateTime.now();
    for (var log in logs) {
      final diff = now.difference(log.date).inDays;
      if (diff >= 0 && diff < 7) {
        final dayIndex = 6 - diff;
        dayTotals[dayIndex] = (dayTotals[dayIndex] ?? 0) + log.totalCalories;
      }
    }
    return dayTotals;
  }

  Widget _buildTimeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.divider.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Week', 'Month'].map((range) {
          final isSelected = _timeRange == range;
          return GestureDetector(
            onTap: () => setState(() => _timeRange = range),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(range, style: TextStyle(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalSummaryGrid(int goalPct, int avgKcal, int daysTrack, int protein) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard('$goalPct%', 'Goal achieved', AppColors.primary),
        _buildSummaryCard(avgKcal.toString(), 'Avg daily kcal', Colors.blue),
        _buildSummaryCard('$daysTrack/7', 'Days on track', Colors.orange),
        _buildSummaryCard('${protein}g', 'Avg protein', Colors.red),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<int, double> weeklyData, double goal) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.divider)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (goal * 1.2).clamp(2500, 5000),
          barGroups: List.generate(7, (i) => _makeGroup(i, weeklyData[i] ?? 0, goal)),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final date = DateTime.now().subtract(Duration(days: 6 - val.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('E').format(date).substring(0, 1), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroup(int x, double y, double goal) {
    final bool overGoal = y > goal;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y == 0 ? AppColors.divider.withOpacity(0.3) : (overGoal ? Colors.red.withOpacity(0.7) : AppColors.primary.withOpacity(0.7)),
          width: 20,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: goal * 1.2, color: AppColors.divider.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildMacroSplitBar(MealProvider mealProv) {
    final p = mealProv.totalDailyProtein;
    final c = mealProv.totalDailyCarbs;
    final f = mealProv.totalDailyFat;
    final total = p + c + f;
    
    if (total == 0) return const Center(child: Text('Log meals to see macro split', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: (p/total*100).toInt(), child: Container(color: AppColors.protein)),
                  Expanded(flex: (c/total*100).toInt(), child: Container(color: AppColors.carbs)),
                  Expanded(flex: (f/total*100).toInt(), child: Container(color: AppColors.fats)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroIndicator('Protein ${(p/total*100).toInt()}%', AppColors.protein),
              _macroIndicator('Carbs ${(c/total*100).toInt()}%', AppColors.carbs),
              _macroIndicator('Fats ${(f/total*100).toInt()}%', AppColors.fats),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroIndicator(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
