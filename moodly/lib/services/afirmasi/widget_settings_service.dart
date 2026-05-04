import 'package:shared_preferences/shared_preferences.dart';

class WidgetSettingsService {
  static const String showCategoryKey = 'widget_show_category';
  static const String showQuoteKey = 'widget_show_quote';
  static const String useBackgroundKey = 'widget_use_background';
  static const String autoRefreshKey = 'widget_auto_refresh';
  static const String widgetScaleKey = 'widget_scale';
  static const String textColorKey = 'widget_text_color';
  static const String overlayColorKey = 'widget_overlay_color';
  static const String selectedWallpaperKey = 'widget_selected_wallpaper';
  static const String customWallpaperPathKey = 'widget_custom_wallpaper_path';
  static const String useCustomWallpaperKey = 'widget_use_custom_wallpaper';

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}