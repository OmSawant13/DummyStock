class PositionModel {
  final String symbol;
  final String stockName;
  final String sector;
  int quantity;
  double averageBuyPrice;
  double totalInvested;

  PositionModel({
    required this.symbol,
    required this.stockName,
    required this.sector,
    required this.quantity,
    required this.averageBuyPrice,
    required this.totalInvested,
  });

  double getCurrentValue(double currentPrice) => quantity * currentPrice;
  double getUnrealizedPnL(double currentPrice) => getCurrentValue(currentPrice) - totalInvested;
  double getUnrealizedPnLPercent(double currentPrice) =>
      totalInvested == 0 ? 0.0 : (getUnrealizedPnL(currentPrice) / totalInvested) * 100;

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'stockName': stockName,
    'sector': sector,
    'quantity': quantity,
    'averageBuyPrice': averageBuyPrice,
    'totalInvested': totalInvested,
  };

  factory PositionModel.fromJson(Map<String, dynamic> json) => PositionModel(
    symbol: json['symbol'],
    stockName: json['stockName'],
    sector: json['sector'],
    quantity: json['quantity'],
    averageBuyPrice: (json['averageBuyPrice'] as num).toDouble(),
    totalInvested: (json['totalInvested'] as num).toDouble(),
  );
}

class ClosedTradeModel {
  final String id;
  final String symbol;
  final String stockName;
  final int quantity;
  final double buyPrice;
  final double sellPrice;
  final double realizedPnL;
  final double realizedPnLPercent;
  final DateTime closedAt;

  ClosedTradeModel({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    required this.realizedPnL,
    required this.realizedPnLPercent,
    required this.closedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'stockName': stockName,
    'quantity': quantity,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'realizedPnL': realizedPnL,
    'realizedPnLPercent': realizedPnLPercent,
    'closedAt': closedAt.toIso8601String(),
  };

  factory ClosedTradeModel.fromJson(Map<String, dynamic> json) => ClosedTradeModel(
    id: json['id'],
    symbol: json['symbol'],
    stockName: json['stockName'],
    quantity: json['quantity'],
    buyPrice: (json['buyPrice'] as num).toDouble(),
    sellPrice: (json['sellPrice'] as num).toDouble(),
    realizedPnL: (json['realizedPnL'] as num).toDouble(),
    realizedPnLPercent: (json['realizedPnLPercent'] as num).toDouble(),
    closedAt: DateTime.parse(json['closedAt']),
  );
}
