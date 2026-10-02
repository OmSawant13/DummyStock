import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../models/price_alert_model.dart';
import '../../models/stock_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/price_alert_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/charts/sparkline_chart_widget.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/stat_badge.dart';
import '../../widgets/trading/order_execution_sheet.dart';
import '../market/stock_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final alertProvider = context.watch<PriceAlertProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final watchlistedStocks = market.allStocks
        .where((s) => watchlist.isInWatchlist(s.symbol))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist & Alerts', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.darkTextMuted,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'My Watchlist (${watchlistedStocks.length})'),
                  Tab(text: 'Price Alerts (${alertProvider.alerts.length})'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWatchlistTab(watchlistedStocks, watchlist, context),
                  _buildAlertsTab(alertProvider, market, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistTab(
    List<StockModel> stocks,
    WatchlistProvider watchlist,
    BuildContext context,
  ) {
    if (stocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline_rounded, size: 54, color: Colors.grey.withOpacity(0.35)),
            const SizedBox(height: 12),
            const Text('Your Watchlist is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Bookmark favorite tickers from the Market tab to monitor real-time trends.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final isPositive = stock.isPositive;

        return Dismissible(
          key: Key(stock.symbol),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.bearRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) {
            watchlist.toggleWatchlist(stock.symbol);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Removed ${stock.symbol} from watchlist')),
            );
          },
          child: CustomCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: stock.symbol)),
              );
            },
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stock.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(
                        stock.name,
                        style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: SparklineChartWidget(
                      points: stock.sparkline,
                      isPositive: isPositive,
                      width: 70,
                      height: 28,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(stock.currentPrice),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      StatBadge(
                        label: '',
                        value: CurrencyFormatter.formatPercent(stock.changePercent),
                        isPositive: isPositive,
                        isNegative: !isPositive,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.primaryLight),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => OrderExecutionSheet(stock: stock, initialSide: OrderSide.buy),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertsTab(
    PriceAlertProvider alertProvider,
    MarketProvider market,
    BuildContext context,
  ) {
    if (alertProvider.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 54, color: Colors.grey.withOpacity(0.35)),
            const SizedBox(height: 12),
            const Text('No Price Alerts Configured', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Set target price triggers from any stock page to stay on top of market breakouts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: alertProvider.alerts.length,
      itemBuilder: (context, index) {
        final alert = alertProvider.alerts[index];
        final stock = market.getStockBySymbol(alert.symbol);
        final currentPrice = stock?.currentPrice ?? 0.0;
        final isTriggered = alert.isTriggered;

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(alert.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isTriggered ? AppColors.bullGreen : AppColors.primary).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isTriggered ? 'TRIGGERED' : 'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isTriggered ? AppColors.bullGreen : AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${alert.condition == AlertCondition.aboveOrEqual ? 'Price ≥' : 'Price ≤'} ${CurrencyFormatter.format(alert.targetPrice)} (CMP: ${CurrencyFormatter.format(currentPrice)})',
                    style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                  ),
                  if (isTriggered && alert.triggeredAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Fired at: ${DateFormat('MMM dd, HH:mm').format(alert.triggeredAt!)}',
                      style: const TextStyle(fontSize: 10, color: AppColors.bullGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.bearRed),
                onPressed: () => alertProvider.removeAlert(alert.id),
              ),
            ],
          ),
        );
      },
    );
  }
}
