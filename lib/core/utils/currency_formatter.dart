import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.00');

  static String format(double value, {String symbol = '\$'}) {
    if (symbol != '\$') {
      return '$symbol${_numberFormat.format(value)}';
    }
    return _currencyFormat.format(value);
  }

  static String formatCompact(double value, {String symbol = '\$'}) {
    if (symbol != '\$') {
      return '$symbol${NumberFormat.compact().format(value)}';
    }
    return _compactCurrency.format(value);
  }

  static String formatChange(double change, double changePercent, {String symbol = '\$'}) {
    final prefix = change >= 0 ? '+' : '';
    return '$prefix${format(change, symbol: symbol)} ($prefix${changePercent.toStringAsFixed(2)}%)';
  }

  static String formatPercent(double percent, {bool includeSign = true}) {
    final prefix = (includeSign && percent >= 0) ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }
}
