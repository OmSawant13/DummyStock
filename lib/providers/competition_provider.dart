import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/competition_model.dart';
import '../services/storage_service.dart';

class CompetitionProvider with ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();
  List<TradingCompetition> _competitions = [];
  List<String> _registeredLeagueIds = [];

  List<TradingCompetition> get competitions => _competitions;
  List<String> get registeredLeagueIds => _registeredLeagueIds;

  CompetitionProvider(this._storageService) {
    _registeredLeagueIds = _storageService.getRegisteredLeagues();
    _initSampleCompetitions();
  }

  void _initSampleCompetitions() {
    _competitions = [
      TradingCompetition(
        id: 'league-1',
        title: 'National Inter-College Quant Challenge 2026',
        organizer: 'Consortium of FinTech Institutes',
        description:
            'Compete against 2,400+ students nationwide. Build an optimal equities portfolio and maximize risk-adjusted Sharpe ratio.',
        initialCapital: 100000.0,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 14)),
        prizePool: '\$15,000 + Summer Quant Internship',
        participantCount: 2418,
        isRegistered: _registeredLeagueIds.contains('league-1'),
        status: 'Active',
        rules: [
          'Initial Capital: \$100,000 virtual cash.',
          'Max Single Stock Holding: 30% of total portfolio value.',
          'Minimum 5 distinct trades required to qualify for awards.',
          'Rankings determined by Net Returns % and Sharpe Ratio.',
        ],
        leaderboard: [
          LeaderboardParticipant(
            id: 'p-1',
            name: 'Alex Chen',
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
            college: 'MIT FinTech Lab',
            portfolioValue: 124850.20,
            returnPercentage: 24.85,
            totalTrades: 42,
            winRate: 76.2,
            rank: 1,
          ),
          LeaderboardParticipant(
            id: 'p-2',
            name: 'Priya Sharma',
            avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
            college: 'IIT Bombay Alpha Club',
            portfolioValue: 119420.00,
            returnPercentage: 19.42,
            totalTrades: 31,
            winRate: 71.0,
            rank: 2,
          ),
          LeaderboardParticipant(
            id: 'p-3',
            name: 'Marcus Brody',
            avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
            college: 'Stanford Trading Society',
            portfolioValue: 116300.50,
            returnPercentage: 16.30,
            totalTrades: 28,
            winRate: 67.8,
            rank: 3,
          ),
          LeaderboardParticipant(
            id: 'p-user',
            name: 'You (Student Trader)',
            avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
            college: 'University League',
            portfolioValue: 108450.00,
            returnPercentage: 8.45,
            totalTrades: 14,
            winRate: 64.3,
            rank: 12,
            isCurrentUser: true,
          ),
          LeaderboardParticipant(
            id: 'p-4',
            name: 'Sophia Mueller',
            avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
            college: 'ETH Zurich Finance Guild',
            portfolioValue: 114200.00,
            returnPercentage: 14.20,
            totalTrades: 22,
            winRate: 63.6,
            rank: 4,
          ),
          LeaderboardParticipant(
            id: 'p-5',
            name: 'David Kim',
            avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
            college: 'UC Berkeley CalTrading',
            portfolioValue: 111800.00,
            returnPercentage: 11.80,
            totalTrades: 19,
            winRate: 61.5,
            rank: 5,
          ),
        ],
      ),
      TradingCompetition(
        id: 'league-2',
        title: 'Global High-Frequency & Tech Alpha Derby',
        organizer: 'TechAlpha Capital Partners',
        description:
            'Focus on semiconductor and AI equities with volatile intraday swings. Win direct interviews and cash rewards.',
        initialCapital: 50000.0,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        prizePool: '\$8,000 + Bloomberg Terminal Student Grants',
        participantCount: 1120,
        isRegistered: _registeredLeagueIds.contains('league-2'),
        status: 'Active',
        rules: [
          'Initial Capital: \$50,000 virtual cash.',
          'Allowed Sectors: Technology, Semiconductors, Consumer Tech.',
          'Leveraged positions simulated at 1.5x margin.',
        ],
        leaderboard: [
          LeaderboardParticipant(
            id: 'p-21',
            name: 'Elena Rostova',
            avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
            college: 'London School of Economics',
            portfolioValue: 62400.00,
            returnPercentage: 24.80,
            totalTrades: 58,
            winRate: 74.1,
            rank: 1,
          ),
          LeaderboardParticipant(
            id: 'p-22',
            name: 'Hiroshi Tanaka',
            avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100',
            college: 'University of Tokyo',
            portfolioValue: 58900.00,
            returnPercentage: 17.80,
            totalTrades: 39,
            winRate: 69.2,
            rank: 2,
          ),
        ],
      ),
      TradingCompetition(
        id: 'league-3',
        title: 'Ivy FinTech Spring Hackathon 2026',
        organizer: 'Harvard & Columbia Investment Clubs',
        description:
            'Upcoming tournament focusing on ESG equities, renewable energy, and value investing portfolios.',
        initialCapital: 200000.0,
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        prizePool: '\$20,000 Collegiate Grand Trophy',
        participantCount: 890,
        isRegistered: _registeredLeagueIds.contains('league-3'),
        status: 'Upcoming',
        rules: [
          'Initial Capital: \$200,000 virtual capital.',
          'Holding requirement: Must hold at least 3 distinct sectors at all times.',
        ],
        leaderboard: [],
      ),
    ];
  }

  void registerLeague(String leagueId) {
    if (!_registeredLeagueIds.contains(leagueId)) {
      _registeredLeagueIds.add(leagueId);
      _storageService.saveRegisteredLeagues(_registeredLeagueIds);

      final idx = _competitions.indexWhere((c) => c.id == leagueId);
      if (idx >= 0) {
        _competitions[idx] = _competitions[idx].copyWith(
          isRegistered: true,
          participantCount: _competitions[idx].participantCount + 1,
        );
      }
      notifyListeners();
    }
  }

  void createCustomLeague({
    required String title,
    required String organizer,
    required String description,
    required double initialCapital,
    required int durationDays,
    required String prizePool,
  }) {
    final newId = _uuid.v4();
    final newLeague = TradingCompetition(
      id: newId,
      title: title,
      organizer: organizer,
      description: description,
      initialCapital: initialCapital,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: durationDays)),
      prizePool: prizePool,
      participantCount: 1,
      isRegistered: true,
      status: 'Active',
      rules: [
        'Initial Capital: \$${initialCapital.toStringAsFixed(0)} virtual cash.',
        'Leaderboard updates in real-time on live ticker ticks.',
        'Custom institutional rules applied.',
      ],
      leaderboard: [
        LeaderboardParticipant(
          id: 'user-admin',
          name: 'You (Creator)',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
          college: organizer,
          portfolioValue: initialCapital,
          returnPercentage: 0.0,
          totalTrades: 0,
          winRate: 0.0,
          rank: 1,
          isCurrentUser: true,
        ),
      ],
    );

    _competitions.insert(0, newLeague);
    _registeredLeagueIds.add(newId);
    _storageService.saveRegisteredLeagues(_registeredLeagueIds);
    notifyListeners();
  }

  void updateCurrentUserPerformance(double userPortfolioValue, double returnPercentage) {
    for (var comp in _competitions) {
      if (comp.isRegistered) {
        final userIdx = comp.leaderboard.indexWhere((p) => p.isCurrentUser);
        if (userIdx >= 0) {
          final old = comp.leaderboard[userIdx];
          comp.leaderboard[userIdx] = LeaderboardParticipant(
            id: old.id,
            name: old.name,
            avatarUrl: old.avatarUrl,
            college: old.college,
            portfolioValue: userPortfolioValue,
            returnPercentage: returnPercentage,
            totalTrades: old.totalTrades,
            winRate: old.winRate,
            rank: old.rank,
            isCurrentUser: true,
          );

          // Re-sort leaderboard
          comp.leaderboard.sort((a, b) => b.returnPercentage.compareTo(a.returnPercentage));
          for (int i = 0; i < comp.leaderboard.length; i++) {
            final p = comp.leaderboard[i];
            comp.leaderboard[i] = LeaderboardParticipant(
              id: p.id,
              name: p.name,
              avatarUrl: p.avatarUrl,
              college: p.college,
              portfolioValue: p.portfolioValue,
              returnPercentage: p.returnPercentage,
              totalTrades: p.totalTrades,
              winRate: p.winRate,
              rank: i + 1,
              isCurrentUser: p.isCurrentUser,
            );
          }
        }
      }
    }
    notifyListeners();
  }
}
