import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  String _selectedMealType = 'Breakfast';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Grains', 'Protein', 'Dairy', 'Snacks'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FoodProvider>().fetchFoods());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add food', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _showAddCustomFoodDialog,
            child: const Text('Custom +', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_searchController.text.isEmpty) ...[
                    _buildSectionHeader('Recent'),
                    _buildFoodList(context.watch<FoodProvider>().foods.take(3).toList()),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Popular'),
                    _buildFoodList(context.watch<FoodProvider>().foods.skip(3).toList()),
                  ] else ...[
                    _buildSectionHeader('Search Results'),
                    _buildFoodList(_searchResults),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) async {
          final results = await context.read<FoodProvider>().searchFoods(val);
          setState(() => _searchResults = results);
        },
        decoration: InputDecoration(
          hintText: 'Search food items...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  Widget _buildFoodList(List<FoodItem> foods) {
    if (foods.isEmpty) return const Text('No items found');
    return Column(
      children: foods.map((food) => _buildFoodTile(food)).toList(),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Icon(_getCategoryIcon(food.category), color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('per ${food.servingSize}${food.servingUnit} • ${food.calories.toInt()} kcal', 
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showAddMealDialog(food),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch(category.toLowerCase()) {
        case 'grains': return Icons.grass;
        case 'protein': return Icons.egg_outlined;
        case 'dairy': return Icons.local_drink_outlined;
        default: return Icons.fastfood_outlined;
    }
  }

  void _showAddMealDialog(FoodItem food) {
    double qty = 1.0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add ${food.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedMealType = val!),
                decoration: const InputDecoration(labelText: 'Meal Type'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Quantity: '),
                  Expanded(
                    child: Slider(
                      value: qty,
                      min: 0.5,
                      max: 10,
                      divisions: 19,
                      label: qty.toString(),
                      onChanged: (val) => setDialogState(() => qty = val),
                    ),
                  ),
                  Text('${qty.toStringAsFixed(1)} units'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal added!')));
              },
              child: const Text('Add'),
            ),
          ],
        ),
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
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
