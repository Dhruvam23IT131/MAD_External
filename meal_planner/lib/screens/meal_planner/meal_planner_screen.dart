import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/providers.dart';
import '../food_log/food_search_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meal Plan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all, color: AppColors.primary),
            onPressed: () => _showCopyDialog(),
            tooltip: 'Copy today\'s plan to tomorrow',
          ),
        ],
      ),
      body: Consumer<MealProvider>(
        builder: (context, mealProv, child) {
          return Column(
            children: [
              _buildCalendarStrip(mealProv),
              _buildCategoryFilter(),
              Expanded(
                child: _buildMealList(mealProv),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarStrip(MealProvider mealProv) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final day = DateTime.now().add(Duration(days: index - 2));
          final isSelected = day.day == _focusedDay.day && day.month == _focusedDay.month;
          return GestureDetector(
            onTap: () {
              setState(() => _focusedDay = day);
              mealProv.setSelectedDate(day);
            },
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(day), style: TextStyle(color: isSelected ? Colors.white70 : AppColors.textSecondary, fontSize: 12)),
                  Text(day.day.toString(), style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textSecondary)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealList(MealProvider mealProv) {
    final allEntries = mealProv.dailyLogs;
    final filteredEntries = _selectedCategory == 'All' 
        ? allEntries 
        : allEntries.where((m) => m.mealType.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    final Map<String, List<dynamic>> grouped = {};
    for (var entry in filteredEntries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    if (grouped.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.divider),
              const SizedBox(height: 16),
              const Text('Nothing planned for this day', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              _buildAddMealButton(),
            ],
          ),
        );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...grouped.entries.map((group) => _buildMealCard(group.key, group.value)).toList(),
        const SizedBox(height: 16),
        _buildAddMealButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMealCard(String type, List<dynamic> entries) {
    final totalKcal = entries.fold(0.0, (sum, e) => sum + e.totalCalories).toInt();
    final totalP = entries.fold(0.0, (sum, e) => sum + e.totalProtein).toInt();
    final totalC = entries.fold(0.0, (sum, e) => sum + e.totalCarbs).toInt();
    final totalF = entries.fold(0.0, (sum, e) => sum + e.totalFat).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _getDotColor(type), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text('$totalKcal kcal', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          ...entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.foodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${e.quantity.toInt()} units', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => context.read<MealProvider>().deleteMealEntry(e.id),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 16),
          Row(
            children: [
              _macroLabel('P: ${totalP}g', Colors.blue),
              const SizedBox(width: 8),
              _macroLabel('C: ${totalC}g', Colors.orange),
              const SizedBox(width: 8),
              _macroLabel('F: ${totalF}g', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDotColor(String type) {
    switch(type.toLowerCase()) {
      case 'breakfast': return Colors.orange;
      case 'lunch': return Colors.teal;
      case 'dinner': return Colors.indigo;
      default: return Colors.red;
    }
  }

  Widget _macroLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildAddMealButton() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodSearchScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Add meal to plan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showCopyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy Plan'),
        content: Text('Would you like to copy today\'s meal plan to tomorrow?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final tomorrow = DateTime.now().add(const Duration(days: 1));
              context.read<MealProvider>().copyDayPlan(DateTime.now(), tomorrow);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan copied to tomorrow!')));
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}
