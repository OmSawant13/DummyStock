class UserModel {
  final String id;
  final String name;
  final String email;
  final String college;
  final String studentId;
  final String role; // 'Student', 'Institutional Trader', 'Professor/Admin'
  final DateTime registeredAt;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    required this.studentId,
    this.role = 'Student',
    required this.registeredAt,
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'college': college,
    'studentId': studentId,
    'role': role,
    'registeredAt': registeredAt.toIso8601String(),
    'avatarUrl': avatarUrl,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    college: json['college'],
    studentId: json['studentId'] ?? 'STU-2026',
    role: json['role'] ?? 'Student',
    registeredAt: DateTime.parse(json['registeredAt']),
    avatarUrl: json['avatarUrl'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
  );
}
