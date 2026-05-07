import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import 'database/database_helper.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseService._init();

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

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
    if (!await isOnline()) return;
    try {
      final unsyncedLogs = await DatabaseHelper.instance.getUnsyncedLogs();
      if (unsyncedLogs.isEmpty) return;

      final batch = _firestore.batch();
      for (var log in unsyncedLogs) {
        final docRef = _firestore.collection('meal_logs').doc(log['id']);
        batch.set(docRef, log);
      }

      await batch.commit();
      for (var log in unsyncedLogs) {
        await DatabaseHelper.instance.markAsSynced(log['id']);
      }
      print('Firebase Sync Success: ${unsyncedLogs.length} logs synced');
    } catch (e) {
      print('Firebase Sync Error: $e');
    }
  }

  Future<void> syncUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc('user_1').set(profile.toMap());
      print('Profile Synced to Firebase');
    } catch (e) {
      print('Profile Sync Error: $e');
    }
  }

  Future<void> syncCustomFood(FoodItem food) async {
    try {
      await _firestore.collection('food_items').doc(food.id).set(food.toMap());
      print('Custom Food Synced to Firebase');
    } catch (e) {
      print('Food Sync Error: $e');
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
