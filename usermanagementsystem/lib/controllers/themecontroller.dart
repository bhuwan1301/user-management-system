import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  final _storage = const FlutterSecureStorage();
  final String _themeKey = 'app_theme';

  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    initializeTheme();
  }

  Future<void> initializeTheme() async {
    await _loadThemeFromStorage();
  }

  Future<void> _loadThemeFromStorage() async {
    try {
      print("Loading theme from storage");
      bool containsKey = await _storage.containsKey(key: _themeKey);
      if (!containsKey) {
        print("No theme found, setting default to light");
        await _storage.write(key: _themeKey, value: 'light');
        _isDarkMode.value = false;
        return;
      }

      final themeStr = await _storage.read(key: _themeKey);
      print("Loaded theme: $themeStr");
      
      if (themeStr != null && themeStr.isNotEmpty) {
        _isDarkMode.value = themeStr == 'dark';
      } else {
        print("Theme value is null or empty, resetting to light");
        _isDarkMode.value = false;
        await _storage.write(key: _themeKey, value: 'light');
      }
    } catch (e) {
      print("Error loading theme: $e");
      _isDarkMode.value = false;
      
      try {
        await _storage.write(key: _themeKey, value: 'light');
      } catch (e) {
        print("Failed to reset theme storage: $e");
      }
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode.value = !_isDarkMode.value;
      final newTheme = _isDarkMode.value ? 'dark' : 'light';
      await _storage.write(key: _themeKey, value: newTheme);
      print("Theme saved successfully: $newTheme");
      Get.changeThemeMode(themeMode);
    } catch (e) {
      print("Error saving theme: $e");
      
      _isDarkMode.value = !_isDarkMode.value;
    }
  }
}