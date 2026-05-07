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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Planner')),
      body: Consumer<MealProvider>(
        builder: (context, mealProv, child) {
          return Column(
            children: [
              _buildCalendarStrip(mealProv),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPlanSlot(context, 'Breakfast', mealProv),
                    _buildPlanSlot(context, 'Lunch', mealProv),
                    _buildPlanSlot(context, 'Dinner', mealProv),
                    _buildPlanSlot(context, 'Snacks', mealProv),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to next day (Mock)')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy to Next Day'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.divider, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarStrip(MealProvider mealProv) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final day = DateTime.now().add(Duration(days: index - 3));
          final isSelected = day.day == _focusedDay.day && day.month == _focusedDay.month;
          return GestureDetector(
            onTap: () {
              setState(() => _focusedDay = day);
              mealProv.setSelectedDate(day);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(day), style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 12)),
                  Text(day.day.toString(), style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanSlot(BuildContext context, String title, MealProvider mealProv) {
    final meals = mealProv.dailyLogs.where((m) => m.mealType.toLowerCase() == title.toLowerCase()).toList();
    final foodName = meals.isEmpty ? 'Not planned' : meals.map((m) => m.foodName).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelectedMeal(title, mealProv) ? AppColors.primary : AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.restaurant, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(foodName, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: meals.isEmpty ? Colors.white38 : Colors.white,
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20), 
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const FoodSearchScreen())
              ).then((_) {
                mealProv.fetchLogs(_focusedDay);
              });
            }
          ),
        ],
      ),
    );
  }

  bool isSelectedMeal(String title, MealProvider mealProv) {
    return mealProv.dailyLogs.any((m) => m.mealType.toLowerCase() == title.toLowerCase());
  }
}
