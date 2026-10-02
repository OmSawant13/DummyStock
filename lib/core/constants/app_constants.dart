class AppConstants {
  static const String appName = 'QuantSim Trade';
  static const String appTagline = 'Smart Stock Trading & EdTech Simulation';
  static const double initialVirtualCash = 100000.00; // $100,000 USD default
  static const double simulatedBrokerageRate = 0.0005; // 0.05% brokerage fee
  static const int marketTickIntervalMs = 2000; // 2 seconds update cycle

  // Sectors
  static const List<String> stockSectors = [
    'All Sectors',
    'Technology',
    'Financials',
    'Healthcare',
    'Consumer Discretionary',
    'Energy',
    'Automotive',
    'Semiconductors',
  ];

  // Timeframes for Candlestick Charts
  static const List<String> chartTimeframes = [
    '1D',
    '1W',
    '1M',
    '1Y',
    'ALL',
  ];
}
