import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/competition_model.dart';
import '../common/custom_card.dart';

class ParticipantRankCard extends StatelessWidget {
  final LeaderboardParticipant participant;

  const ParticipantRankCard({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = participant.returnPercentage >= 0;

    Color? rankBadgeColor;
    if (participant.rank == 1) rankBadgeColor = AppColors.gold;
    if (participant.rank == 2) rankBadgeColor = AppColors.silver;
    if (participant.rank == 3) rankBadgeColor = AppColors.bronze;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: participant.isCurrentUser
          ? Border.all(color: AppColors.primaryLight, width: 1.5)
          : null,
      color: participant.isCurrentUser
          ? (isDark ? AppColors.primary.withOpacity(0.12) : AppColors.primary.withOpacity(0.06))
          : null,
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankBadgeColor ?? (isDark ? AppColors.darkInputBg : AppColors.lightInputBg),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '#${participant.rank}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: rankBadgeColor != null ? Colors.black87 : null,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participant.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: participant.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                          color: participant.isCurrentUser ? AppColors.primaryLight : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (participant.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  participant.college,
                  style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Win Rate: ${participant.winRate.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trades: ${participant.totalTrades}',
                      style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Value & Returns
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(participant.portfolioValue),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.bullGreenBg : AppColors.bearRedBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${participant.returnPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
