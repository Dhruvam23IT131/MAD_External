import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import 'database/database_helper.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseService._init();

  // Sync profile to Firebase
  Future<void> syncProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc('current_user').set(profile.toMap());
    } catch (e) {
      print('Firebase Sync Error (Profile): $e');
    }
  }

  // Sync meal logs to Firebase
  Future<void> syncMealLogs() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;

    try {
      final unsynced = await DatabaseHelper.instance.getUnsyncedLogs();

      for (var map in unsynced) {
        final entry = MealEntry.fromMap(map);
        
        // Push to Firestore
        await _firestore.collection('meal_logs').doc(entry.id).set(entry.toMap());
        
        // Mark as synced in local DB
        await DatabaseHelper.instance.markAsSynced(entry.id);
      }
      print('Firebase Sync Success: ${unsynced.length} logs synced');
    } catch (e) {
      print('Firebase Sync Error (Logs): $e');
    }
  }

  // Real-time listener for food items (global database)
  Stream<List<FoodItem>> getFoodItemsStream() {
    return _firestore.collection('foods').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FoodItem.fromMap(doc.data())).toList();
    });
  }

  // Initial setup to seed Firestore with default foods if empty
  Future<void> seedFirestore(List<FoodItem> foods) async {
    final snapshot = await _firestore.collection('foods').limit(1).get();
    if (snapshot.docs.isEmpty) {
      for (var food in foods) {
        await _firestore.collection('foods').doc(food.id).set(food.toMap());
      }
    }
  }
}
