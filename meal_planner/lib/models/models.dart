class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;
  final String category;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'category': category,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      servingSize: map['serving_size'],
      servingUnit: map['serving_unit'],
      category: map['category'],
    );
  }
}

class MealEntry {
  final String id;
  final String foodItemId;
  final String foodName;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime date;
  final double quantity;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int synced;

  MealEntry({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    required this.mealType,
    required this.date,
    required this.quantity,
    required this.totalCalories,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_item_id': foodItemId,
      'food_name': foodName,
      'meal_type': mealType,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'synced': synced,
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'],
      foodItemId: map['food_item_id'],
      foodName: map['food_name'],
      mealType: map['meal_type'],
      date: DateTime.parse(map['date']),
      quantity: map['quantity'],
      totalCalories: map['total_calories'],
      totalProtein: map['total_protein'] ?? 0.0,
      totalCarbs: map['total_carbs'] ?? 0.0,
      totalFat: map['total_fat'] ?? 0.0,
      synced: map['synced'] ?? 0,
    );
  }
}

class UserProfile {
  final String name;
  final int age;
  final double weight;
  final double height;
  final double goalWeight;
  final String activityLevel;
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.goalWeight,
    required this.activityLevel,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'goal_weight': goalWeight,
      'activity_level': activityLevel,
      'calorie_goal': calorieGoal,
      'protein_goal': proteinGoal,
      'carbs_goal': carbsGoal,
      'fat_goal': fatGoal,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      age: map['age'],
      weight: map['weight'],
      height: map['height'],
      goalWeight: map['goal_weight'],
      activityLevel: map['activity_level'],
      calorieGoal: map['calorie_goal'],
      proteinGoal: map['protein_goal'],
      carbsGoal: map['carbs_goal'],
      fatGoal: map['fat_goal'],
    );
  }
}
