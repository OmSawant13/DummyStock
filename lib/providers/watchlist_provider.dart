import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class WatchlistProvider with ChangeNotifier {
  final StorageService _storageService;
  List<String> _watchlistSymbols = [];

  List<String> get watchlistSymbols => _watchlistSymbols;

  WatchlistProvider(this._storageService) {
    reloadUserData();
  }

  void reloadUserData() {
    _watchlistSymbols = _storageService.getWatchlistSymbols();
    notifyListeners();
  }

  bool isInWatchlist(String symbol) {
    return _watchlistSymbols.contains(symbol.toUpperCase());
  }

  void toggleWatchlist(String symbol) {
    final sym = symbol.toUpperCase();
    if (_watchlistSymbols.contains(sym)) {
      _watchlistSymbols.remove(sym);
    } else {
      _watchlistSymbols.add(sym);
    }
    _storageService.saveWatchlistSymbols(_watchlistSymbols);
    notifyListeners();
  }

  void reorderWatchlist(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _watchlistSymbols.removeAt(oldIndex);
    _watchlistSymbols.insert(newIndex, item);
    _storageService.saveWatchlistSymbols(_watchlistSymbols);
    notifyListeners();
  }
}
