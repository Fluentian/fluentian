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
  final DateTime? birthDate;
  final String? learningMotivation;
  final String? priorFrenchExposure;
  final bool isFounder;
  final int dailyGoalMinutes;
  final int startingUnitNo;
  final String baseLanguageCode;
  final bool notificationsEnabled;
  final bool autoplayAudio;
  final bool soundEnabled;
  final bool learningReminderEnabled;
  final String reminderTime;
  final String timezone;
  final bool opportunityNotificationsEnabled;
  final bool phoneticHintsEnabled;
  final bool speakingExercisesEnabled;
  final bool highContrastEnabled;
  final bool reduceAnimationsEnabled;
  final bool hapticFeedbackEnabled;
  final double ttsSpeed;
  final int fontScale;
  final String preferredVoiceId;

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
    this.birthDate,
    this.learningMotivation,
    this.priorFrenchExposure,
    this.isFounder = false,
    this.dailyGoalMinutes = 15,
    this.startingUnitNo = 1,
    this.baseLanguageCode = 'en',
    this.notificationsEnabled = true,
    this.autoplayAudio = true,
    this.soundEnabled = true,
    this.learningReminderEnabled = true,
    this.reminderTime = '08:00',
    this.timezone = 'Africa/Addis_Ababa',
    this.opportunityNotificationsEnabled = true,
    this.phoneticHintsEnabled = true,
    this.speakingExercisesEnabled = true,
    this.highContrastEnabled = false,
    this.reduceAnimationsEnabled = false,
    this.hapticFeedbackEnabled = true,
    this.ttsSpeed = 1.0,
    this.fontScale = 1,
    this.preferredVoiceId = 'claire',
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
      birthDate: (profile?['birth_date'] ?? json['birth_date']) != null
          ? DateTime.tryParse(
              (profile?['birth_date'] ?? json['birth_date']).toString(),
            )
          : null,
      learningMotivation:
          profile?['learning_motivation']?.toString() ??
          json['learning_motivation']?.toString(),
      priorFrenchExposure:
          profile?['prior_french_exposure']?.toString() ??
          json['prior_french_exposure']?.toString(),
      isFounder:
          profile?['is_founder'] as bool? ??
          json['is_founder'] as bool? ??
          false,
      dailyGoalMinutes: json['daily_goal_minutes'] as int? ?? 15,
      startingUnitNo: json['starting_unit_no'] as int? ?? 1,
      baseLanguageCode: json['base_language_code']?.toString() ?? 'en',
      notificationsEnabled: settings?['notifications_enabled'] as bool? ?? true,
      autoplayAudio: settings?['autoplay_audio'] as bool? ?? true,
      soundEnabled: settings?['sound_enabled'] as bool? ?? true,
      learningReminderEnabled:
          settings?['learning_reminder_enabled'] as bool? ?? true,
      reminderTime: settings?['reminder_time']?.toString() ?? '08:00',
      timezone:
          settings?['timezone']?.toString() ?? 'Africa/Addis_Ababa',
      opportunityNotificationsEnabled:
          settings?['opportunity_notifications_enabled'] as bool? ?? true,
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
      preferredVoiceId: profile?['preferred_voice_id']?.toString() ?? 'claire',
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
    'birth_date': birthDate?.toIso8601String().split('T').first,
    'learning_motivation': learningMotivation,
    'prior_french_exposure': priorFrenchExposure,
    'is_founder': isFounder,
    'daily_goal_minutes': dailyGoalMinutes,
    'starting_unit_no': startingUnitNo,
    'base_language_code': baseLanguageCode,
    'settings': {
      'notifications_enabled': notificationsEnabled,
      'autoplay_audio': autoplayAudio,
      'sound_enabled': soundEnabled,
      'learning_reminder_enabled': learningReminderEnabled,
      'reminder_time': reminderTime,
      'timezone': timezone,
      'opportunity_notifications_enabled': opportunityNotificationsEnabled,
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
    DateTime? birthDate,
    String? learningMotivation,
    String? priorFrenchExposure,
    bool? isFounder,
    int? dailyGoalMinutes,
    int? startingUnitNo,
    String? baseLanguageCode,
    bool? notificationsEnabled,
    bool? autoplayAudio,
    bool? soundEnabled,
    bool? learningReminderEnabled,
    String? reminderTime,
    String? timezone,
    bool? opportunityNotificationsEnabled,
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
    birthDate: birthDate ?? this.birthDate,
    learningMotivation: learningMotivation ?? this.learningMotivation,
    priorFrenchExposure: priorFrenchExposure ?? this.priorFrenchExposure,
    isFounder: isFounder ?? this.isFounder,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    startingUnitNo: startingUnitNo ?? this.startingUnitNo,
    baseLanguageCode: baseLanguageCode ?? this.baseLanguageCode,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    autoplayAudio: autoplayAudio ?? this.autoplayAudio,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    learningReminderEnabled:
        learningReminderEnabled ?? this.learningReminderEnabled,
    reminderTime: reminderTime ?? this.reminderTime,
    timezone: timezone ?? this.timezone,
    opportunityNotificationsEnabled:
        opportunityNotificationsEnabled ?? this.opportunityNotificationsEnabled,
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
