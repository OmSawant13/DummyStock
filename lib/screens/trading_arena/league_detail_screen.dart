import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/competition_model.dart';
import '../../providers/competition_provider.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/stat_badge.dart';
import '../../widgets/competition/participant_rank_card.dart';

class LeagueDetailScreen extends StatelessWidget {
  final String leagueId;

  const LeagueDetailScreen({super.key, required this.leagueId});

  @override
  Widget build(BuildContext context) {
    final compProvider = context.watch<CompetitionProvider>();
    final comp = compProvider.competitions.where((c) => c.id == leagueId).firstOrNull;

    if (comp == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Competition Details')),
        body: const Center(child: Text('League not found')),
      );
    }

    final isRegistered = compProvider.registeredLeagueIds.contains(comp.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(comp.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // League Header Card
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          comp.status.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.purple),
                        ),
                      ),
                      Text(
                        '${comp.participantCount} Participants',
                        style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(comp.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Organized by: ${comp.organizer}', style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(comp.description, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.darkTextMuted)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prize Pool', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                          const SizedBox(height: 2),
                          Text(comp.prizePool, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Initial Capital', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                          const SizedBox(height: 2),
                          Text(CurrencyFormatter.format(comp.initialCapital), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Timeline: ${DateFormat('MMM dd').format(comp.startDate)} – ${DateFormat('MMM dd, yyyy').format(comp.endDate)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Registration Action
            if (!isRegistered) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  compProvider.registerLeague(comp.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully registered for ${comp.title}!'),
                      backgroundColor: AppColors.bullGreenDark,
                    ),
                  );
                },
                child: const Text('Join This League (Free Student Entry)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],

            // Competition Rules
            const Text('Tournament Rules & Constraints', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comp.rules.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(rule, style: const TextStyle(fontSize: 12, height: 1.35)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Live Leaderboard
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Leaderboard Standings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                StatBadge(label: 'Live', value: '${comp.leaderboard.length} Ranked', isPositive: true),
              ],
            ),
            const SizedBox(height: 10),

            if (comp.leaderboard.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Tournament starts soon. Standings will open on launch.', style: TextStyle(color: AppColors.darkTextMuted)),
                ),
              )
            else
              ...comp.leaderboard.map((participant) => ParticipantRankCard(participant: participant)),
          ],
        ),
      ),
    );
  }
}
