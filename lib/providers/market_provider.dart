import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../models/candle_model.dart';
import '../services/market_data_service.dart';
import '../core/constants/app_constants.dart';

class MarketProvider with ChangeNotifier {
  final MarketDataService _marketDataService = MarketDataService();
  Timer? _tickTimer;
  bool _isLiveStreaming = true;
  String _selectedSector = 'All Sectors';
  String _searchQuery = '';
  String _selectedTimeframe = '1D';

  List<StockModel> get allStocks => _marketDataService.stocks;
  List<MarketIndexModel> get indices => _marketDataService.indices;
  bool get isLiveStreaming => _isLiveStreaming;
  String get selectedSector => _selectedSector;
  String get searchQuery => _searchQuery;
  String get selectedTimeframe => _selectedTimeframe;

  // Callback to inform other engines (e.g. Trading engine for Limit orders & Alerts)
  Function(List<StockModel>)? onTickUpdated;

  MarketProvider() {
    _init();
  }

  void _init() {
    _marketDataService.initializeUniverse();
    startSimulation();
  }

  void startSimulation() {
    _tickTimer?.cancel();
    _isLiveStreaming = true;
    _tickTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.marketTickIntervalMs),
      (_) {
        if (_isLiveStreaming) {
          _marketDataService.simulateNextTick();
          notifyListeners();
          onTickUpdated?.call(_marketDataService.stocks);
        }
      },
    );
  }

  Future<bool> syncLiveAPI() async {
    final success = await _marketDataService.fetchLiveMarketQuotesFromAPI();
    notifyListeners();
    onTickUpdated?.call(_marketDataService.stocks);
    return success;
  }

  void toggleLiveStream() {
    _isLiveStreaming = !_isLiveStreaming;
    notifyListeners();
  }

  void setSector(String sector) {
    _selectedSector = sector;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTimeframe(String tf) {
    _selectedTimeframe = tf;
    notifyListeners();
  }

  List<StockModel> get filteredStocks {
    return _marketDataService.stocks.where((stock) {
      final matchesSector = _selectedSector == 'All Sectors' || stock.sector == _selectedSector;
      final matchesSearch = _searchQuery.isEmpty ||
          stock.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          stock.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSector && matchesSearch;
    }).toList();
  }

  List<StockModel> get topGainers {
    final list = List<StockModel>.from(_marketDataService.stocks);
    list.sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return list.take(5).toList();
  }

  List<StockModel> get topLosers {
    final list = List<StockModel>.from(_marketDataService.stocks);
    list.sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return list.take(5).toList();
  }

  List<StockModel> get mostActive {
    final list = List<StockModel>.from(_marketDataService.stocks);
    list.sort((a, b) => b.volume.compareTo(a.volume));
    return list.take(5).toList();
  }

  StockModel? getStockBySymbol(String symbol) {
    try {
      return _marketDataService.stocks.firstWhere((s) => s.symbol.toUpperCase() == symbol.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  List<CandleModel> getStockCandles(String symbol, String timeframe) {
    final stock = getStockBySymbol(symbol);
    if (stock == null) return [];
    return stock.historicalCandles[timeframe] ?? stock.historicalCandles['1D'] ?? [];
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}
