import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storageService;
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider(this._storageService) {
    _isDarkMode = _storageService.isDarkMode();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _storageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }
}
