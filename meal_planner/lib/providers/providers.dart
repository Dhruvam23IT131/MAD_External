import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/models.dart';
import '../core/firebase_service.dart';

class FoodProvider with ChangeNotifier {
  List<FoodItem> _foods = [];
  List<FoodItem> get foods => _foods;

  Future<void> fetchFoods() async {
    _foods = await DatabaseHelper.instance.getAllFoodItems();
    notifyListeners();
  }

  Future<List<FoodItem>> searchFoods(String query) async {
    if (query.isEmpty) return [];
    return await DatabaseHelper.instance.searchFoodItems(query);
  }

  Future<void> addCustomFood(FoodItem food) async {
    await DatabaseHelper.instance.insertFoodItem(food);
    await fetchFoods();
    FirebaseService.instance.syncCustomFood(food);
  }
}

class MealProvider with ChangeNotifier {
  List<MealEntry> _dailyLogs = [];
  List<MealEntry> get dailyLogs => _dailyLogs;

  List<MealEntry> _weeklyLogs = [];
  List<MealEntry> get weeklyLogs => _weeklyLogs;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  double get totalDailyCalories => _dailyLogs.fold(0, (sum, item) => sum + item.totalCalories);
  double get totalDailyProtein => _dailyLogs.fold(0, (sum, item) => sum + item.totalProtein);
  double get totalDailyCarbs => _dailyLogs.fold(0, (sum, item) => sum + item.totalCarbs);
  double get totalDailyFat => _dailyLogs.fold(0, (sum, item) => sum + item.totalFat);

  Future<void> fetchLogs(DateTime date) async {
    _selectedDate = date;
    _dailyLogs = await DatabaseHelper.instance.getMealLogsByDate(date);
    await fetchWeeklyLogs();
    notifyListeners();
  }

  Future<void> fetchWeeklyLogs() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    _weeklyLogs = await DatabaseHelper.instance.getMealLogsInRange(start, now);
  }

  Future<void> addMealEntry(MealEntry entry) async {
    await DatabaseHelper.instance.insertMealLog(entry);
    
    // Trigger offline-first sync
    FirebaseService.instance.syncMealLogs();

    if (entry.date.year == _selectedDate.year &&
        entry.date.month == _selectedDate.month &&
        entry.date.day == _selectedDate.day) {
      await fetchLogs(_selectedDate);
    }
  }

  Future<void> deleteMealEntry(String id) async {
    await DatabaseHelper.instance.deleteMealLog(id);
    await fetchLogs(_selectedDate);
  }

  Future<void> copyDayPlan(DateTime from, DateTime to) async {
    final logs = await DatabaseHelper.instance.getMealLogsByDate(from);
    for (var log in logs) {
      final newEntry = MealEntry(
        id: const Uuid().v4(),
        foodItemId: log.foodItemId,
        foodName: log.foodName,
        mealType: log.mealType,
        date: to,
        quantity: log.quantity,
        totalCalories: log.totalCalories,
        totalProtein: log.totalProtein,
        totalCarbs: log.totalCarbs,
        totalFat: log.totalFat,
      );
      await DatabaseHelper.instance.insertMealLog(newEntry);
    }
    await fetchLogs(_selectedDate);
    FirebaseService.instance.syncMealLogs();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchLogs(date);
  }
}

class UserProfileProvider with ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  static const String profileBoxName = 'user_profile';

  double get calorieGoal => _profile?.calorieGoal ?? 2000.0;
  double get proteinGoal => _profile?.proteinGoal ?? 150.0;
  double get carbsGoal => _profile?.carbsGoal ?? 250.0;
  double get fatGoal => _profile?.fatGoal ?? 70.0;
  double get weight => _profile?.weight ?? 70.0;

  Future<void> loadProfile() async {
    final box = await Hive.openBox(profileBoxName);
    final data = box.get('current_profile');
    if (data != null) {
      _profile = UserProfile.fromMap(Map<String, dynamic>.from(data));
    }
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    final box = await Hive.openBox(profileBoxName);
    await box.put('current_profile', profile.toMap());
    notifyListeners();
    FirebaseService.instance.syncUserProfile(profile);
  }
}
