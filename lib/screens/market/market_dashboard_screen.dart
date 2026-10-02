import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../models/stock_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/trading_provider.dart';
import '../../widgets/charts/sparkline_chart_widget.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/trading/order_execution_sheet.dart';
import '../profile/user_profile_screen.dart';
import 'stock_detail_screen.dart';

class MarketDashboardScreen extends StatefulWidget {
  const MarketDashboardScreen({super.key});

  @override
  State<MarketDashboardScreen> createState() => _MarketDashboardScreenState();
}

class _MarketDashboardScreenState extends State<MarketDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final trading = context.watch<TradingProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allStocks = market.filteredStocks;
    final topGainers = market.topGainers;
    final topLosers = market.topLosers;
    final mostActive = market.mostActive;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.candlestick_chart_rounded, color: AppColors.primaryLight, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'QuantSim Market',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          // Live HTTP REST API Sync Button
          IconButton(
            icon: const Icon(Icons.sync_rounded, size: 20, color: AppColors.accent),
            tooltip: 'Sync Real Market Quotes (Yahoo Finance REST API)',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing live exchange feeds...'),
                  duration: Duration(seconds: 1),
                ),
              );
              final success = await market.syncLiveAPI();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Live market prices synced!' : 'Simulation engine active.'),
                    backgroundColor: AppColors.bullGreenDark,
                  ),
                );
              }
            },
          ),
          // User Profile
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 22),
            tooltip: 'Account & ID',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => market.startSimulation(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Index Ticker Ribbon
              Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: market.indices.length,
                  separatorBuilder: (_, __) => Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    color: AppColors.darkCardBorder,
                  ),
                  itemBuilder: (context, index) {
                    final idx = market.indices[index];
                    final isPos = idx.change >= 0;
                    return Row(
                      children: [
                        Text(
                          idx.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextPrimary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          idx.value.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${isPos ? "+" : ""}${idx.changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPos ? AppColors.bullGreen : AppColors.bearRed,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Funds & Account Summary Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AVAILABLE FUNDS',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(trading.walletBalance),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkTextPrimary),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 28, width: 1, color: AppColors.darkCardBorder),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PORTFOLIO VALUE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(trading.getTotalPortfolioValue(market.allStocks)),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkTextPrimary),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 28, width: 1, color: AppColors.darkCardBorder),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL UNREALIZED P&L',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(trading.getTotalUnrealizedPnL(market.allStocks)),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: trading.getTotalUnrealizedPnL(market.allStocks) >= 0 ? AppColors.bullGreen : AppColors.bearRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Search Bar + Category Pills
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SearchBarWidget(
                      controller: _searchController,
                      onChanged: (val) => market.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.stockSectors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final sector = AppConstants.stockSectors[index];
                          final isSelected = market.selectedSector == sector;
                          return ChoiceChip(
                            label: Text(sector),
                            selected: isSelected,
                            onSelected: (_) => market.setSector(sector),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.darkCard,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.darkTextSecondary,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.darkCardBorder,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Market Categorization Tabs
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  labelColor: AppColors.darkTextPrimary,
                  unselectedLabelColor: AppColors.darkTextMuted,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'All Instruments'),
                    Tab(text: 'Top Gainers ▲'),
                    Tab(text: 'Top Losers ▼'),
                    Tab(text: 'Most Traded ⚡'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Table Column Headers
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.darkInputBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text('INSTRUMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text('24H TREND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted)),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('LTP / 24H CHG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('TRADE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Stock Table Rows
              SizedBox(
                height: 560,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStockTable(allStocks),
                    _buildStockTable(topGainers),
                    _buildStockTable(topLosers),
                    _buildStockTable(mostActive),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockTable(List<StockModel> stocks) {
    if (stocks.isEmpty) {
      return const Center(
        child: Text('No instruments matching query', style: TextStyle(color: AppColors.darkTextMuted)),
      );
    }

    return ListView.builder(
      itemCount: stocks.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final isPositive = stock.isPositive;

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StockDetailScreen(symbol: stock.symbol),
              ),
            );
          },
          child: Row(
            children: [
              // Symbol, Name & Sector
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            stock.symbol,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.darkTextPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.darkInputBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.darkCardBorder),
                          ),
                          child: Text(
                            stock.sector.split(' ').first.toUpperCase(),
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.name,
                      style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Sparkline Chart
              Expanded(
                flex: 2,
                child: Center(
                  child: SparklineChartWidget(
                    points: stock.sparkline,
                    isPositive: isPositive,
                    width: 70,
                    height: 24,
                  ),
                ),
              ),

              // Price & Change %
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(stock.currentPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isPositive ? AppColors.bullGreenBg : AppColors.bearRedBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${isPositive ? "+" : ""}${stock.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Quick Buy / Sell Buttons (Zerodha Kite Style)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => OrderExecutionSheet(stock: stock, initialSide: OrderSide.buy),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.bullGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.bullGreen.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'BUY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.bullGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => OrderExecutionSheet(stock: stock, initialSide: OrderSide.sell),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.bearRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.bearRed.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'SELL',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.bearRed),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
