import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _favoriteMealIds = [];
  bool _isLoading = false;

  List<String> get items => _favoriteMealIds;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();
      
      _favoriteMealIds = snapshot.docs.map((doc) => doc.id).toList();
      print('✅ Loaded ${_favoriteMealIds.length} favorites');
    } catch (e) {
      print('❌ Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

    Future<void> toggleFavorite(String mealId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    final favoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(mealId);

    try {
      final doc = await favoritesRef.get();
      
      if (doc.exists) {
        await favoritesRef.delete();
        _favoriteMealIds.remove(mealId);
        print('❤️ Removed favorite: $mealId');
      } 
      else {
        await favoritesRef.set({
          'userId': user.uid,
          'mealId': mealId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        _favoriteMealIds.add(mealId);
        print('💙 Added favorite: $mealId');
      }
    } catch (e) {
      print('❌ Toggle error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String mealId) => _favoriteMealIds.contains(mealId);

  static Future<List<String>> getAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('favorites')
          .limit(50)
          .get();
      
      final users = snapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .toSet()
          .toList();
      return users;
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
}
