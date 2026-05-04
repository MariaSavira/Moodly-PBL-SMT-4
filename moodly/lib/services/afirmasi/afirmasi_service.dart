import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AfirmasiService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Map<String, String>> _favoritItems = [];
  static const String _favoriteItemsKey = 'favorite_afirmasi_items';

  static Future<List<Map<String, String>>> getAfirmasiByCategories(
    List<String> categories,
  ) async {
    if (categories.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('afirmasi')
          .where('kategori', whereIn: categories)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'kategori': (data['kategori'] ?? '').toString(),
          'teks': (data['teks'] ?? '').toString(),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> loadFavoritesFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getStringList(_favoriteItemsKey) ?? [];

    _favoritItems.clear();

    for (final item in savedItems) {
      final decoded = jsonDecode(item);
      _favoritItems.add(Map<String, String>.from(decoded));
    }
  }

  static Future<void> _saveFavoritesToLocal() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedItems = _favoritItems.map((item) => jsonEncode(item)).toList();

    await prefs.setStringList(_favoriteItemsKey, encodedItems);
  }

  static List<Map<String, String>> getFavoritItems() {
    return List<Map<String, String>>.from(_favoritItems);
  }

  static bool isFavorite(Map<String, String> item) {
    final itemId = item['id'] ?? '';
    return _favoritItems.any((fav) => (fav['id'] ?? '') == itemId);
  }

  static Future<void> toggleFavorite(Map<String, String> item) async {
    final itemId = item['id'] ?? '';
    final index = _favoritItems.indexWhere(
      (fav) => (fav['id'] ?? '') == itemId,
    );

    if (index >= 0) {
      _favoritItems.removeAt(index);
    } else {
      _favoritItems.add(Map<String, String>.from(item));
    }

    await _saveFavoritesToLocal();
  }

  static Future<void> removeFavorite(Map<String, String> item) async {
    final itemId = item['id'] ?? '';
    _favoritItems.removeWhere((fav) => (fav['id'] ?? '') == itemId);
    await _saveFavoritesToLocal();
  }

  static Future<void> removeManyFavorites(
    List<Map<String, String>> items,
  ) async {
    final idsToRemove = items.map((item) => item['id'] ?? '').toSet();
    _favoritItems.removeWhere((fav) => idsToRemove.contains(fav['id'] ?? ''));
    await _saveFavoritesToLocal();
  }
}