import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/providers.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<MealProvider>(
        builder: (context, mealProv, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Trends', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                _buildWeeklyChart(context),
                const SizedBox(height: 32),
                Text('Today\'s Balance', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                _buildNutrientPie(context, mealProv),
                const SizedBox(height: 32),
                _buildSummaryCards(context, mealProv),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 2500,
          barGroups: [
            _makeGroup(0, 1800),
            _makeGroup(1, 2100),
            _makeGroup(2, 1600),
            _makeGroup(3, 2400),
            _makeGroup(4, 1900),
            _makeGroup(5, 1200),
            _makeGroup(6, 1750),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Text(days[val.toInt()], style: const TextStyle(color: Colors.white70, fontSize: 10));
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

  BarChartGroupData _makeGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 2500,
            color: AppColors.divider,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientPie(BuildContext context, MealProvider mealProv) {
    final prot = mealProv.totalDailyProtein;
    final carb = mealProv.totalDailyCarbs;
    final fat = mealProv.totalDailyFat;
    final total = prot + carb + fat;

    final List<PieChartSectionData> sections = total == 0 
      ? [PieChartSectionData(color: AppColors.divider, value: 100, title: 'No Data', radius: 50)]
      : [
          PieChartSectionData(color: AppColors.chartProtein, value: prot, title: '${((prot/total)*100).toInt()}%', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          PieChartSectionData(color: AppColors.chartCarbs, value: carb, title: '${((carb/total)*100).toInt()}%', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          PieChartSectionData(color: AppColors.chartFat, value: fat, title: '${((fat/total)*100).toInt()}%', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pieLegend('Protein (${prot.toInt()}g)', AppColors.chartProtein),
                _pieLegend('Carbs (${carb.toInt()}g)', AppColors.chartCarbs),
                _pieLegend('Fats (${fat.toInt()}g)', AppColors.chartFat),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pieLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, MealProvider mealProv) {
    return Row(
      children: [
        _summaryCard(context, 'Avg Cal', mealProv.totalDailyCalories.toInt().toString(), Icons.bolt, Colors.orange),
        const SizedBox(width: 12),
        _summaryCard(context, 'Goal Hit', '85%', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
