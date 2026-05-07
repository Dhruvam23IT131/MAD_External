import 'package:hive_flutter/hive_flutter.dart';
import 'seed_data.dart';
import '../../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  DatabaseHelper._init();

  static const String foodBoxName = 'food_items';
  static const String logBoxName = 'meal_logs';
  static const String planBoxName = 'meal_plans';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(foodBoxName);
    await Hive.openBox(logBoxName);
    await Hive.openBox(planBoxName);

    final foodBox = Hive.box(foodBoxName);
    if (foodBox.isEmpty) {
      for (var food in SeedData.initialFoods) {
        await foodBox.put(food.id, food.toMap());
      }
    }
  }

  Future<void> insertMealLog(MealEntry entry) async {
    final box = Hive.box(logBoxName);
    await box.put(entry.id, entry.toMap());
  }

  Future<void> deleteMealLog(String id) async {
    final box = Hive.box(logBoxName);
    await box.delete(id);
  }

  Future<List<MealEntry>> getMealLogsByDate(DateTime date) async {
    final box = Hive.box(logBoxName);
    final dateStr = date.toIso8601String().split('T')[0];
    
    return box.values
        .where((item) => item['date'].toString().startsWith(dateStr))
        .map((item) => MealEntry.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<MealEntry>> getMealLogsInRange(DateTime start, DateTime end) async {
    final box = Hive.box(logBoxName);
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return box.values
        .map((item) => MealEntry.fromMap(Map<String, dynamic>.from(item)))
        .where((entry) => entry.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
                          entry.date.isBefore(endOfDay.add(const Duration(seconds: 1))))
        .toList();
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    final box = Hive.box(foodBoxName);
    return box.values
        .map((item) => FoodItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final box = Hive.box(foodBoxName);
    return box.values
        .where((item) => item['name'].toString().toLowerCase().contains(query.toLowerCase()))
        .map((item) => FoodItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> insertFoodItem(FoodItem food) async {
    final box = Hive.box(foodBoxName);
    await box.put(food.id, food.toMap());
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLogs() async {
    final box = Hive.box(logBoxName);
    return box.values
        .where((item) => item['synced'] == 0)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> markAsSynced(String id) async {
    final box = Hive.box(logBoxName);
    final data = box.get(id);
    if (data != null) {
      final map = Map<String, dynamic>.from(data);
      map['synced'] = 1;
      await box.put(id, map);
    }
  }
}
