import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/trading_provider.dart';
import '../../widgets/common/custom_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final trading = context.watch<TradingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Institutional Pricing', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Mode Switcher
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Appearance Theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('Toggle between FinTech Dark & Clean Light', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: theme.isDarkMode,
                    activeColor: AppColors.primaryLight,
                    onChanged: (_) => theme.toggleTheme(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Pricing Strategy & Institutional Tiers Section
            const Text(
              'Pricing Strategy & Subscriptions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildPricingCard(
              title: '1. Free Basic Simulation',
              badge: 'ACTIVE PLAN',
              badgeColor: AppColors.bullGreen,
              price: '\$0 / forever',
              features: [
                '\$100,000 Virtual Paper Trading Capital',
                'Standard Market & Candlestick OHLCV Data',
                'Limit, Market, Stop-Loss & Take-Profit Orders',
                'Basic Watchlists & Price Alerts',
              ],
            ),
            const SizedBox(height: 10),

            _buildPricingCard(
              title: '2. Premium Analytics Tier',
              badge: 'PRO TRADER',
              badgeColor: AppColors.accent,
              price: '\$9.99 / month',
              features: [
                'Unlimited Portfolio Capital Resets',
                'Advanced Quant Indicators (RSI, Bollinger, MACD)',
                'AI-Powered Trade Execution Insights & Post-Mortem',
                'Live Push Notifications on Technical Breakouts',
              ],
            ),
            const SizedBox(height: 10),

            _buildPricingCard(
              title: '3. Institutional Subscription (Colleges)',
              badge: 'UNIVERSITIES',
              badgeColor: AppColors.purple,
              price: '\$299 / semester (Unlimited Batch)',
              features: [
                'Bulk Student Onboarding & Professor Admin Console',
                'Automated Grading on Risk-Adjusted Sharpe Ratio',
                'Custom Class-Wide Portfolio Allocation Constraints',
                'Curriculum Alignment & Quiz Analytics Export',
              ],
            ),
            const SizedBox(height: 10),

            _buildPricingCard(
              title: '4. Competition Packages for Colleges',
              badge: 'HACKATHONS',
              badgeColor: AppColors.gold,
              price: 'Custom / Sponsored League',
              features: [
                'Branded Collegiate Trading Tournaments',
                'Automated Live Verified National Leaderboards',
                'Anti-Cheat & Trade Manipulation Filters',
                'API Integration for Campus FinTech Societies',
              ],
            ),
            const SizedBox(height: 20),

            // Sandbox Data Controls
            const Text(
              'Data & Simulation Controls',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restart_alt_rounded, color: AppColors.bearRed),
                    title: const Text('Reset All Simulation State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Clears all active trades and resets cash to \$100,000', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.bearRed, foregroundColor: Colors.white),
                      onPressed: () {
                        trading.resetSimulation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All positions and wallet balance reset!')),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Platform
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v1.0.0',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Smart Stock Trading & EdTech Simulation Engine',
                    style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String price,
    required List<String> features,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
          const Divider(height: 14),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.bullGreen),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 12, height: 1.3))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
