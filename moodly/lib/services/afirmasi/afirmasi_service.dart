import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AfirmasiService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Map<String, String>> _favoritItems = [];
  static const String _favoriteItemsKey = 'favorite_afirmasi_items';
  static const String _languagePrefKey = 'moodly_settings_language_code';

  static const Map<String, String> _categoryIdToEn = {
    'Rasa Syukur': 'Gratitude',
    'Meredakan Kecemasan': 'Ease Anxiety',
    'Motivasi': 'Motivation',
    'Kesehatan Mental': 'Mental Health',
    'Cinta Diri': 'Self Love',
    'Afirmasi': 'Affirmation',
  };

  static const Map<String, String> _categoryAliasToCanonical = {
    'Rasa Syukur': 'Rasa Syukur',
    'Gratitude': 'Rasa Syukur',
    'Meredakan Kecemasan': 'Meredakan Kecemasan',
    'Ease Anxiety': 'Meredakan Kecemasan',
    'Motivasi': 'Motivasi',
    'Motivation': 'Motivasi',
    'Kesehatan Mental': 'Kesehatan Mental',
    'Mental Health': 'Kesehatan Mental',
    'Cinta Diri': 'Cinta Diri',
    'Self Love': 'Cinta Diri',
    'Afirmasi': 'Afirmasi',
    'Affirmation': 'Afirmasi',
  };

  static Future<String> _resolveLanguageCode([String? languageCode]) async {
    if (languageCode != null && languageCode.trim().isNotEmpty) {
      return languageCode.trim() == 'en' ? 'en' : 'id';
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languagePrefKey);
    return saved == 'en' ? 'en' : 'id';
  }

  static String canonicalCategoryKey(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return 'Afirmasi';
    return _categoryAliasToCanonical[cleaned] ?? cleaned;
  }

  static String localizedCategoryLabel(
    String? value, {
    String languageCode = 'id',
  }) {
    final canonical = canonicalCategoryKey(value);
    if (languageCode == 'en') {
      return _categoryIdToEn[canonical] ?? canonical;
    }
    return canonical;
  }

  static Map<String, String> _normalizeStoredFavorite(Map<String, String> item) {
    final id = (item['id'] ?? '').trim();
    final kategoriKey = canonicalCategoryKey(
      item['kategori_key'] ?? item['kategori'],
    );
    final textId = (item['teks_id'] ?? item['teks'] ?? '').trim();
    final textEn = (item['teks_en'] ?? '').trim();

    return {
      'id': id,
      'kategori_key': kategoriKey,
      'kategori': localizedCategoryLabel(kategoriKey, languageCode: 'id'),
      'kategori_en': localizedCategoryLabel(kategoriKey, languageCode: 'en'),
      'teks': textId,
      'teks_id': textId,
      'teks_en': textEn,
    };
  }

  static Map<String, String> _localizedFavoriteItem(
    Map<String, String> rawItem,
    String languageCode,
  ) {
    final normalized = _normalizeStoredFavorite(rawItem);
    final localizedText = languageCode == 'en' &&
            (normalized['teks_en'] ?? '').trim().isNotEmpty
        ? (normalized['teks_en'] ?? '').trim()
        : (normalized['teks_id'] ?? normalized['teks'] ?? '').trim();

    return {
      'id': normalized['id'] ?? '',
      'kategori_key': normalized['kategori_key'] ?? 'Afirmasi',
      'kategori': localizedCategoryLabel(
        normalized['kategori_key'],
        languageCode: languageCode,
      ),
      'teks': localizedText,
      'teks_id': normalized['teks_id'] ?? '',
      'teks_en': normalized['teks_en'] ?? '',
    };
  }

  static Future<List<Map<String, String>>> getAfirmasiByCategories(
    List<String> categories, {
    String? languageCode,
  }) async {
    if (categories.isEmpty) return [];

    final activeLanguage = await _resolveLanguageCode(languageCode);
    final canonicalCategories = categories
        .map(canonicalCategoryKey)
        .where((item) => item.trim().isNotEmpty)
        .toSet()
        .toList();

    try {
      final snapshot = await _firestore
          .collection('afirmasi')
          .where('kategori', whereIn: canonicalCategories)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final kategoriKey = canonicalCategoryKey(
          (data['kategori'] ?? '').toString(),
        );
        final textId = (data['teks'] ?? '').toString().trim();
        final textEn = (data['teks_en'] ?? data['teksEn'] ?? '')
            .toString()
            .trim();
        final localizedText = activeLanguage == 'en' && textEn.isNotEmpty
            ? textEn
            : textId;

        return {
          'id': doc.id,
          'kategori_key': kategoriKey,
          'kategori': localizedCategoryLabel(
            kategoriKey,
            languageCode: activeLanguage,
          ),
          'kategori_en': localizedCategoryLabel(
            kategoriKey,
            languageCode: 'en',
          ),
          'teks': localizedText,
          'teks_id': textId,
          'teks_en': textEn,
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

  static List<Map<String, String>> getFavoritItems({
    String languageCode = 'id',
  }) {
    return _favoritItems
        .map((item) => _localizedFavoriteItem(item, languageCode))
        .toList();
  }

  static bool isFavorite(Map<String, String> item) {
    final itemId = item['id'] ?? '';
    return _favoritItems.any((fav) => (fav['id'] ?? '') == itemId);
  }

  static Future<void> toggleFavorite(Map<String, String> item) async {
    final normalized = _normalizeStoredFavorite(item);
    final itemId = normalized['id'] ?? '';
    final index = _favoritItems.indexWhere(
      (fav) => (fav['id'] ?? '') == itemId,
    );

    if (index >= 0) {
      _favoritItems.removeAt(index);
    } else {
      _favoritItems.add(normalized);
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
