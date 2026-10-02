enum AlertCondition {
  aboveOrEqual,
  belowOrEqual,
}

class PriceAlertModel {
  final String id;
  final String symbol;
  final String stockName;
  final double targetPrice;
  final AlertCondition condition;
  final DateTime createdAt;
  bool isTriggered;
  DateTime? triggeredAt;

  PriceAlertModel({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.targetPrice,
    required this.condition,
    required this.createdAt,
    this.isTriggered = false,
    this.triggeredAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'stockName': stockName,
    'targetPrice': targetPrice,
    'condition': condition.name,
    'createdAt': createdAt.toIso8601String(),
    'isTriggered': isTriggered,
    'triggeredAt': triggeredAt?.toIso8601String(),
  };

  factory PriceAlertModel.fromJson(Map<String, dynamic> json) => PriceAlertModel(
    id: json['id'],
    symbol: json['symbol'],
    stockName: json['stockName'],
    targetPrice: (json['targetPrice'] as num).toDouble(),
    condition: AlertCondition.values.byName(json['condition']),
    createdAt: DateTime.parse(json['createdAt']),
    isTriggered: json['isTriggered'] ?? false,
    triggeredAt: json['triggeredAt'] != null ? DateTime.parse(json['triggeredAt']) : null,
  );
}
