import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/price_alert_model.dart';
import '../models/stock_model.dart';
import '../services/storage_service.dart';

class PriceAlertProvider with ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();
  List<PriceAlertModel> _alerts = [];
  PriceAlertModel? _latestTriggeredAlert;

  List<PriceAlertModel> get alerts => _alerts;
  List<PriceAlertModel> get activeAlerts => _alerts.where((a) => !a.isTriggered).toList();
  List<PriceAlertModel> get triggeredAlerts => _alerts.where((a) => a.isTriggered).toList();
  PriceAlertModel? get latestTriggeredAlert => _latestTriggeredAlert;

  PriceAlertProvider(this._storageService) {
    _alerts = _storageService.getAlerts();
  }

  void addAlert({
    required String symbol,
    required String stockName,
    required double targetPrice,
    required AlertCondition condition,
  }) {
    final alert = PriceAlertModel(
      id: _uuid.v4(),
      symbol: symbol,
      stockName: stockName,
      targetPrice: targetPrice,
      condition: condition,
      createdAt: DateTime.now(),
    );
    _alerts.insert(0, alert);
    _storageService.saveAlerts(_alerts);
    notifyListeners();
  }

  void removeAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
    _storageService.saveAlerts(_alerts);
    notifyListeners();
  }

  void checkPriceAlerts(List<StockModel> stocks) {
    bool hasUpdates = false;
    for (var alert in activeAlerts) {
      final stock = stocks.where((s) => s.symbol.toUpperCase() == alert.symbol.toUpperCase()).firstOrNull;
      if (stock != null) {
        bool triggered = false;
        if (alert.condition == AlertCondition.aboveOrEqual && stock.currentPrice >= alert.targetPrice) {
          triggered = true;
        } else if (alert.condition == AlertCondition.belowOrEqual && stock.currentPrice <= alert.targetPrice) {
          triggered = true;
        }

        if (triggered) {
          alert.isTriggered = true;
          alert.triggeredAt = DateTime.now();
          _latestTriggeredAlert = alert;
          hasUpdates = true;
        }
      }
    }

    if (hasUpdates) {
      _storageService.saveAlerts(_alerts);
      notifyListeners();
    }
  }

  void clearLatestTriggered() {
    _latestTriggeredAlert = null;
    notifyListeners();
  }
}
