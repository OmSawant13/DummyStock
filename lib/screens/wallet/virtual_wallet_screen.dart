import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/trading_provider.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/trading/trade_receipt_dialog.dart';

class VirtualWalletScreen extends StatefulWidget {
  const VirtualWalletScreen({super.key});

  @override
  State<VirtualWalletScreen> createState() => _VirtualWalletScreenState();
}

class _VirtualWalletScreenState extends State<VirtualWalletScreen> {
  TransactionType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final trading = context.watch<TradingProvider>();

    final filteredTransactions = trading.transactions.where((tx) {
      if (_selectedFilter == null) return true;
      return tx.type == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Wallet & Ledger', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Wallet to \$100,000',
            onPressed: () => _confirmReset(context, trading),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cash Balance Master Card
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
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
                      const Text(
                        'Virtual Buying Power',
                        style: TextStyle(fontSize: 13, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bullGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('RISK-FREE SANDBOX', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.bullGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(trading.walletBalance),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: const Text('Deposit \$10,000'),
                          onPressed: () {
                            trading.depositFunds(10000);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Deposited \$10,000 virtual funds into wallet!'),
                                backgroundColor: AppColors.bullGreenDark,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.restart_alt_rounded, size: 18),
                          label: const Text('Reset All'),
                          onPressed: () => _confirmReset(context, trading),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Ledger Filter Chips
            Row(
              children: [
                _buildFilterChip(null, 'All Activity'),
                const SizedBox(width: 8),
                _buildFilterChip(TransactionType.stockBuy, 'Buys'),
                const SizedBox(width: 8),
                _buildFilterChip(TransactionType.stockSell, 'Sells'),
                const SizedBox(width: 8),
                _buildFilterChip(TransactionType.depositCash, 'Deposits'),
              ],
            ),
            const SizedBox(height: 14),

            // Transactions Activity List
            Text(
              'Audit Trail & Trade Receipts (${filteredTransactions.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (filteredTransactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No transaction activity records found.', style: TextStyle(color: AppColors.darkTextMuted)),
                ),
              )
            else
              ...filteredTransactions.map((tx) {
                final isCredit = tx.isCredit;

                return CustomCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => TradeReceiptDialog(transaction: tx),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isCredit ? AppColors.bullGreen : AppColors.primary).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          size: 18,
                          color: isCredit ? AppColors.bullGreen : AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd, yyyy • HH:mm').format(tx.timestamp),
                              style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isCredit ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isCredit ? AppColors.bullGreen : AppColors.bearRed,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bal: ${CurrencyFormatter.format(tx.balanceAfter)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(TransactionType? type, String label) {
    final isSelected = _selectedFilter == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.darkTextMuted,
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, TradingProvider trading) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Simulation Sandbox?'),
        content: const Text(
          'This will reset your virtual wallet balance back to \$100,000 and clear all active open positions and trade history.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.bearRed, foregroundColor: Colors.white),
            onPressed: () {
              trading.resetSimulation();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulation Sandbox reset to initial state!')),
              );
            },
            child: const Text('Confirm Reset'),
          ),
        ],
      ),
    );
  }
}
