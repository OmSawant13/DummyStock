enum TransactionType {
  stockBuy,
  stockSell,
  depositCash,
  resetWallet,
  competitionReward,
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final String title;
  final String? symbol;
  final int? quantity;
  final double? pricePerShare;
  final double amount;
  final double balanceAfter;
  final double brokerageFee;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    this.symbol,
    this.quantity,
    this.pricePerShare,
    required this.amount,
    required this.balanceAfter,
    this.brokerageFee = 0.0,
    required this.timestamp,
  });

  bool get isCredit => type == TransactionType.stockSell || type == TransactionType.depositCash || type == TransactionType.competitionReward;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'symbol': symbol,
    'quantity': quantity,
    'pricePerShare': pricePerShare,
    'amount': amount,
    'balanceAfter': balanceAfter,
    'brokerageFee': brokerageFee,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'],
    type: TransactionType.values.byName(json['type']),
    title: json['title'],
    symbol: json['symbol'],
    quantity: json['quantity'],
    pricePerShare: (json['pricePerShare'] as num?)?.toDouble(),
    amount: (json['amount'] as num).toDouble(),
    balanceAfter: (json['balanceAfter'] as num).toDouble(),
    brokerageFee: (json['brokerageFee'] as num?)?.toDouble() ?? 0.0,
    timestamp: DateTime.parse(json['timestamp']),
  );
}
