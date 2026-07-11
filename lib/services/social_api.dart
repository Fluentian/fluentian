import 'api_client.dart';
import '../core/livekit_config.dart';

class SpeakingCallSession {
  final String roomToken;
  final String providerRoomName;
  final String serverUrl;
  final int durationSeconds;
  final List<String> prompts;
  final String? topic;
  final String? level;
  final String? matchStrategy;
  final String? matchReason;

  const SpeakingCallSession({
    required this.roomToken,
    required this.providerRoomName,
    required this.serverUrl,
    required this.durationSeconds,
    required this.prompts,
    this.topic,
    this.level,
    this.matchStrategy,
    this.matchReason,
  });

  factory SpeakingCallSession.fromJson(Map<String, dynamic> json) {
    final prompts = json['prompts'];
    final serverUrl = json['server_url']?.toString().trim();
    return SpeakingCallSession(
      roomToken: json['room_token']?.toString() ?? '',
      providerRoomName: json['provider_room_name']?.toString() ?? '',
      serverUrl: serverUrl == null || serverUrl.isEmpty
          ? LiveKitConfig.serverUrl
          : serverUrl,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 240,
      prompts: prompts is List
          ? prompts.map((item) => item.toString()).toList()
          : const [],
      topic: json['topic']?.toString(),
      level: json['level']?.toString(),
      matchStrategy: json['match_strategy']?.toString(),
      matchReason: json['match_reason']?.toString(),
    );
  }
}

class SocialApi {
  SocialApi._();
  static final SocialApi instance = SocialApi._();

  final _api = ApiClient.instance;

  Future<SpeakingCallSession> createSpeakingCall({
    required String topic,
    String? level,
    String callKind = 'audio',
    bool smartMatch = false,
  }) async {
    final data = await _api.post('/social/speaking-calls', {
      'topic': topic,
      if (level != null && level.isNotEmpty) 'level': level,
      'call_kind': callKind,
      'smart_match': smartMatch,
    });
    return SpeakingCallSession.fromJson(data);
  }

  Future<List<FriendSummary>> getFriends() async {
    final items = await _api.getList('/social/friends');
    return items
        .whereType<Map>()
        .map((item) => FriendSummary.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<FriendSummary>> searchUsers(String query) async {
    final encoded = Uri.encodeQueryComponent(query);
    final items = await _api.getList('/social/friends/search?q=$encoded');
    return items
        .whereType<Map>()
        .map((item) => FriendSummary.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<FriendRequest>> getFriendRequests() async {
    final items = await _api.getList('/social/friends/requests');
    return items
        .whereType<Map>()
        .map((item) => FriendRequest.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<FriendRequest> sendFriendRequest(String username) async {
    final data = await _api.post('/social/friends/requests', {
      'username': username,
    });
    return FriendRequest.fromJson(data);
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _api.post('/social/friends/requests/$requestId/accept', {});
  }

  Future<void> declineOrCancelFriendRequest(String requestId) async {
    await _api.delete('/social/friends/requests/$requestId');
  }

  Future<void> removeFriend(String friendId) async {
    await _api.delete('/social/friends/$friendId');
  }

  Future<List<FriendActivity>> getFriendActivity() async {
    final items = await _api.getList('/social/friends/activity');
    return items
        .whereType<Map>()
        .map((item) => FriendActivity.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<FriendChallenge>> getChallenges() async {
    final items = await _api.getList('/social/challenges');
    return items
        .whereType<Map>()
        .map(
          (item) => FriendChallenge.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<FriendChallenge> createChallenge({
    required String friendId,
    String challengeKind = 'xp',
    int targetValue = 100,
    int durationDays = 7,
    String? title,
  }) async {
    final data = await _api.post('/social/challenges', {
      'friend_id': friendId,
      'challenge_kind': challengeKind,
      'target_value': targetValue,
      'duration_days': durationDays,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
    });
    return FriendChallenge.fromJson(data);
  }

  Future<FriendChallenge> updateChallengeStatus({
    required String challengeId,
    required String status,
  }) async {
    final data = await _api.patch('/social/challenges/$challengeId', {
      'status': status,
    });
    return FriendChallenge.fromJson(data);
  }
}

class FriendSummary {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String currentLevel;
  final int xpTotal;
  final int streakDays;
  final int lessonsCompleted;
  final int unitsCompleted;

  const FriendSummary({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.currentLevel,
    required this.xpTotal,
    required this.streakDays,
    required this.lessonsCompleted,
    required this.unitsCompleted,
  });

  factory FriendSummary.fromJson(Map<String, dynamic> json) => FriendSummary(
    id: json['id']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
    displayName: json['display_name']?.toString() ?? 'Friend',
    avatarUrl: json['avatar_url']?.toString(),
    currentLevel: json['current_level']?.toString() ?? 'A1',
    xpTotal: (json['xp_total'] as num?)?.toInt() ?? 0,
    streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
    lessonsCompleted: (json['lessons_completed'] as num?)?.toInt() ?? 0,
    unitsCompleted: (json['units_completed'] as num?)?.toInt() ?? 0,
  );
}

class FriendRequest {
  final String id;
  final String direction;
  final String status;
  final DateTime createdAt;
  final FriendSummary user;

  const FriendRequest({
    required this.id,
    required this.direction,
    required this.status,
    required this.createdAt,
    required this.user,
  });

  bool get isIncoming => direction == 'incoming';

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id: json['id']?.toString() ?? '',
    direction: json['direction']?.toString() ?? 'incoming',
    status: json['status']?.toString() ?? 'pending',
    createdAt:
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now(),
    user: FriendSummary.fromJson(
      Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
    ),
  );
}

class FriendChallenge {
  final String id;
  final String status;
  final String direction;
  final String challengeKind;
  final String title;
  final int targetValue;
  final int durationDays;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? endsAt;
  final FriendSummary challenger;
  final FriendSummary challenged;
  final int myProgress;
  final int friendProgress;

  const FriendChallenge({
    required this.id,
    required this.status,
    required this.direction,
    required this.challengeKind,
    required this.title,
    required this.targetValue,
    required this.durationDays,
    required this.createdAt,
    this.acceptedAt,
    this.endsAt,
    required this.challenger,
    required this.challenged,
    required this.myProgress,
    required this.friendProgress,
  });

  double get myRatio =>
      targetValue <= 0 ? 0 : (myProgress / targetValue).clamp(0, 1);
  double get friendRatio =>
      targetValue <= 0 ? 0 : (friendProgress / targetValue).clamp(0, 1);

  factory FriendChallenge.fromJson(Map<String, dynamic> json) =>
      FriendChallenge(
        id: json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        direction: json['direction']?.toString() ?? 'incoming',
        challengeKind: json['challenge_kind']?.toString() ?? 'xp',
        title: json['title']?.toString() ?? 'Friend challenge',
        targetValue: (json['target_value'] as num?)?.toInt() ?? 100,
        durationDays: (json['duration_days'] as num?)?.toInt() ?? 7,
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        acceptedAt: DateTime.tryParse(json['accepted_at']?.toString() ?? ''),
        endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? ''),
        challenger: FriendSummary.fromJson(
          Map<String, dynamic>.from(json['challenger'] as Map? ?? const {}),
        ),
        challenged: FriendSummary.fromJson(
          Map<String, dynamic>.from(json['challenged'] as Map? ?? const {}),
        ),
        myProgress: (json['my_progress'] as num?)?.toInt() ?? 0,
        friendProgress: (json['friend_progress'] as num?)?.toInt() ?? 0,
      );
}

class FriendActivity {
  final String id;
  final String activityKind;
  final String title;
  final String body;
  final DateTime createdAt;
  final FriendSummary actor;
  final Map<String, dynamic> metadata;

  const FriendActivity({
    required this.id,
    required this.activityKind,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.actor,
    required this.metadata,
  });

  factory FriendActivity.fromJson(Map<String, dynamic> json) => FriendActivity(
    id: json['id']?.toString() ?? '',
    activityKind: json['activity_kind']?.toString() ?? 'activity',
    title: json['title']?.toString() ?? 'made progress',
    body: json['body']?.toString() ?? '',
    createdAt:
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now(),
    actor: FriendSummary.fromJson(
      Map<String, dynamic>.from(json['actor'] as Map? ?? const {}),
    ),
    metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
  );
}
