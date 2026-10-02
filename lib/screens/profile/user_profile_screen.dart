import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/trading_provider.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/stat_badge.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final trading = context.watch<TradingProvider>();
    final market = context.watch<MarketProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Profile')),
        body: const Center(child: Text('No active student session')),
      );
    }

    final totalPortfolioVal = trading.getTotalPortfolioValue(market.allStocks);
    final winRate = trading.getWinRate();
    final sharpe = trading.getSharpeRatio(market.allStocks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile & ID', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Virtual ID Card
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                              Text(user.college, style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bullGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('VERIFIED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bullGreen)),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Student Roll ID', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          const SizedBox(height: 2),
                          Text(user.studentId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Account Tier', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          const SizedBox(height: 2),
                          Text(user.role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accent)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Joined', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          const SizedBox(height: 2),
                          Text(DateFormat('MMM yyyy').format(user.registeredAt), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Performance Overview
            const Text('Trading Performance Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Portfolio Value', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                        const SizedBox(height: 4),
                        Text(CurrencyFormatter.formatCompact(totalPortfolioVal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Win Rate', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                        const SizedBox(height: 4),
                        Text('${winRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.bullGreen)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sharpe Ratio', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                        const SizedBox(height: 4),
                        Text(sharpe.toStringAsFixed(2), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Account Details List
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileRow(Icons.email_outlined, 'Academic Email', user.email),
                  const Divider(height: 16),
                  _buildProfileRow(Icons.badge_outlined, 'Student Identifier', user.studentId),
                  const Divider(height: 16),
                  _buildProfileRow(Icons.account_balance_wallet_outlined, 'Available Cash', CurrencyFormatter.format(trading.walletBalance)),
                  const Divider(height: 16),
                  _buildProfileRow(Icons.receipt_long_outlined, 'Total Executed Trades', '${trading.transactions.length} orders'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout / Switch User Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bearRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out / Switch Student Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              onPressed: () {
                auth.logout();
                Navigator.pop(context); // Return to previous screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.darkTextMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
