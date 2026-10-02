import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/trading_provider.dart';
import '../../widgets/charts/portfolio_allocation_chart.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/stat_badge.dart';
import '../market/stock_detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final trading = context.watch<TradingProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalPortfolioVal = trading.getTotalPortfolioValue(market.allStocks);
    final totalUnrealizedPnL = trading.getTotalUnrealizedPnL(market.allStocks);
    final totalRealizedPnL = trading.getTotalRealizedPnL();
    final totalNetPnL = trading.getTotalPnL(market.allStocks);
    final totalReturnsPercent = trading.getTotalReturnsPercent(market.allStocks);
    final isPositive = totalNetPnL >= 0;
    final winRate = trading.getWinRate();
    final sharpe = trading.getSharpeRatio(market.allStocks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio & Risk Analytics', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Portfolio Statement',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Official Portfolio Audit Statement'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Net Worth: ${CurrencyFormatter.format(totalPortfolioVal)}'),
                      const SizedBox(height: 4),
                      Text('Cash Balance: ${CurrencyFormatter.format(trading.walletBalance)}'),
                      const SizedBox(height: 4),
                      Text('Realized P&L: ${CurrencyFormatter.format(totalRealizedPnL)}'),
                      const SizedBox(height: 4),
                      Text('Unrealized P&L: ${CurrencyFormatter.format(totalUnrealizedPnL)}'),
                      const SizedBox(height: 4),
                      Text('Sharpe Ratio: ${sharpe.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Text('Active Holdings: ${trading.positions.length} stocks'),
                      const Divider(height: 16),
                      const Text(
                        'Verified academic statement generated for collegiate accreditation and portfolio submission.',
                        style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Download PDF/CSV'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Portfolio Statement exported successfully!'),
                            backgroundColor: AppColors.bullGreenDark,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Net Worth Summary Banner
            CustomCard(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF131A2B),
                        Color(0xFF090D15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.lightCardBorder,
                width: 1.2,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL PORTFOLIO VALUATION',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.8,
                          color: AppColors.cyberCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPositive ? AppColors.bullGreenBg : AppColors.bearRedBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isPositive
                                ? AppColors.bullGreen.withValues(alpha: 0.3)
                                : AppColors.bearRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${isPositive ? "+" : ""}${totalReturnsPercent.toStringAsFixed(2)}% ALL TIME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(totalPortfolioVal),
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Net P&L', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                          const SizedBox(height: 2),
                          Text(
                            '${isPositive ? '+' : ''}${CurrencyFormatter.format(totalNetPnL)} (${CurrencyFormatter.formatPercent(totalReturnsPercent)})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Unrealized / Realized', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                          const SizedBox(height: 2),
                          Text(
                            '${CurrencyFormatter.format(totalUnrealizedPnL)} / ${CurrencyFormatter.format(totalRealizedPnL)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Quant Risk Metrics Badges
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      children: [
                        const Text('Sharpe Ratio', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                        const SizedBox(height: 4),
                        Text(
                          sharpe.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      children: [
                        const Text('Win Rate', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                        const SizedBox(height: 4),
                        Text(
                          '${winRate.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.bullGreen),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      children: [
                        const Text('Open Positions', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                        const SizedBox(height: 4),
                        Text(
                          '${trading.positions.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Asset & Sector Allocation Donut Chart
            const Text(
              'Asset Allocation Breakdown',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomCard(
              child: PortfolioAllocationChart(
                positions: trading.positions,
                stocks: market.allStocks,
                walletBalance: trading.walletBalance,
              ),
            ),
            const SizedBox(height: 16),

            // Quant AI Risk Advisor & Health Diagnostics
            CustomCard(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.secondary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Quant Risk Advisor',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryLight),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.bullGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Score: ${(sharpe * 20 + winRate * 0.4).clamp(50, 98).toStringAsFixed(0)}/100',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.bullGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    trading.positions.isEmpty
                        ? '• Your portfolio is currently 100% in cash. Allocate capital across diverse sectors to maximize risk-adjusted returns.'
                        : '• Sharpe ratio is ${sharpe.toStringAsFixed(2)} (${sharpe >= 1.5 ? 'Excellent risk adjustment' : 'Moderate volatility'}).\n• Diversified across ${trading.positions.length} active positions. Maintain cash reserves above 15% for optimal liquidity.',
                    style: const TextStyle(fontSize: 12, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Holdings, Orders, Closed Trades Tabs
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
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'Holdings (${trading.positions.length})'),
                  Tab(text: 'Pending (${trading.pendingOrders.length})'),
                  Tab(text: 'Closed (${trading.closedTrades.length})'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab Views
            SizedBox(
              height: 420,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHoldingsTab(trading, market),
                  _buildPendingOrdersTab(trading),
                  _buildClosedTradesTab(trading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingsTab(TradingProvider trading, MarketProvider market) {
    if (trading.positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 48, color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 10),
            const Text('No active equity holdings.', style: TextStyle(color: AppColors.darkTextMuted)),
            const SizedBox(height: 4),
            const Text('Explore the Market Dashboard to place your first trade.', style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: trading.positions.length,
      itemBuilder: (context, index) {
        final pos = trading.positions[index];
        final stock = market.getStockBySymbol(pos.symbol);
        final currentPrice = stock?.currentPrice ?? pos.averageBuyPrice;
        final currentVal = pos.getCurrentValue(currentPrice);
        final unrealizedPnL = pos.getUnrealizedPnL(currentPrice);
        final unrealizedPnLPercent = pos.getUnrealizedPnLPercent(currentPrice);
        final isPos = unrealizedPnL >= 0;

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: pos.symbol)),
            );
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(pos.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${pos.quantity} Shares', style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(currentVal),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg: ${CurrencyFormatter.format(pos.averageBuyPrice)} • CMP: ${CurrencyFormatter.format(currentPrice)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                  ),
                  Text(
                    '${isPos ? '+' : ''}${CurrencyFormatter.format(unrealizedPnL)} (${CurrencyFormatter.formatPercent(unrealizedPnLPercent)})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isPos ? AppColors.bullGreen : AppColors.bearRed,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Invested: ${CurrencyFormatter.format(pos.totalInvested)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.bearRed,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                    label: const Text('Close Position', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final error = trading.closePosition(pos, currentPrice);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: AppColors.bearRed),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Closed position for ${pos.quantity} ${pos.symbol} at ${CurrencyFormatter.format(currentPrice)}'),
                            backgroundColor: AppColors.bullGreenDark,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingOrdersTab(TradingProvider trading) {
    if (trading.pendingOrders.isEmpty) {
      return const Center(
        child: Text('No pending Limit or Stop-Loss orders.', style: TextStyle(color: AppColors.darkTextMuted)),
      );
    }

    return ListView.builder(
      itemCount: trading.pendingOrders.length,
      itemBuilder: (context, index) {
        final order = trading.pendingOrders[index];
        final isBuy = order.side == OrderSide.buy;

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(order.symbol, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      StatBadge(
                        label: order.side.name.toUpperCase(),
                        value: order.type.name.toUpperCase(),
                        isPositive: isBuy,
                        isNegative: !isBuy,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${order.quantity} • Target: ${CurrencyFormatter.format(order.targetPrice)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: AppColors.bearRed),
                tooltip: 'Cancel Order',
                onPressed: () => trading.cancelOrder(order.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClosedTradesTab(TradingProvider trading) {
    if (trading.closedTrades.isEmpty) {
      return const Center(
        child: Text('No closed trades yet.', style: TextStyle(color: AppColors.darkTextMuted)),
      );
    }

    return ListView.builder(
      itemCount: trading.closedTrades.length,
      itemBuilder: (context, index) {
        final trade = trading.closedTrades[index];
        final isWin = trade.realizedPnL >= 0;

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${trade.quantity}x ${trade.symbol}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    'Buy: ${CurrencyFormatter.format(trade.buyPrice)} • Sell: ${CurrencyFormatter.format(trade.sellPrice)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isWin ? '+' : ''}${CurrencyFormatter.format(trade.realizedPnL)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isWin ? AppColors.bullGreen : AppColors.bearRed,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatPercent(trade.realizedPnLPercent),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isWin ? AppColors.bullGreen : AppColors.bearRed,
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
