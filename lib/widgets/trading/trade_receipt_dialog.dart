import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaction_model.dart';

class TradeReceiptDialog extends StatelessWidget {
  final TransactionModel transaction;

  const TradeReceiptDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCredit = transaction.isCredit;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isCredit ? AppColors.bullGreen : AppColors.primary).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.check_circle_outline_rounded : Icons.receipt_long_rounded,
                  size: 32,
                  color: isCredit ? AppColors.bullGreen : AppColors.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Trading Execution Audit Receipt',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                'Simulated Exchange Settlement',
                style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
              ),
            ),
            const SizedBox(height: 16),

            // Amount Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isCredit ? AppColors.bullGreen : AppColors.bearRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Value Details
            _buildDetailRow('Transaction ID', '${transaction.id.substring(0, 12)}...'),
            _buildDetailRow('Timestamp', DateFormat('MMM dd, yyyy • HH:mm:ss').format(transaction.timestamp)),
            if (transaction.symbol != null) _buildDetailRow('Asset Symbol', transaction.symbol!),
            if (transaction.quantity != null) _buildDetailRow('Executed Quantity', '${transaction.quantity} Shares'),
            if (transaction.pricePerShare != null)
              _buildDetailRow('Execution Price', CurrencyFormatter.format(transaction.pricePerShare!)),
            if (transaction.brokerageFee > 0)
              _buildDetailRow('Brokerage Fee', CurrencyFormatter.format(transaction.brokerageFee)),
            _buildDetailRow('Wallet Balance After', CurrencyFormatter.format(transaction.balanceAfter)),
            const Divider(height: 20),

            // Close & Share Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Audit receipt saved to portfolio ledger!'),
                          backgroundColor: AppColors.bullGreenDark,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
