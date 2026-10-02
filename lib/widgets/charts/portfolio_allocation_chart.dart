import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/position_model.dart';
import '../../models/stock_model.dart';

class PortfolioAllocationChart extends StatefulWidget {
  final List<PositionModel> positions;
  final List<StockModel> stocks;
  final double walletBalance;

  const PortfolioAllocationChart({
    super.key,
    required this.positions,
    required this.stocks,
    required this.walletBalance,
  });

  @override
  State<PortfolioAllocationChart> createState() => _PortfolioAllocationChartState();
}

class _PortfolioAllocationChartState extends State<PortfolioAllocationChart> {
  int _touchedIndex = -1;

  final List<Color> _palette = [
    AppColors.primaryLight,
    AppColors.bullGreen,
    AppColors.purple,
    AppColors.accent,
    AppColors.gold,
    AppColors.secondary,
    const Color(0xFFF97316),
    const Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate Holdings values
    Map<String, double> sectorAllocations = {};
    sectorAllocations['Cash'] = widget.walletBalance;

    for (var pos in widget.positions) {
      final stock = widget.stocks.where((s) => s.symbol == pos.symbol).firstOrNull;
      final value = stock != null ? pos.getCurrentValue(stock.currentPrice) : pos.totalInvested;
      sectorAllocations[pos.symbol] = (sectorAllocations[pos.symbol] ?? 0) + value;
    }

    final totalVal = sectorAllocations.values.fold(0.0, (a, b) => a + b);
    if (totalVal == 0) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No assets to display')),
      );
    }

    final entries = sectorAllocations.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 45,
              sections: List.generate(entries.length, (i) {
                final isTouched = i == _touchedIndex;
                final fontSize = isTouched ? 14.0 : 11.0;
                final radius = isTouched ? 48.0 : 40.0;
                final entry = entries[i];
                final percentage = (entry.value / totalVal) * 100;
                final color = entry.key == 'Cash'
                    ? (isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8))
                    : _palette[i % _palette.length];

                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            final entry = entries[i];
            final color = entry.key == 'Cash'
                ? (isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8))
                : _palette[i % _palette.length];
            final percent = (entry.value / totalVal) * 100;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${entry.key}: ',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${CurrencyFormatter.formatCompact(entry.value)} (${percent.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextMuted,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
