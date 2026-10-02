import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../models/stock_model.dart';
import '../../providers/trading_provider.dart';

class OrderExecutionSheet extends StatefulWidget {
  final StockModel stock;
  final OrderSide initialSide;

  const OrderExecutionSheet({
    super.key,
    required this.stock,
    this.initialSide = OrderSide.buy,
  });

  @override
  State<OrderExecutionSheet> createState() => _OrderExecutionSheetState();
}

class _OrderExecutionSheetState extends State<OrderExecutionSheet> {
  late OrderSide _selectedSide;
  OrderType _selectedType = OrderType.market;
  int _quantity = 1;
  late TextEditingController _targetPriceController;
  final TextEditingController _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _selectedSide = widget.initialSide;
    _targetPriceController = TextEditingController(
      text: widget.stock.currentPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tradingProvider = context.watch<TradingProvider>();
    final walletBalance = tradingProvider.walletBalance;

    final existingPos = tradingProvider.positions
        .where((p) => p.symbol == widget.stock.symbol)
        .firstOrNull;
    final ownedQuantity = existingPos?.quantity ?? 0;

    final targetPrice = double.tryParse(_targetPriceController.text) ?? widget.stock.currentPrice;
    final executionUnit = _selectedType == OrderType.market ? widget.stock.currentPrice : targetPrice;
    final orderValue = _quantity * executionUnit;
    final brokerage = orderValue * AppConstants.simulatedBrokerageRate;
    final totalAmount = _selectedSide == OrderSide.buy ? (orderValue + brokerage) : (orderValue - brokerage);

    final isBuy = _selectedSide == OrderSide.buy;
    final themeColor = isBuy ? AppColors.bullGreen : AppColors.bearRed;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stock.symbol,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      widget.stock.name,
                      style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(widget.stock.currentPrice),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Owned: $ownedQuantity shares',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Buy / Sell Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSideTab(OrderSide.buy, 'BUY', AppColors.bullGreen),
                  ),
                  Expanded(
                    child: _buildSideTab(OrderSide.sell, 'SELL', AppColors.bearRed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Type Selector
            Row(
              children: [
                _buildTypeChip(OrderType.market, 'Market'),
                const SizedBox(width: 8),
                _buildTypeChip(OrderType.limit, 'Limit'),
                const SizedBox(width: 8),
                _buildTypeChip(OrderType.stopLoss, 'Stop Loss'),
                const SizedBox(width: 8),
                _buildTypeChip(OrderType.takeProfit, 'Take Profit'),
              ],
            ),
            const SizedBox(height: 16),

            // Price Field (if not Market)
            if (_selectedType != OrderType.market) ...[
              TextField(
                controller: _targetPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: _selectedType == OrderType.limit
                      ? 'Limit Price (\$)'
                      : _selectedType == OrderType.stopLoss
                          ? 'Stop Loss Trigger (\$)'
                          : 'Take Profit Target (\$)',
                  prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Quantity Stepper
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setState(() => _quantity = parsed);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Shares Quantity',
                      prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: _quantity > 1
                      ? () {
                          setState(() {
                            _quantity--;
                            _quantityController.text = _quantity.toString();
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                      _quantityController.text = _quantity.toString();
                    });
                  },
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick Percentage Allocation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPercentButton(0.25, '25%'),
                _buildPercentButton(0.50, '50%'),
                _buildPercentButton(0.75, '75%'),
                _buildPercentButton(1.00, 'MAX'),
              ],
            ),
            const SizedBox(height: 16),

            // Cost & Fee Breakdown Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Available Cash', CurrencyFormatter.format(walletBalance)),
                  const SizedBox(height: 6),
                  _buildSummaryRow('Estimated Order Value', CurrencyFormatter.format(orderValue)),
                  const SizedBox(height: 6),
                  _buildSummaryRow(
                    'Simulated Fee (0.05%)',
                    CurrencyFormatter.format(brokerage),
                    isMuted: true,
                  ),
                  const Divider(height: 16),
                  _buildSummaryRow(
                    isBuy ? 'Total Estimated Outflow' : 'Estimated Net Inflow',
                    CurrencyFormatter.format(totalAmount),
                    isBold: true,
                    valueColor: themeColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Execute Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () {
                final error = tradingProvider.placeOrder(
                  stock: widget.stock,
                  side: _selectedSide,
                  type: _selectedType,
                  quantity: _quantity,
                  targetPrice: targetPrice,
                );

                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: AppColors.bearRed,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_selectedType.name.toUpperCase()} order for $_quantity ${widget.stock.symbol} submitted successfully!',
                      ),
                      backgroundColor: AppColors.bullGreenDark,
                    ),
                  );
                }
              },
              child: Text(
                '${isBuy ? 'BUY' : 'SELL'} $_quantity ${widget.stock.symbol}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideTab(OrderSide side, String label, Color activeColor) {
    final isSelected = _selectedSide == side;
    return GestureDetector(
      onTap: () => setState(() => _selectedSide = side),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.darkTextMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(OrderType type, String label) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.18)
                : (isDark ? AppColors.darkInputBg : AppColors.lightInputBg),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryLight : AppColors.darkTextMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentButton(double ratio, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 6),
            side: BorderSide(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            final trading = context.read<TradingProvider>();
            if (_selectedSide == OrderSide.buy) {
              final budget = trading.walletBalance * ratio;
              final maxShares = (budget / widget.stock.currentPrice).floor();
              setState(() {
                _quantity = maxShares > 0 ? maxShares : 1;
                _quantityController.text = _quantity.toString();
              });
            } else {
              final pos = trading.positions.where((p) => p.symbol == widget.stock.symbol).firstOrNull;
              if (pos != null) {
                final qty = (pos.quantity * ratio).ceil();
                setState(() {
                  _quantity = qty > 0 ? qty : 1;
                  _quantityController.text = _quantity.toString();
                });
              }
            }
          },
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isMuted = false, bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isMuted ? AppColors.darkTextMuted : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isMuted ? AppColors.darkTextMuted : null),
          ),
        ),
      ],
    );
  }
}
