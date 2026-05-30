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
  final String? displayNameField;
  final String? avatarUrl;
  final String? bio;
  final String? learningGoal;

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
    this.displayNameField,
    this.avatarUrl,
    this.bio,
    this.learningGoal,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<dynamic, dynamic>?;
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      currentLevel: json['current_level'] as String? ?? 'A0',
      xpTotal: json['xp_total'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      hearts: json['hearts'] as int? ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String),
      displayNameField: profile?['display_name']?.toString() ?? json['display_name_field']?.toString(),
      avatarUrl: profile?['avatar_url']?.toString() ?? json['avatar_url']?.toString(),
      bio: profile?['bio']?.toString() ?? json['bio']?.toString(),
      learningGoal: profile?['learning_goal']?.toString() ?? json['learning_goal']?.toString(),
    );
  }

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
        'display_name_field': displayNameField,
        'avatar_url': avatarUrl,
        'bio': bio,
        'learning_goal': learningGoal,
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
    String? displayNameField,
    String? avatarUrl,
    String? bio,
    String? learningGoal,
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
        displayNameField: displayNameField ?? this.displayNameField,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        learningGoal: learningGoal ?? this.learningGoal,
      );

  /// Greeting based on time of day.
  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Returns display name (username fallback).
  String get displayName => (displayNameField != null && displayNameField!.isNotEmpty)
      ? displayNameField!
      : username;
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
