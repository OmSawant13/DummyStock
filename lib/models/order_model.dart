enum OrderType {
  market,
  limit,
  stopLoss,
  takeProfit,
}

enum OrderSide {
  buy,
  sell,
}

enum OrderStatus {
  pending,
  executed,
  cancelled,
  rejected,
}

class OrderModel {
  final String id;
  final String symbol;
  final String stockName;
  final OrderSide side;
  final OrderType type;
  final int quantity;
  final double targetPrice; // For Limit / SL / TP
  final double? executedPrice;
  final DateTime placedAt;
  DateTime? executedAt;
  OrderStatus status;
  final double brokerageFee;

  OrderModel({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.side,
    required this.type,
    required this.quantity,
    required this.targetPrice,
    this.executedPrice,
    required this.placedAt,
    this.executedAt,
    this.status = OrderStatus.pending,
    this.brokerageFee = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'stockName': stockName,
    'side': side.name,
    'type': type.name,
    'quantity': quantity,
    'targetPrice': targetPrice,
    'executedPrice': executedPrice,
    'placedAt': placedAt.toIso8601String(),
    'executedAt': executedAt?.toIso8601String(),
    'status': status.name,
    'brokerageFee': brokerageFee,
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    symbol: json['symbol'],
    stockName: json['stockName'],
    side: OrderSide.values.byName(json['side']),
    type: OrderType.values.byName(json['type']),
    quantity: json['quantity'],
    targetPrice: (json['targetPrice'] as num).toDouble(),
    executedPrice: json['executedPrice'] != null ? (json['executedPrice'] as num).toDouble() : null,
    placedAt: DateTime.parse(json['placedAt']),
    executedAt: json['executedAt'] != null ? DateTime.parse(json['executedAt']) : null,
    status: OrderStatus.values.byName(json['status']),
    brokerageFee: (json['brokerageFee'] as num?)?.toDouble() ?? 0.0,
  );
}
