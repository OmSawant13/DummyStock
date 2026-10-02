class LeaderboardParticipant {
  final String id;
  final String name;
  final String avatarUrl;
  final String college;
  final double portfolioValue;
  final double returnPercentage;
  final int totalTrades;
  final double winRate;
  final int rank;
  final bool isCurrentUser;

  LeaderboardParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.college,
    required this.portfolioValue,
    required this.returnPercentage,
    required this.totalTrades,
    required this.winRate,
    required this.rank,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'college': college,
    'portfolioValue': portfolioValue,
    'returnPercentage': returnPercentage,
    'totalTrades': totalTrades,
    'winRate': winRate,
    'rank': rank,
    'isCurrentUser': isCurrentUser,
  };

  factory LeaderboardParticipant.fromJson(Map<String, dynamic> json) => LeaderboardParticipant(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
    college: json['college'],
    portfolioValue: (json['portfolioValue'] as num).toDouble(),
    returnPercentage: (json['returnPercentage'] as num).toDouble(),
    totalTrades: json['totalTrades'],
    winRate: (json['winRate'] as num).toDouble(),
    rank: json['rank'],
    isCurrentUser: json['isCurrentUser'] ?? false,
  );
}

class TradingCompetition {
  final String id;
  final String title;
  final String organizer; // e.g. "MIT FinTech Club", "Stanford Investment League"
  final String description;
  final double initialCapital;
  final DateTime startDate;
  final DateTime endDate;
  final String prizePool;
  final int participantCount;
  final bool isRegistered;
  final String status; // "Active", "Upcoming", "Completed"
  final List<String> rules;
  final List<LeaderboardParticipant> leaderboard;

  TradingCompetition({
    required this.id,
    required this.title,
    required this.organizer,
    required this.description,
    required this.initialCapital,
    required this.startDate,
    required this.endDate,
    required this.prizePool,
    required this.participantCount,
    this.isRegistered = false,
    required this.status,
    required this.rules,
    required this.leaderboard,
  });

  TradingCompetition copyWith({
    bool? isRegistered,
    int? participantCount,
    List<LeaderboardParticipant>? leaderboard,
  }) {
    return TradingCompetition(
      id: id,
      title: title,
      organizer: organizer,
      description: description,
      initialCapital: initialCapital,
      startDate: startDate,
      endDate: endDate,
      prizePool: prizePool,
      participantCount: participantCount ?? this.participantCount,
      isRegistered: isRegistered ?? this.isRegistered,
      status: status,
      rules: rules,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }
}
