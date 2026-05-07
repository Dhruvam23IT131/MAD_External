import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../core/constants/app_colors.dart';
import '../../core/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Goals', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer2<UserProfileProvider, MealProvider>(
        builder: (context, userProv, mealProv, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalorieGoalCard(userProv, mealProv),
                const SizedBox(height: 32),
                const Text('Nutrient targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                _buildNutrientTargetTile('Protein', mealProv.totalDailyProtein, userProv.proteinGoal, AppColors.protein),
                _buildNutrientTargetTile('Carbohydrates', mealProv.totalDailyCarbs, userProv.carbsGoal, AppColors.carbs),
                _buildNutrientTargetTile('Fats', mealProv.totalDailyFat, userProv.fatGoal, AppColors.fats),
                const SizedBox(height: 32),
                const Text('Quick adjustments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                _buildQuickAdjustments(),
                const SizedBox(height: 32),
                _buildOfflineSyncCard(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalorieGoalCard(UserProfileProvider userProv, MealProvider mealProv) {
    final consumed = mealProv.totalDailyCalories;
    final goal = userProv.calorieGoal;
    final left = (goal - consumed).clamp(0.0, goal);
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily calorie goal', style: TextStyle(color: Colors.white70, fontSize: 14)),
              IconButton(onPressed: () => _showEditGoalDialog(userProv), icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(goal.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Text('kcal', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${consumed.toInt()} consumed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${left.toInt()} left', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientTargetTile(String label, double current, double target, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${current.toInt()}g', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    TextSpan(text: ' / ${target.toInt()}g', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppColors.divider, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdjustments() {
    return Row(
      children: [
        _adjustmentCard('Lose weight', Icons.directions_run, true),
        const SizedBox(width: 12),
        _adjustmentCard('Maintain', Icons.balance, false),
        const SizedBox(width: 12),
        _adjustmentCard('Gain muscle', Icons.fitness_center, false),
      ],
    );
  }

  Widget _adjustmentCard(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSyncCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_outlined, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Offline mode active', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text('3 entries pending sync', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => FirebaseService.instance.syncMealLogs(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Sync'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(UserProfileProvider userProv) {
    final calController = TextEditingController(text: userProv.calorieGoal.toString());
    final nameController = TextEditingController(text: userProv.profile?.name ?? 'Arjun Patel');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Display Name')),
            const SizedBox(height: 12),
            TextField(controller: calController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target kcal')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newGoal = double.tryParse(calController.text) ?? 2000.0;
              final newName = nameController.text.isEmpty ? 'User' : nameController.text;
              final profile = userProv.profile ?? UserProfile(name: newName, age: 25, weight: 70, height: 170, goalWeight: 70, activityLevel: 'Moderate', calorieGoal: 2000, proteinGoal: 150, carbsGoal: 250, fatGoal: 70);
              
              userProv.updateProfile(UserProfile(
                name: newName,
                age: profile.age,
                weight: profile.weight,
                height: profile.height,
                goalWeight: profile.goalWeight,
                activityLevel: profile.activityLevel,
                calorieGoal: newGoal,
                proteinGoal: profile.proteinGoal,
                carbsGoal: profile.carbsGoal,
                fatGoal: profile.fatGoal,
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
