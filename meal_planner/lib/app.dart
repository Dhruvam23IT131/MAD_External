import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'screens/splash/splash_screen.dart';

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
