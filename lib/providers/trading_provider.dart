import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/position_model.dart';
import '../models/transaction_model.dart';
import '../models/stock_model.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

class TradingProvider with ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  double _walletBalance = AppConstants.initialVirtualCash;
  List<PositionModel> _positions = [];
  List<OrderModel> _orders = [];
  List<TransactionModel> _transactions = [];
  List<ClosedTradeModel> _closedTrades = [];

  double get walletBalance => _walletBalance;
  List<PositionModel> get positions => _positions;
  List<OrderModel> get orders => _orders;
  List<OrderModel> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<TransactionModel> get transactions => _transactions;
  List<ClosedTradeModel> get closedTrades => _closedTrades;

  TradingProvider(this._storageService) {
    reloadUserData();
  }

  void reloadUserData() {
    _walletBalance = _storageService.getWalletBalance();
    _positions = _storageService.getPositions();
    _orders = _storageService.getOrders();
    _transactions = _storageService.getTransactions();
    _closedTrades = _storageService.getClosedTrades();

    // If transactions are empty, create initial deposit ledger
    if (_transactions.isEmpty) {
      final initialTx = TransactionModel(
        id: _uuid.v4(),
        type: TransactionType.depositCash,
        title: 'Initial Virtual Capital',
        amount: AppConstants.initialVirtualCash,
        balanceAfter: AppConstants.initialVirtualCash,
        timestamp: DateTime.now(),
      );
      _transactions.add(initialTx);
      _storageService.saveTransactions(_transactions);
    }
    notifyListeners();
  }

  // Portfolio Total Value & PnL
  double getTotalInvested() {
    return _positions.fold(0.0, (sum, pos) => sum + pos.totalInvested);
  }

  double getTotalHoldingsValue(List<StockModel> stocks) {
    double sum = 0.0;
    for (var pos in _positions) {
      final stock = _findStock(pos.symbol, stocks);
      if (stock != null) {
        sum += pos.getCurrentValue(stock.currentPrice);
      } else {
        sum += pos.totalInvested;
      }
    }
    return sum;
  }

  double getTotalPortfolioValue(List<StockModel> stocks) {
    return _walletBalance + getTotalHoldingsValue(stocks);
  }

  double getTotalUnrealizedPnL(List<StockModel> stocks) {
    double sum = 0.0;
    for (var pos in _positions) {
      final stock = _findStock(pos.symbol, stocks);
      if (stock != null) {
        sum += pos.getUnrealizedPnL(stock.currentPrice);
      }
    }
    return sum;
  }

  double getTotalRealizedPnL() {
    return _closedTrades.fold(0.0, (sum, trade) => sum + trade.realizedPnL);
  }

  double getTotalPnL(List<StockModel> stocks) {
    return getTotalUnrealizedPnL(stocks) + getTotalRealizedPnL();
  }

  double getTotalReturnsPercent(List<StockModel> stocks) {
    final netWorth = getTotalPortfolioValue(stocks);
    return ((netWorth - AppConstants.initialVirtualCash) / AppConstants.initialVirtualCash) * 100;
  }

  double getWinRate() {
    if (_closedTrades.isEmpty) return 0.0;
    final wins = _closedTrades.where((t) => t.realizedPnL > 0).length;
    return (wins / _closedTrades.length) * 100;
  }

  // Sharpe Ratio estimation (Simulated risk adjusted metric)
  double getSharpeRatio(List<StockModel> stocks) {
    if (_closedTrades.length < 2) return 1.42; // default healthy ratio baseline
    final returns = _closedTrades.map((t) => t.realizedPnLPercent).toList();
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns.map((r) => math.pow(r - mean, 2)).reduce((a, b) => a + b) / returns.length;
    final stdDev = math.sqrt(variance);
    if (stdDev == 0) return 1.0;
    const riskFreeRate = 0.04; // 4% annual risk free
    return (mean - riskFreeRate) / stdDev;
  }

  StockModel? _findStock(String symbol, List<StockModel> stocks) {
    try {
      return stocks.firstWhere((s) => s.symbol.toUpperCase() == symbol.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  // Place Order
  String? placeOrder({
    required StockModel stock,
    required OrderSide side,
    required OrderType type,
    required int quantity,
    required double targetPrice,
  }) {
    if (quantity <= 0) return 'Quantity must be greater than 0';

    final unitPrice = (type == OrderType.market) ? stock.currentPrice : targetPrice;
    final estimatedCost = quantity * unitPrice;
    final brokerage = estimatedCost * AppConstants.simulatedBrokerageRate;
    final totalCost = estimatedCost + brokerage;

    if (side == OrderSide.buy) {
      if (totalCost > _walletBalance) {
        return 'Insufficient virtual funds. Needed: \$${totalCost.toStringAsFixed(2)}, Available: \$${_walletBalance.toStringAsFixed(2)}';
      }
    } else {
      // Sell validation: check holding quantity
      final existingPos = _positions.firstWhere(
        (p) => p.symbol == stock.symbol,
        orElse: () => PositionModel(symbol: '', stockName: '', sector: '', quantity: 0, averageBuyPrice: 0, totalInvested: 0),
      );
      if (existingPos.quantity < quantity) {
        return 'Insufficient shares. You own ${existingPos.quantity} shares of ${stock.symbol}.';
      }
    }

    final order = OrderModel(
      id: _uuid.v4(),
      symbol: stock.symbol,
      stockName: stock.name,
      side: side,
      type: type,
      quantity: quantity,
      targetPrice: targetPrice,
      placedAt: DateTime.now(),
      brokerageFee: brokerage,
    );

    _orders.insert(0, order);

    // If Market order, execute immediately
    if (type == OrderType.market) {
      _executeOrder(order, stock.currentPrice, stock.sector);
    } else {
      // Limit, StopLoss, TakeProfit - check if already triggerable
      _checkOrderTrigger(order, stock.currentPrice, stock.sector);
    }

    _persistAll();
    notifyListeners();
    return null; // Success
  }

  void _executeOrder(OrderModel order, double execPrice, String sector) {
    final tradeAmount = order.quantity * execPrice;
    final brokerage = tradeAmount * AppConstants.simulatedBrokerageRate;

    order.status = OrderStatus.executed;
    order.executedAt = DateTime.now();

    if (order.side == OrderSide.buy) {
      final totalDeduction = tradeAmount + brokerage;
      _walletBalance -= totalDeduction;

      final existingIndex = _positions.indexWhere((p) => p.symbol == order.symbol);
      if (existingIndex >= 0) {
        final existing = _positions[existingIndex];
        final newQuantity = existing.quantity + order.quantity;
        final newTotalInvested = existing.totalInvested + tradeAmount;
        final newAvgPrice = newTotalInvested / newQuantity;

        existing.quantity = newQuantity;
        existing.totalInvested = newTotalInvested;
        existing.averageBuyPrice = newAvgPrice;
      } else {
        _positions.add(
          PositionModel(
            symbol: order.symbol,
            stockName: order.stockName,
            sector: sector,
            quantity: order.quantity,
            averageBuyPrice: execPrice,
            totalInvested: tradeAmount,
          ),
        );
      }

      // Record Transaction
      _transactions.insert(
        0,
        TransactionModel(
          id: _uuid.v4(),
          type: TransactionType.stockBuy,
          title: 'Bought ${order.quantity} ${order.symbol}',
          symbol: order.symbol,
          quantity: order.quantity,
          pricePerShare: execPrice,
          amount: totalDeduction,
          balanceAfter: _walletBalance,
          brokerageFee: brokerage,
          timestamp: DateTime.now(),
        ),
      );
    } else {
      // Sell Order Execution
      final netCredit = tradeAmount - brokerage;
      _walletBalance += netCredit;

      final existingIndex = _positions.indexWhere((p) => p.symbol == order.symbol);
      if (existingIndex >= 0) {
        final existing = _positions[existingIndex];
        final costBasis = existing.averageBuyPrice * order.quantity;
        final realizedPnL = tradeAmount - costBasis;
        final realizedPnLPercent = costBasis == 0 ? 0.0 : (realizedPnL / costBasis) * 100;

        _closedTrades.insert(
          0,
          ClosedTradeModel(
            id: _uuid.v4(),
            symbol: order.symbol,
            stockName: order.stockName,
            quantity: order.quantity,
            buyPrice: existing.averageBuyPrice,
            sellPrice: execPrice,
            realizedPnL: realizedPnL,
            realizedPnLPercent: realizedPnLPercent,
            closedAt: DateTime.now(),
          ),
        );

        if (existing.quantity == order.quantity) {
          _positions.removeAt(existingIndex);
        } else {
          existing.quantity -= order.quantity;
          existing.totalInvested -= costBasis;
        }
      }

      // Record Transaction
      _transactions.insert(
        0,
        TransactionModel(
          id: _uuid.v4(),
          type: TransactionType.stockSell,
          title: 'Sold ${order.quantity} ${order.symbol}',
          symbol: order.symbol,
          quantity: order.quantity,
          pricePerShare: execPrice,
          amount: netCredit,
          balanceAfter: _walletBalance,
          brokerageFee: brokerage,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _checkOrderTrigger(OrderModel order, double currentPrice, String sector) {
    if (order.status != OrderStatus.pending) return;

    bool shouldTrigger = false;
    switch (order.type) {
      case OrderType.limit:
        if (order.side == OrderSide.buy && currentPrice <= order.targetPrice) {
          shouldTrigger = true;
        } else if (order.side == OrderSide.sell && currentPrice >= order.targetPrice) {
          shouldTrigger = true;
        }
        break;
      case OrderType.stopLoss:
        if (order.side == OrderSide.sell && currentPrice <= order.targetPrice) {
          shouldTrigger = true;
        }
        break;
      case OrderType.takeProfit:
        if (order.side == OrderSide.sell && currentPrice >= order.targetPrice) {
          shouldTrigger = true;
        }
        break;
      case OrderType.market:
        break;
    }

    if (shouldTrigger) {
      _executeOrder(order, currentPrice, sector);
    }
  }

  // Cancel Pending Order
  void cancelOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0 && _orders[idx].status == OrderStatus.pending) {
      _orders[idx].status = OrderStatus.cancelled;
      _persistAll();
      notifyListeners();
    }
  }

  // Close Position at Market Price
  String? closePosition(PositionModel position, double currentPrice) {
    return placeOrder(
      stock: StockModel(
        symbol: position.symbol,
        name: position.stockName,
        sector: position.sector,
        currentPrice: currentPrice,
        openPrice: currentPrice,
        highPrice: currentPrice,
        lowPrice: currentPrice,
        previousClose: currentPrice,
        volume: 0,
        marketCap: 0,
        peRatio: 0,
        week52High: 0,
        week52Low: 0,
        beta: 0,
        description: '',
        sparkline: [],
        historicalCandles: {},
      ),
      side: OrderSide.sell,
      type: OrderType.market,
      quantity: position.quantity,
      targetPrice: currentPrice,
    );
  }

  // Called on each market tick
  void processMarketTick(List<StockModel> stocks) {
    bool hasChanges = false;
    for (var order in pendingOrders) {
      final stock = _findStock(order.symbol, stocks);
      if (stock != null) {
        final prevStatus = order.status;
        _checkOrderTrigger(order, stock.currentPrice, stock.sector);
        if (order.status != prevStatus) {
          hasChanges = true;
        }
      }
    }
    if (hasChanges) {
      _persistAll();
      notifyListeners();
    }
  }

  // Deposit Virtual Funds
  void depositFunds(double amount) {
    if (amount <= 0) return;
    _walletBalance += amount;
    _transactions.insert(
      0,
      TransactionModel(
        id: _uuid.v4(),
        type: TransactionType.depositCash,
        title: 'Virtual Top-up Deposit',
        amount: amount,
        balanceAfter: _walletBalance,
        timestamp: DateTime.now(),
      ),
    );
    _persistAll();
    notifyListeners();
  }

  // Reset Wallet and Simulation
  Future<void> resetSimulation() async {
    _walletBalance = AppConstants.initialVirtualCash;
    _positions.clear();
    _orders.clear();
    _transactions.clear();
    _closedTrades.clear();

    _transactions.add(
      TransactionModel(
        id: _uuid.v4(),
        type: TransactionType.resetWallet,
        title: 'Simulation Account Reset',
        amount: AppConstants.initialVirtualCash,
        balanceAfter: AppConstants.initialVirtualCash,
        timestamp: DateTime.now(),
      ),
    );

    await _storageService.resetUserState();
    _persistAll();
    notifyListeners();
  }

  void _persistAll() {
    _storageService.saveWalletBalance(_walletBalance);
    _storageService.savePositions(_positions);
    _storageService.saveOrders(_orders);
    _storageService.saveTransactions(_transactions);
    _storageService.saveClosedTrades(_closedTrades);
  }
}
