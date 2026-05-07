import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../core/constants/app_colors.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  String _selectedMealType = 'Breakfast';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FoodProvider>().fetchFoods());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search food...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) async {
                      final results = await context.read<FoodProvider>().searchFoods(val);
                      setState(() => _searchResults = results);
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildMealTypeSelector(),
          Expanded(
            child: _searchResults.isEmpty && _searchController.text.isEmpty
                ? _buildInitialList()
                : _buildSearchResults(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomFoodDialog,
        label: const Text('Custom Food'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCustomFoodDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: calController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
              TextField(controller: protController, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
              TextField(controller: carbsController, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number),
              TextField(controller: fatController, decoration: const InputDecoration(labelText: 'Fat (g)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              final food = FoodItem(
                id: const Uuid().v4(),
                name: nameController.text,
                calories: double.tryParse(calController.text) ?? 0,
                protein: double.tryParse(protController.text) ?? 0,
                carbs: double.tryParse(carbsController.text) ?? 0,
                fat: double.tryParse(fatController.text) ?? 0,
                servingSize: 100,
                servingUnit: 'g',
                category: 'Custom',
              );
              context.read<FoodProvider>().addCustomFood(food);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom food added!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    final types = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: types.map((type) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(type),
            selected: _selectedMealType == type,
            onSelected: (selected) {
              if (selected) setState(() => _selectedMealType = type);
            },
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInitialList() {
    return Consumer<FoodProvider>(
      builder: (context, foodProv, child) {
        return ListView.builder(
          itemCount: foodProv.foods.length,
          itemBuilder: (context, index) {
            return _foodTile(foodProv.foods[index]);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No food found. Try adding custom food?'));
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _foodTile(_searchResults[index]);
      },
    );
  }

  Widget _foodTile(FoodItem food) {
    return ListTile(
      title: Text(food.name),
      subtitle: Text('${food.calories.toInt()} kcal / ${food.servingSize.toInt()} ${food.servingUnit}'),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
        onPressed: () => _showAddDialog(food),
      ),
    );
  }

  void _showAddDialog(FoodItem food) {
    final qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${food.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (${food.servingUnit}s)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 1.0;
              final entry = MealEntry(
                id: const Uuid().v4(),
                foodItemId: food.id,
                foodName: food.name,
                mealType: _selectedMealType,
                date: DateTime.now(),
                quantity: qty,
                totalCalories: food.calories * qty,
                totalProtein: food.protein * qty,
                totalCarbs: food.carbs * qty,
                totalFat: food.fat * qty,
              );
              context.read<MealProvider>().addMealEntry(entry);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${food.name} to $_selectedMealType')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
