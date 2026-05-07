import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../core/constants/app_colors.dart';
import '../food_log/food_search_screen.dart';
import '../meal_planner/meal_planner_screen.dart';
import '../insights/analytics_screen.dart';
import '../profile/profile_screen.dart';

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
      appBar: AppBar(
        title: const Text('Smart Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealPlannerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MealProvider>().fetchLogs(context.read<MealProvider>().selectedDate);
          await context.read<FoodProvider>().fetchFoods();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDailyProgress(),
              const SizedBox(height: 24),
              _buildMacroSection(),
              const SizedBox(height: 24),
              _buildMealSection('Breakfast', Icons.wb_sunny_outlined, AppColors.breakfast),
              _buildMealSection('Lunch', Icons.sunny, AppColors.lunch),
              _buildMealSection('Dinner', Icons.nightlight_round, AppColors.dinner),
              _buildMealSection('Snacks', Icons.apple_outlined, AppColors.snack),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const FoodSearchScreen())
        ).then((_) {
          context.read<MealProvider>().fetchLogs(context.read<MealProvider>().selectedDate);
        }),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDailyProgress() {
    return Consumer2<MealProvider, UserProfileProvider>(
      builder: (context, mealProv, userProv, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalorieRing(
                  consumed: mealProv.totalDailyCalories,
                  goal: userProv.calorieGoal,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem('Goal', '${userProv.calorieGoal.toInt()}'),
                    const SizedBox(height: 12),
                    _buildStatItem('Consumed', '${mealProv.totalDailyCalories.toInt()}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
      ],
    );
  }

  Widget _buildMacroSection() {
    return Consumer2<MealProvider, UserProfileProvider>(
      builder: (context, mealProv, userProv, child) {
        return Row(
          children: [
            Expanded(child: MacroCard(label: 'Protein', value: mealProv.totalDailyProtein, goal: userProv.proteinGoal, color: AppColors.chartProtein)),
            const SizedBox(width: 12),
            Expanded(child: MacroCard(label: 'Carbs', value: mealProv.totalDailyCarbs, goal: userProv.carbsGoal, color: AppColors.chartCarbs)),
            const SizedBox(width: 12),
            Expanded(child: MacroCard(label: 'Fat', value: mealProv.totalDailyFat, goal: userProv.fatGoal, color: AppColors.chartFat)),
          ],
        );
      },
    );
  }

  Widget _buildMealSection(String title, IconData icon, Color color) {
    return Consumer<MealProvider>(
      builder: (context, mealProv, child) {
        final meals = mealProv.dailyLogs.where((m) => m.mealType.toLowerCase() == title.toLowerCase()).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const Spacer(),
                  Text('${meals.fold(0.0, (sum, m) => sum + m.totalCalories).toInt()} kcal', 
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text('No entries yet', style: Theme.of(context).textTheme.bodySmall),
              )
            else
              ...meals.map((meal) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(meal.foodName),
                subtitle: Text('${meal.quantity.toInt()} units'),
                trailing: Text('${meal.totalCalories.toInt()} kcal'),
              )),
          ],
        );
      },
    );
  }
}
