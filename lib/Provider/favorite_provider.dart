import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> get favorites => _favoriteIds;
  
  // Toggle favorites state
  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;
    
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId);
    }
    
    notifyListeners();
  }
  
  // Check if a product is favorited
  bool isFavorited(String productId) {
    return _favoriteIds.contains(productId);
  }
  
  // Add to favorites in Firestore
  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite': true,
      });
    } catch (e) {
      print(e.toString());
    }
  }
  
  // Remove favorite from Firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }
  
  // Load favorites from Firestore
  Future<void> loadFavorites() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("userFavorite").get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}

