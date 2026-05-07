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
    
    // Register adapters if you had them, but we'll use Map for simplicity to avoid boilerplate
    await Hive.openBox(foodBoxName);
    await Hive.openBox(logBoxName);
    await Hive.openBox(planBoxName);

    // Seed if empty
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

  Future<List<MealEntry>> getMealLogsByDate(DateTime date) async {
    final box = Hive.box(logBoxName);
    final dateStr = date.toIso8601String().split('T')[0];
    
    return box.values
        .where((item) => item['date'].toString().startsWith(dateStr))
        .map((item) => MealEntry.fromMap(Map<String, dynamic>.from(item)))
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

  // Sync helpers
  Future<List<Map<String, dynamic>>> getUnsyncedLogs() async {
    final box = Hive.box(logBoxName);
    return box.values
        .where((item) => item['synced'] == 0)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> markAsSynced(String id) async {
    final box = Hive.box(logBoxName);
    final data = Map<String, dynamic>.from(box.get(id));
    data['synced'] = 1;
    await box.put(id, data);
  }
}
