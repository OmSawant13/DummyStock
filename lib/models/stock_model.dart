import 'candle_model.dart';

class StockModel {
  final String symbol;
  final String name;
  final String sector;
  double currentPrice;
  double openPrice;
  double highPrice;
  double lowPrice;
  double previousClose;
  double volume;
  final double marketCap;
  final double peRatio;
  final double week52High;
  final double week52Low;
  final double beta;
  final String description;
  List<double> sparkline;
  Map<String, List<CandleModel>> historicalCandles;

  StockModel({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.currentPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.previousClose,
    required this.volume,
    required this.marketCap,
    required this.peRatio,
    required this.week52High,
    required this.week52Low,
    required this.beta,
    required this.description,
    required this.sparkline,
    required this.historicalCandles,
  });

  double get change => currentPrice - previousClose;
  double get changePercent => previousClose == 0 ? 0.0 : (change / previousClose) * 100;
  bool get isPositive => change >= 0;

  // Bid / Ask spread simulation
  double get bestBid => currentPrice * 0.9995;
  double get bestAsk => currentPrice * 1.0005;

  StockModel copyWith({
    double? currentPrice,
    double? highPrice,
    double? lowPrice,
    double? volume,
    List<double>? sparkline,
    Map<String, List<CandleModel>>? historicalCandles,
  }) {
    return StockModel(
      symbol: symbol,
      name: name,
      sector: sector,
      currentPrice: currentPrice ?? this.currentPrice,
      openPrice: openPrice,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      previousClose: previousClose,
      volume: volume ?? this.volume,
      marketCap: marketCap,
      peRatio: peRatio,
      week52High: week52High,
      week52Low: week52Low,
      beta: beta,
      description: description,
      sparkline: sparkline ?? this.sparkline,
      historicalCandles: historicalCandles ?? this.historicalCandles,
    );
  }
}

class MarketIndexModel {
  final String name;
  final String symbol;
  double value;
  double change;
  double changePercent;
  List<double> sparkline;

  MarketIndexModel({
    required this.name,
    required this.symbol,
    required this.value,
    required this.change,
    required this.changePercent,
    required this.sparkline,
  });
}
