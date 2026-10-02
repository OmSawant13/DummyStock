import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../models/price_alert_model.dart';
import '../../models/stock_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/price_alert_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/charts/candlestick_chart_widget.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/stat_badge.dart';
import '../../widgets/trading/order_book_widget.dart';
import '../../widgets/trading/order_execution_sheet.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String _selectedTimeframe = '1D';
  bool _showSMA = true;
  bool _showRSI = false;
  bool _showVolume = true;

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stock = marketProvider.getStockBySymbol(widget.symbol);

    if (stock == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stock Details')),
        body: const Center(child: Text('Stock symbol not found')),
      );
    }

    final isPositive = stock.isPositive;
    final isWatchlisted = watchlistProvider.isInWatchlist(stock.symbol);
    final candles = marketProvider.getStockCandles(stock.symbol, _selectedTimeframe);

    // Calculate day's range ratio for the slider
    final dayRange = stock.highPrice - stock.lowPrice;
    final dayProgress = dayRange > 0 ? ((stock.currentPrice - stock.lowPrice) / dayRange).clamp(0.0, 1.0) : 0.5;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(stock.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                      ),
                      child: Text(
                        stock.sector.split(' ').first.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.darkTextMuted),
                      ),
                    ),
                  ],
                ),
                Text(
                  stock.name,
                  style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWatchlisted ? Icons.star_rounded : Icons.star_border_rounded,
              color: isWatchlisted ? AppColors.gold : null,
              size: 22,
            ),
            tooltip: isWatchlisted ? 'Remove from Watchlist' : 'Add to Watchlist',
            onPressed: () {
              watchlistProvider.toggleWatchlist(stock.symbol);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isWatchlisted
                        ? 'Removed ${stock.symbol} from Watchlist'
                        : 'Added ${stock.symbol} to Watchlist',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, size: 20),
            tooltip: 'Set Price Alert',
            onPressed: () => _showAddAlertDialog(context, stock),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live Price & Day Range Hero Card
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.format(stock.currentPrice),
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                                color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                                size: 20,
                              ),
                              Text(
                                '${CurrencyFormatter.format(stock.change)} (${stock.changePercent.abs().toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.darkTextMuted)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isPositive ? AppColors.bullGreen : AppColors.bearRed).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: (isPositive ? AppColors.bullGreen : AppColors.bearRed).withOpacity(0.3)),
                        ),
                        child: Text(
                          isPositive ? 'BULLISH' : 'BEARISH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.darkCardBorder),
                  const SizedBox(height: 12),

                  // Day Range Visualizer Meter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DAY LOW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted)),
                          const SizedBox(height: 2),
                          Text(CurrencyFormatter.format(stock.lowPrice), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: dayProgress,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.bearRed, AppColors.bullGreen],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('24H RANGE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted)),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('DAY HIGH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted)),
                          const SizedBox(height: 2),
                          Text(CurrencyFormatter.format(stock.highPrice), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Timeframe Selector & Technical Indicator Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timeframes
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                  ),
                  child: Row(
                    children: AppConstants.chartTimeframes.map((tf) {
                      final isSelected = _selectedTimeframe == tf;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTimeframe = tf),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tf,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.darkTextMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Indicator Toggles
                Row(
                  children: [
                    _buildIndicatorPill('SMA (20)', _showSMA, () => setState(() => _showSMA = !_showSMA)),
                    const SizedBox(width: 6),
                    _buildIndicatorPill('RSI (14)', _showRSI, () => setState(() => _showRSI = !_showRSI)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Interactive Candlestick Chart Widget
            CustomCard(
              padding: const EdgeInsets.all(12),
              child: CandlestickChartWidget(
                candles: candles,
                symbol: stock.symbol,
                showSMA: _showSMA,
                showRSI: _showRSI,
                showVolume: _showVolume,
              ),
            ),
            const SizedBox(height: 14),

            // Market Depth Level 2 Order Book Ladder
            OrderBookWidget(stock: stock),
            const SizedBox(height: 14),

            // Company Statistics & Valuation Grid
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VALUATION & MARKET METRICS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildMetricTile('Market Cap', CurrencyFormatter.formatCompact(stock.marketCap))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('P/E Ratio', '${stock.peRatio.toStringAsFixed(1)}x')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricTile('52-Week High', CurrencyFormatter.format(stock.week52High))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('52-Week Low', CurrencyFormatter.format(stock.week52Low))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricTile('Beta (Volatility)', stock.beta.toStringAsFixed(2))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('24h Volume', CurrencyFormatter.formatCompact(stock.volume, symbol: ''))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Company Overview / EdTech Bio
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COMPANY PROFILE & FUNDAMENTALS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stock.description,
                    style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 85), // Space for bottom action bar
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bullGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => _openOrderSheet(context, stock, OrderSide.buy),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('BUY / LONG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bearRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => _openOrderSheet(context, stock, OrderSide.sell),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('SELL / SHORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.darkTextMuted)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildIndicatorPill(String title, bool isActive, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.18) : (isDark ? AppColors.darkInputBg : AppColors.lightInputBg),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? AppColors.primaryLight : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isActive ? AppColors.primaryLight : AppColors.darkTextMuted,
          ),
        ),
      ),
    );
  }

  void _openOrderSheet(BuildContext context, StockModel stock, OrderSide side) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderExecutionSheet(stock: stock, initialSide: side),
    );
  }

  void _showAddAlertDialog(BuildContext context, StockModel stock) {
    final controller = TextEditingController(text: stock.currentPrice.toStringAsFixed(2));
    AlertCondition condition = AlertCondition.aboveOrEqual;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Price Alert for ${stock.symbol}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current price: ${CurrencyFormatter.format(stock.currentPrice)}'),
                const SizedBox(height: 14),
                DropdownButtonFormField<AlertCondition>(
                  value: condition,
                  items: const [
                    DropdownMenuItem(
                      value: AlertCondition.aboveOrEqual,
                      child: Text('Price rises to or above (>=)'),
                    ),
                    DropdownMenuItem(
                      value: AlertCondition.belowOrEqual,
                      child: Text('Price drops to or below (<=)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => condition = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Target Price (\$)',
                    prefixText: '\$',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  final target = double.tryParse(controller.text) ?? stock.currentPrice;
                  context.read<PriceAlertProvider>().addAlert(
                    symbol: stock.symbol,
                    stockName: stock.name,
                    targetPrice: target,
                    condition: condition,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Price alert set for ${stock.symbol} at \$${target.toStringAsFixed(2)}'),
                      backgroundColor: AppColors.bullGreenDark,
                    ),
                  );
                },
                child: const Text('Set Alert'),
              ),
            ],
          );
        },
      ),
    );
  }
}
