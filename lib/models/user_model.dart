/// User data models — mirrors backend UserBriefResponse & UserProfile.

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String currentLevel;
  final int xpTotal;
  final int streakDays;
  final int hearts;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.currentLevel,
    required this.xpTotal,
    required this.streakDays,
    required this.hearts,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        currentLevel: json['current_level'] as String? ?? 'A0',
        xpTotal: json['xp_total'] as int? ?? 0,
        streakDays: json['streak_days'] as int? ?? 0,
        hearts: json['hearts'] as int? ?? 5,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role,
        'current_level': currentLevel,
        'xp_total': xpTotal,
        'streak_days': streakDays,
        'hearts': hearts,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? currentLevel,
    int? xpTotal,
    int? streakDays,
    int? hearts,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        role: role ?? this.role,
        currentLevel: currentLevel ?? this.currentLevel,
        xpTotal: xpTotal ?? this.xpTotal,
        streakDays: streakDays ?? this.streakDays,
        hearts: hearts ?? this.hearts,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Greeting based on time of day.
  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Returns display name (username fallback).
  String get displayName => username;
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
