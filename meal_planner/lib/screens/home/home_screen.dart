import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MealProvider>().fetchLogs(DateTime.now());
      context.read<FoodProvider>().fetchFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Teal background for the top header
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildMainContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProfileProvider>(
      builder: (context, userProv, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Good morning 🌿', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text(userProv.profile?.name ?? 'Arjun Patel', 
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Text('AP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalorieCard(),
          const SizedBox(height: 24),
          _buildMacrosRow(),
          const SizedBox(height: 32),
          _buildMealHeader(),
          const SizedBox(height: 16),
          _buildMealList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCalorieCard() {
    return Consumer2<MealProvider, UserProfileProvider>(
      builder: (context, mealProv, userProv, child) {
        final consumed = mealProv.totalDailyCalories;
        final goal = userProv.calorieGoal;
        final progress = (consumed / goal).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CALORIES TODAY', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(consumed.toInt().toString(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Goal: ${goal.toInt()} kcal', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.primaryLight,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacrosRow() {
    return Consumer<MealProvider>(
      builder: (context, mealProv, child) {
        return Row(
          children: [
            Expanded(child: MacroChip(label: 'Protein', value: '${mealProv.totalDailyProtein.toInt()}g', color: AppColors.protein)),
            const SizedBox(width: 12),
            Expanded(child: MacroChip(label: 'Carbs', value: '${mealProv.totalDailyCarbs.toInt()}g', color: AppColors.carbs)),
            const SizedBox(width: 12),
            Expanded(child: MacroChip(label: 'Fats', value: '${mealProv.totalDailyFat.toInt()}g', color: AppColors.fats)),
          ],
        );
      },
    );
  }

  Widget _buildMealHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Today\'s meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text('View all', style: TextStyle(color: AppColors.primary))),
      ],
    );
  }

  Widget _buildMealList() {
    return Consumer<MealProvider>(
      builder: (context, mealProv, child) {
        final meals = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];
        return Column(
          children: meals.map((type) {
            final entries = mealProv.dailyLogs.where((m) => m.mealType.toLowerCase() == type.toLowerCase()).toList();
            if (entries.isEmpty && type != 'Dinner') {
                return const SizedBox.shrink(); // Hide empty except maybe the one we want to "Log"
            }
            if (entries.isEmpty && type == 'Dinner') {
                return _buildLogDinnerButton();
            }
            
            return _buildMealTile(type, entries);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMealTile(String title, List<dynamic> entries) {
    final totalKcal = entries.fold(0.0, (sum, e) => sum + e.totalCalories).toInt();
    final itemsText = entries.map((e) => e.foodName).join(', ');
    
    IconData icon;
    Color iconBg;
    switch(title.toLowerCase()) {
      case 'breakfast': icon = Icons.breakfast_dining_outlined; iconBg = Colors.orange.withOpacity(0.1); break;
      case 'lunch': icon = Icons.lunch_dining_outlined; iconBg = Colors.blue.withOpacity(0.1); break;
      case 'snack': icon = Icons.apple_outlined; iconBg = Colors.red.withOpacity(0.1); break;
      default: icon = Icons.dinner_dining_outlined; iconBg = Colors.green.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(itemsText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$totalKcal kcal', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                    for(var e in entries) {
                        context.read<MealProvider>().deleteMealEntry(e.id);
                    }
                },
                child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogDinnerButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add, color: AppColors.textSecondary, size: 20),
          SizedBox(width: 8),
          Text('Log dinner', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MacroChip({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
