import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _weightController;
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>();
    _weightController = TextEditingController(text: profile.weight.toString());
    _calorieController = TextEditingController(text: profile.calorieGoal.toString());
    _proteinController = TextEditingController(text: profile.proteinGoal.toString());
    _carbsController = TextEditingController(text: profile.carbsGoal.toString());
    _fatController = TextEditingController(text: profile.fatGoal.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final newProfile = UserProfile(
      name: context.read<UserProfileProvider>().profile?.name ?? 'User',
      age: context.read<UserProfileProvider>().profile?.age ?? 25,
      weight: double.tryParse(_weightController.text) ?? 70.0,
      height: context.read<UserProfileProvider>().profile?.height ?? 170.0,
      goalWeight: context.read<UserProfileProvider>().profile?.goalWeight ?? 70.0,
      activityLevel: context.read<UserProfileProvider>().profile?.activityLevel ?? 'Moderate',
      calorieGoal: double.tryParse(_calorieController.text) ?? 2000.0,
      proteinGoal: double.tryParse(_proteinController.text) ?? 150.0,
      carbsGoal: double.tryParse(_carbsController.text) ?? 250.0,
      fatGoal: double.tryParse(_fatController.text) ?? 70.0,
    );
    context.read<UserProfileProvider>().updateProfile(newProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Body Info'),
            _buildTextField('Current Weight (kg)', _weightController, Icons.monitor_weight_outlined),
            const SizedBox(height: 24),
            _buildSectionTitle('Daily Goals'),
            _buildTextField('Calorie Target (kcal)', _calorieController, Icons.bolt, color: Colors.orange),
            _buildTextField('Protein Target (g)', _proteinController, Icons.egg_outlined, color: AppColors.chartProtein),
            _buildTextField('Carbs Target (g)', _carbsController, Icons.bakery_dining_outlined, color: AppColors.chartCarbs),
            _buildTextField('Fat Target (g)', _fatController, Icons.opacity_outlined, color: AppColors.chartFat),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color ?? Colors.white70),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
