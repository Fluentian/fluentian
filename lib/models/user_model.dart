/// User data models — mirrors backend UserBriefResponse & UserProfile.
library;

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String currentLevel;
  final int xpTotal;
  final int streakDays;
  final int hearts;
  final DateTime? nextHeartRefillAt;
  final DateTime createdAt;
  final String? displayNameField;
  final String? avatarUrl;
  final String? bio;
  final String? learningGoal;
  final int dailyGoalMinutes;
  final bool notificationsEnabled;
  final bool autoplayAudio;
  final bool soundEnabled;
  final bool learningReminderEnabled;
  final String reminderTime;
  final bool phoneticHintsEnabled;
  final bool speakingExercisesEnabled;
  final bool highContrastEnabled;
  final bool reduceAnimationsEnabled;
  final bool hapticFeedbackEnabled;
  final double ttsSpeed;
  final int fontScale;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.currentLevel,
    required this.xpTotal,
    required this.streakDays,
    required this.hearts,
    this.nextHeartRefillAt,
    required this.createdAt,
    this.displayNameField,
    this.avatarUrl,
    this.bio,
    this.learningGoal,
    this.dailyGoalMinutes = 15,
    this.notificationsEnabled = true,
    this.autoplayAudio = true,
    this.soundEnabled = true,
    this.learningReminderEnabled = true,
    this.reminderTime = '08:00',
    this.phoneticHintsEnabled = true,
    this.speakingExercisesEnabled = true,
    this.highContrastEnabled = false,
    this.reduceAnimationsEnabled = false,
    this.hapticFeedbackEnabled = true,
    this.ttsSpeed = 1.0,
    this.fontScale = 1,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<dynamic, dynamic>?;
    final settings = json['settings'] as Map<dynamic, dynamic>?;
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      currentLevel: json['current_level'] as String? ?? 'A0',
      xpTotal: json['xp_total'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      hearts: json['hearts'] as int? ?? 5,
      nextHeartRefillAt: json['next_heart_refill_at'] != null
          ? DateTime.parse(json['next_heart_refill_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      displayNameField:
          profile?['display_name']?.toString() ??
          json['display_name_field']?.toString(),
      avatarUrl:
          profile?['avatar_url']?.toString() ?? json['avatar_url']?.toString(),
      bio: profile?['bio']?.toString() ?? json['bio']?.toString(),
      learningGoal:
          profile?['learning_goal']?.toString() ??
          json['learning_goal']?.toString(),
      dailyGoalMinutes: json['daily_goal_minutes'] as int? ?? 15,
      notificationsEnabled: settings?['notifications_enabled'] as bool? ?? true,
      autoplayAudio: settings?['autoplay_audio'] as bool? ?? true,
      soundEnabled: settings?['sound_enabled'] as bool? ?? true,
      learningReminderEnabled:
          settings?['learning_reminder_enabled'] as bool? ?? true,
      reminderTime: settings?['reminder_time']?.toString() ?? '08:00',
      phoneticHintsEnabled:
          settings?['phonetic_hints_enabled'] as bool? ?? true,
      speakingExercisesEnabled:
          settings?['speaking_exercises_enabled'] as bool? ?? true,
      highContrastEnabled: settings?['high_contrast_enabled'] as bool? ?? false,
      reduceAnimationsEnabled:
          settings?['reduce_animations_enabled'] as bool? ?? false,
      hapticFeedbackEnabled:
          settings?['haptic_feedback_enabled'] as bool? ?? true,
      ttsSpeed: (settings?['tts_speed'] as num?)?.toDouble() ?? 1.0,
      fontScale: settings?['font_scale'] as int? ?? 1,
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
    'next_heart_refill_at': nextHeartRefillAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'display_name_field': displayNameField,
    'avatar_url': avatarUrl,
    'bio': bio,
    'learning_goal': learningGoal,
    'daily_goal_minutes': dailyGoalMinutes,
    'settings': {
      'notifications_enabled': notificationsEnabled,
      'autoplay_audio': autoplayAudio,
      'sound_enabled': soundEnabled,
      'learning_reminder_enabled': learningReminderEnabled,
      'reminder_time': reminderTime,
      'phonetic_hints_enabled': phoneticHintsEnabled,
      'speaking_exercises_enabled': speakingExercisesEnabled,
      'high_contrast_enabled': highContrastEnabled,
      'reduce_animations_enabled': reduceAnimationsEnabled,
      'haptic_feedback_enabled': hapticFeedbackEnabled,
      'tts_speed': ttsSpeed,
      'font_scale': fontScale,
    },
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
    DateTime? nextHeartRefillAt,
    bool clearNextHeartRefillAt = false,
    DateTime? createdAt,
    String? displayNameField,
    String? avatarUrl,
    String? bio,
    String? learningGoal,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
    bool? autoplayAudio,
    bool? soundEnabled,
    bool? learningReminderEnabled,
    String? reminderTime,
    bool? phoneticHintsEnabled,
    bool? speakingExercisesEnabled,
    bool? highContrastEnabled,
    bool? reduceAnimationsEnabled,
    bool? hapticFeedbackEnabled,
    double? ttsSpeed,
    int? fontScale,
  }) => UserModel(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    role: role ?? this.role,
    currentLevel: currentLevel ?? this.currentLevel,
    xpTotal: xpTotal ?? this.xpTotal,
    streakDays: streakDays ?? this.streakDays,
    hearts: hearts ?? this.hearts,
    nextHeartRefillAt: clearNextHeartRefillAt
        ? null
        : nextHeartRefillAt ?? this.nextHeartRefillAt,
    createdAt: createdAt ?? this.createdAt,
    displayNameField: displayNameField ?? this.displayNameField,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    bio: bio ?? this.bio,
    learningGoal: learningGoal ?? this.learningGoal,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    autoplayAudio: autoplayAudio ?? this.autoplayAudio,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    learningReminderEnabled:
        learningReminderEnabled ?? this.learningReminderEnabled,
    reminderTime: reminderTime ?? this.reminderTime,
    phoneticHintsEnabled: phoneticHintsEnabled ?? this.phoneticHintsEnabled,
    speakingExercisesEnabled:
        speakingExercisesEnabled ?? this.speakingExercisesEnabled,
    highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
    reduceAnimationsEnabled:
        reduceAnimationsEnabled ?? this.reduceAnimationsEnabled,
    hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    ttsSpeed: ttsSpeed ?? this.ttsSpeed,
    fontScale: fontScale ?? this.fontScale,
  );

  /// Greeting based on time of day.
  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Returns display name (username fallback).
  String get displayName =>
      (displayNameField != null && displayNameField!.isNotEmpty)
      ? displayNameField!
      : username;
}

class HeartStatus {
  final int hearts;
  final int maxHearts;
  final DateTime? nextRefillAt;

  const HeartStatus({
    required this.hearts,
    required this.maxHearts,
    this.nextRefillAt,
  });

  factory HeartStatus.fromJson(Map<String, dynamic> json) => HeartStatus(
    hearts: json['hearts'] as int? ?? 5,
    maxHearts: json['max_hearts'] as int? ?? 5,
    nextRefillAt: json['next_refill_at'] != null
        ? DateTime.parse(json['next_refill_at'] as String)
        : null,
  );
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
