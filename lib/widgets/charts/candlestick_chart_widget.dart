import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/technical_indicators.dart';
import '../../models/candle_model.dart';

class CandlestickChartWidget extends StatefulWidget {
  final List<CandleModel> candles;
  final String symbol;
  final bool showSMA;
  final bool showRSI;
  final bool showVolume;

  const CandlestickChartWidget({
    super.key,
    required this.candles,
    required this.symbol,
    this.showSMA = true,
    this.showRSI = false,
    this.showVolume = true,
  });

  @override
  State<CandlestickChartWidget> createState() => _CandlestickChartWidgetState();
}

class _CandlestickChartWidgetState extends State<CandlestickChartWidget> {
  int? _hoveredIndex;
  Offset? _touchPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(child: Text('No historical data available')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<double?> sma20 = widget.showSMA
        ? TechnicalIndicators.calculateSMA(widget.candles, 14)
        : [];
    final List<double?> rsi14 = widget.showRSI
        ? TechnicalIndicators.calculateRSI(widget.candles, period: 14)
        : [];

    final activeIndex = _hoveredIndex != null &&
            _hoveredIndex! >= 0 &&
            _hoveredIndex! < widget.candles.length
        ? _hoveredIndex!
        : widget.candles.length - 1;
    final activeCandle = widget.candles[activeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Candle Inspect Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildMetric('O', CurrencyFormatter.format(activeCandle.open)),
              _buildMetric('H', CurrencyFormatter.format(activeCandle.high)),
              _buildMetric('L', CurrencyFormatter.format(activeCandle.low)),
              _buildMetric(
                'C',
                CurrencyFormatter.format(activeCandle.close),
                color: activeCandle.isBullish ? AppColors.bullGreen : AppColors.bearRed,
              ),
              _buildMetric('Vol', NumberFormat.compact().format(activeCandle.volume)),
              Text(
                DateFormat('MMM dd, HH:mm').format(activeCandle.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Candlestick Canvas
        SizedBox(
          height: widget.showRSI ? 340 : 280,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              _handleTouch(details.localPosition);
            },
            onHorizontalDragStart: (details) {
              _handleTouch(details.localPosition);
            },
            onHorizontalDragEnd: (_) {
              setState(() {
                _hoveredIndex = null;
                _touchPosition = null;
              });
            },
            onTapDown: (details) {
              _handleTouch(details.localPosition);
            },
            onTapUp: (_) {
              setState(() {
                _hoveredIndex = null;
                _touchPosition = null;
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: _CandlestickPainter(
                candles: widget.candles,
                smaValues: sma20,
                rsiValues: rsi14,
                showVolume: widget.showVolume,
                showRSI: widget.showRSI,
                hoveredIndex: _hoveredIndex,
                touchPosition: _touchPosition,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTouch(Offset localPos) {
    if (widget.candles.isEmpty) return;
    final width = context.size?.width ?? 350;
    final candleWidth = width / widget.candles.length;
    int index = (localPos.dx / candleWidth).clamp(0, widget.candles.length - 1).toInt();

    setState(() {
      _hoveredIndex = index;
      _touchPosition = localPos;
    });
  }

  Widget _buildMetric(String label, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.darkTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  final List<CandleModel> candles;
  final List<double?> smaValues;
  final List<double?> rsiValues;
  final bool showVolume;
  final bool showRSI;
  final int? hoveredIndex;
  final Offset? touchPosition;
  final bool isDark;

  _CandlestickPainter({
    required this.candles,
    required this.smaValues,
    required this.rsiValues,
    required this.showVolume,
    required this.showRSI,
    required this.hoveredIndex,
    required this.touchPosition,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final rsiHeight = showRSI ? 70.0 : 0.0;
    final volumeHeight = showVolume ? 45.0 : 0.0;
    final mainChartHeight = size.height - rsiHeight - volumeHeight - 20;

    double maxPrice = candles.map((c) => c.high).reduce(math.max);
    double minPrice = candles.map((c) => c.low).reduce(math.min);
    double maxVolume = candles.map((c) => c.volume).reduce(math.max);

    // Padding on price bounds
    final priceRange = (maxPrice - minPrice).abs();
    maxPrice += priceRange * 0.05;
    minPrice -= priceRange * 0.05;
    if (maxPrice == minPrice) {
      maxPrice += 1;
      minPrice -= 1;
    }

    final candleSlotWidth = size.width / candles.length;
    final candleBarWidth = math.max(2.0, candleSlotWidth * 0.65);

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw Price Horizontal Gridlines
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = (mainChartHeight / gridLines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final priceLabel = maxPrice - ((maxPrice - minPrice) / gridLines * i);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$${priceLabel.toStringAsFixed(1)}',
          style: TextStyle(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width - textPainter.width - 4, y - textPainter.height - 2));
    }

    // Draw Candlesticks & Volume Bars
    final bullPaint = Paint()..color = AppColors.bullGreen;
    final bearPaint = Paint()..color = AppColors.bearRed;
    final bullVolPaint = Paint()..color = AppColors.bullGreen.withOpacity(0.35);
    final bearVolPaint = Paint()..color = AppColors.bearRed.withOpacity(0.35);

    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      final xCenter = (i * candleSlotWidth) + (candleSlotWidth / 2);

      // Candlestick coordinates
      final yHigh = mainChartHeight - ((c.high - minPrice) / (maxPrice - minPrice) * mainChartHeight);
      final yLow = mainChartHeight - ((c.low - minPrice) / (maxPrice - minPrice) * mainChartHeight);
      final yOpen = mainChartHeight - ((c.open - minPrice) / (maxPrice - minPrice) * mainChartHeight);
      final yClose = mainChartHeight - ((c.close - minPrice) / (maxPrice - minPrice) * mainChartHeight);

      final isBull = c.isBullish;
      final paint = isBull ? bullPaint : bearPaint;

      // Draw Upper and Lower Wick
      final wickPaint = Paint()
        ..color = paint.color
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(xCenter, yHigh), Offset(xCenter, yLow), wickPaint);

      // Draw Candle Body
      final bodyTop = math.min(yOpen, yClose);
      final bodyBottom = math.max(yOpen, yClose);
      final bodyHeight = math.max(2.0, bodyBottom - bodyTop);

      final candleRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(xCenter, bodyTop + (bodyHeight / 2)),
          width: candleBarWidth,
          height: bodyHeight,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(candleRect, paint);

      // Draw Volume Bar
      if (showVolume && maxVolume > 0) {
        final volBarHeight = (c.volume / maxVolume) * (volumeHeight - 5);
        final volTop = mainChartHeight + volumeHeight - volBarHeight;
        final volRect = Rect.fromLTWH(
          xCenter - (candleBarWidth / 2),
          volTop,
          candleBarWidth,
          volBarHeight,
        );
        canvas.drawRect(volRect, isBull ? bullVolPaint : bearVolPaint);
      }
    }

    // Draw SMA 20 Overlay Line
    if (smaValues.isNotEmpty) {
      final smaPaint = Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final smaPath = Path();
      bool started = false;

      for (int i = 0; i < candles.length; i++) {
        final sma = smaValues[i];
        if (sma != null) {
          final x = (i * candleSlotWidth) + (candleSlotWidth / 2);
          final y = mainChartHeight - ((sma - minPrice) / (maxPrice - minPrice) * mainChartHeight);
          if (!started) {
            smaPath.moveTo(x, y);
            started = true;
          } else {
            smaPath.lineTo(x, y);
          }
        }
      }
      canvas.drawPath(smaPath, smaPaint);
    }

    // Draw RSI Sub-chart
    if (showRSI && rsiValues.isNotEmpty) {
      final rsiTop = size.height - rsiHeight;
      final rsiBgPaint = Paint()..color = (isDark ? Colors.black : Colors.white).withOpacity(0.2);
      canvas.drawRect(Rect.fromLTWH(0, rsiTop, size.width, rsiHeight), rsiBgPaint);

      // RSI 70 & 30 Reference Lines
      final rsi30Y = rsiTop + (rsiHeight * 0.7);
      final rsi70Y = rsiTop + (rsiHeight * 0.3);
      final rsiRefPaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawLine(Offset(0, rsi30Y), Offset(size.width, rsi30Y), rsiRefPaint);
      canvas.drawLine(Offset(0, rsi70Y), Offset(size.width, rsi70Y), rsiRefPaint);

      final rsiPath = Path();
      bool rsiStarted = false;
      final rsiLinePaint = Paint()
        ..color = AppColors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      for (int i = 0; i < candles.length; i++) {
        final rsi = rsiValues[i];
        if (rsi != null) {
          final x = (i * candleSlotWidth) + (candleSlotWidth / 2);
          final y = rsiTop + rsiHeight - ((rsi / 100.0) * rsiHeight);
          if (!rsiStarted) {
            rsiPath.moveTo(x, y);
            rsiStarted = true;
          } else {
            rsiPath.lineTo(x, y);
          }
        }
      }
      canvas.drawPath(rsiPath, rsiLinePaint);
    }

    // Draw Interactive Crosshair & Tooltip
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < candles.length) {
      final xCross = (hoveredIndex! * candleSlotWidth) + (candleSlotWidth / 2);
      final crosshairPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Vertical line
      canvas.drawLine(Offset(xCross, 0), Offset(xCross, size.height), crosshairPaint);

      if (touchPosition != null) {
        // Horizontal line
        canvas.drawLine(
          Offset(0, touchPosition!.dy.clamp(0, mainChartHeight)),
          Offset(size.width, touchPosition!.dy.clamp(0, mainChartHeight)),
          crosshairPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return true;
  }
}
