import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/competition_provider.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/competition/create_league_dialog.dart';
import 'league_detail_screen.dart';

class CompetitionHubScreen extends StatelessWidget {
  const CompetitionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compProvider = context.watch<CompetitionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Arena & Leagues', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Host Custom College League',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CreateLeagueDialog(),
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
            // Hero Banner
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('EDTECH TRADING LEAGUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Compete & Win Institutional Honours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Participate in real-time collegiate trading tournaments with simulated funds and climb verified national leaderboards.',
                    style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5B21B6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Host College Contest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const CreateLeagueDialog(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active & Upcoming Leagues List
            const Text(
              'Featured Collegiate Competitions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...compProvider.competitions.map((league) {
              final isRegistered = compProvider.registeredLeagueIds.contains(league.id);

              return CustomCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeagueDetailScreen(leagueId: league.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: league.status == 'Active'
                                ? AppColors.bullGreenBg
                                : AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            league.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: league.status == 'Active' ? AppColors.bullGreen : AppColors.primaryLight,
                            ),
                          ),
                        ),
                        if (isRegistered)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('REGISTERED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.purple)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(league.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(league.organizer, style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      league.description,
                      style: const TextStyle(fontSize: 12, height: 1.35, color: AppColors.darkTextMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.darkTextMuted),
                            const SizedBox(width: 4),
                            Text('${league.participantCount} Traders', style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.emoji_events_outlined, size: 16, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Text(league.prizePool.split('+').first.trim(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold)),
                          ],
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
}
