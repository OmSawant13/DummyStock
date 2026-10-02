import '../../models/candle_model.dart';

class TechnicalIndicators {
  /// Calculate Simple Moving Average (SMA)
  static List<double?> calculateSMA(List<CandleModel> candles, int period) {
    List<double?> sma = List.filled(candles.length, null);
    if (candles.length < period) return sma;

    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += candles[i].close;
    }
    sma[period - 1] = sum / period;

    for (int i = period; i < candles.length; i++) {
      sum += candles[i].close - candles[i - period].close;
      sma[i] = sum / period;
    }

    return sma;
  }

  /// Calculate Relative Strength Index (RSI)
  static List<double?> calculateRSI(List<CandleModel> candles, {int period = 14}) {
    List<double?> rsiList = List.filled(candles.length, null);
    if (candles.length <= period) return rsiList;

    double gainSum = 0.0;
    double lossSum = 0.0;

    for (int i = 1; i <= period; i++) {
      double diff = candles[i].close - candles[i - 1].close;
      if (diff >= 0) {
        gainSum += diff;
      } else {
        lossSum += diff.abs();
      }
    }

    double avgGain = gainSum / period;
    double avgLoss = lossSum / period;

    if (avgLoss == 0) {
      rsiList[period] = 100.0;
    } else {
      double rs = avgGain / avgLoss;
      rsiList[period] = 100.0 - (100.0 / (1.0 + rs));
    }

    for (int i = period + 1; i < candles.length; i++) {
      double diff = candles[i].close - candles[i - 1].close;
      double gain = diff > 0 ? diff : 0.0;
      double loss = diff < 0 ? diff.abs() : 0.0;

      avgGain = ((avgGain * (period - 1)) + gain) / period;
      avgLoss = ((avgLoss * (period - 1)) + loss) / period;

      if (avgLoss == 0) {
        rsiList[i] = 100.0;
      } else {
        double rs = avgGain / avgLoss;
        rsiList[i] = 100.0 - (100.0 / (1.0 + rs));
      }
    }

    return rsiList;
  }
}
