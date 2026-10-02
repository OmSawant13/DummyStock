import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/stock_model.dart';

class OrderBookWidget extends StatelessWidget {
  final StockModel stock;

  const OrderBookWidget({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Simulated 5-depth order book ladder
    final bids = [
      {'qty': 1420, 'orders': 14, 'price': stock.currentPrice * 0.9995},
      {'qty': 2850, 'orders': 29, 'price': stock.currentPrice * 0.9988},
      {'qty': 5100, 'orders': 52, 'price': stock.currentPrice * 0.9975},
      {'qty': 8200, 'orders': 84, 'price': stock.currentPrice * 0.9960},
      {'qty': 12400, 'orders': 118, 'price': stock.currentPrice * 0.9945},
    ];

    final asks = [
      {'qty': 1180, 'orders': 12, 'price': stock.currentPrice * 1.0005},
      {'qty': 3240, 'orders': 31, 'price': stock.currentPrice * 1.0012},
      {'qty': 4900, 'orders': 48, 'price': stock.currentPrice * 1.0025},
      {'qty': 7600, 'orders': 79, 'price': stock.currentPrice * 1.0040},
      {'qty': 11500, 'orders': 105, 'price': stock.currentPrice * 1.0055},
    ];

    const int totalBidQty = 29970;
    const int totalAskQty = 28420;
    const double buyerRatio = totalBidQty / (totalBidQty + totalAskQty);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.bullGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'MARKET DEPTH (LEVEL 2)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                ),
                child: Text(
                  'SPREAD: \$${(stock.currentPrice * 0.001).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Depth Headers
          const Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ORDERS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted)),
                    Text('BID QTY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted)),
                    Text('BID PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.bullGreen)),
                  ],
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ASK PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.bearRed)),
                    Text('ASK QTY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted)),
                    Text('ORDERS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Depth Rows with horizontal volume meter fills
          ...List.generate(5, (index) {
            final bid = bids[index];
            final ask = asks[index];
            final bidFill = ((bid['qty'] as num) / 12400).clamp(0.05, 1.0);
            final askFill = ((ask['qty'] as num) / 11500).clamp(0.05, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  // Bid Side
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: bidFill,
                              child: Container(
                                color: AppColors.bullGreen.withOpacity(0.08),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${bid['orders']}', style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
                              Text('${bid['qty']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                              Text(
                                CurrencyFormatter.format((bid['price'] as num).toDouble()),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.bullGreen),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Ask Side
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: askFill,
                              child: Container(
                                color: AppColors.bearRed.withOpacity(0.08),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                CurrencyFormatter.format((ask['price'] as num).toDouble()),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.bearRed),
                              ),
                              Text('${ask['qty']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                              Text('${ask['orders']}', style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.darkCardBorder),
          const SizedBox(height: 8),

          // Total Buyer vs Seller Power Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BUY ${(buyerRatio * 100).toStringAsFixed(1)}% (${CurrencyFormatter.formatCompact(totalBidQty.toDouble(), symbol: '')})',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.bullGreen),
              ),
              Text(
                'SELL ${((1 - buyerRatio) * 100).toStringAsFixed(1)}% (${CurrencyFormatter.formatCompact(totalAskQty.toDouble(), symbol: '')})',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.bearRed),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 4,
              child: Row(
                children: [
                  Expanded(
                    flex: (buyerRatio * 100).round(),
                    child: Container(color: AppColors.bullGreen),
                  ),
                  Expanded(
                    flex: ((1 - buyerRatio) * 100).round(),
                    child: Container(color: AppColors.bearRed),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
