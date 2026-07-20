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

  Future<List<LiveRoomModel>> getLiveRooms() async {
    final items = await _api.getList('/social/live-rooms');
    return items
        .whereType<Map>()
        .map((item) => LiveRoomModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SpeakingCallSession> joinLiveRoom({
    required String roomId,
    String callKind = 'audio',
  }) async {
    final data = await _api.post('/social/live-rooms/join', {
      'room_id': roomId,
      'call_kind': callKind,
    });
    return SpeakingCallSession.fromJson(data);
  }

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

  Future<List<ChatRoomModel>> getChatRooms() async {
    final data = await _api.get('/social/rooms?size=50');
    final items = data['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((item) => ChatRoomModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ChatMessageModel>> getChatMessages(String roomId) async {
    final data = await _api.get('/social/rooms/$roomId/messages?size=50');
    final items = data['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map(
          (item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList()
        .reversed
        .toList();
  }

  Future<ChatMessageModel> sendChatMessage({
    required String roomId,
    required String body,
  }) async {
    final data = await _api.post('/social/rooms/$roomId/messages', {
      'body': body.trim(),
      'message_kind': 'text',
    });
    return ChatMessageModel.fromJson(data);
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

  Future<List<VocabularyItem>> getVocabulary() async {
    final items = await _api.getList('/social/vocabulary');
    return items
        .whereType<Map>()
        .map((item) => VocabularyItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<VocabularyItem> saveVocabulary({
    required String word,
    required String storyId,
    required String sourceSentence,
    required String translatedSentence,
    String translation = '',
  }) async {
    final data = await _api.post('/social/vocabulary', {
      'word': word,
      'story_id': storyId,
      'translation': translation,
      'source_sentence': sourceSentence,
      'translated_sentence': translatedSentence,
    });
    return VocabularyItem.fromJson(data);
  }

  Future<void> deleteVocabulary(String id) =>
      _api.delete('/social/vocabulary/$id');

  Future<List<AccountabilityPartnership>> getPartnerships() async {
    final items = await _api.getList('/social/accountability');
    return items
        .whereType<Map>()
        .map(
          (item) => AccountabilityPartnership.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<AccountabilityPartnership> createPartnership({
    required String partnerId,
    required String goalKind,
    required int targetValue,
    required int durationDays,
    String message = '',
  }) async {
    final data = await _api.post('/social/accountability', {
      'partner_id': partnerId,
      'goal_kind': goalKind,
      'target_value': targetValue,
      'duration_days': durationDays,
      'message': message,
    });
    return AccountabilityPartnership.fromJson(data);
  }

  Future<AccountabilityPartnership> updatePartnership(
    String id,
    String status,
  ) async {
    final data = await _api.patch('/social/accountability/$id', {
      'status': status,
    });
    return AccountabilityPartnership.fromJson(data);
  }

  Future<void> blockUser(String userId) =>
      _api.post('/social/safety/blocks/$userId', {});

  Future<void> reportUser({
    required String roomName,
    required String category,
    String? reportedUserId,
    String details = '',
    bool blockUser = false,
  }) => _api.post('/social/safety/reports', {
    'room_name': roomName,
    'category': category,
    if (reportedUserId != null) 'reported_user_id': reportedUserId,
    'details': details,
    'block_user': blockUser,
  });
}

class VocabularyItem {
  final String id, word, translation, sourceSentence, translatedSentence;
  final int masteryLevel, reviewCount;
  const VocabularyItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.sourceSentence,
    required this.translatedSentence,
    required this.masteryLevel,
    required this.reviewCount,
  });
  factory VocabularyItem.fromJson(Map<String, dynamic> json) => VocabularyItem(
    id: json['id']?.toString() ?? '',
    word: json['word']?.toString() ?? '',
    translation: json['translation']?.toString() ?? '',
    sourceSentence: json['source_sentence']?.toString() ?? '',
    translatedSentence: json['translated_sentence']?.toString() ?? '',
    masteryLevel: (json['mastery_level'] as num?)?.toInt() ?? 0,
    reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  );
}

class AccountabilityPartnership {
  final String id, status, direction, goalKind, message;
  final int targetValue, durationDays, myProgress, partnerProgress;
  final DateTime? endsAt;
  final FriendSummary partner;
  const AccountabilityPartnership({
    required this.id,
    required this.status,
    required this.direction,
    required this.goalKind,
    required this.message,
    required this.targetValue,
    required this.durationDays,
    required this.myProgress,
    required this.partnerProgress,
    required this.partner,
    this.endsAt,
  });
  double get myRatio =>
      targetValue == 0 ? 0 : (myProgress / targetValue).clamp(0, 1);
  double get partnerRatio =>
      targetValue == 0 ? 0 : (partnerProgress / targetValue).clamp(0, 1);
  factory AccountabilityPartnership.fromJson(Map<String, dynamic> json) =>
      AccountabilityPartnership(
        id: json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        direction: json['direction']?.toString() ?? 'incoming',
        goalKind: json['goal_kind']?.toString() ?? 'lessons',
        message: json['message']?.toString() ?? '',
        targetValue: (json['target_value'] as num?)?.toInt() ?? 5,
        durationDays: (json['duration_days'] as num?)?.toInt() ?? 7,
        myProgress: (json['my_progress'] as num?)?.toInt() ?? 0,
        partnerProgress: (json['partner_progress'] as num?)?.toInt() ?? 0,
        endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? ''),
        partner: FriendSummary.fromJson(
          Map<String, dynamic>.from(json['partner'] as Map? ?? const {}),
        ),
      );
}

class LiveRoomModel {
  final String id, title, description, roomType, eligibilityLabel;
  final bool eligible, isOpen;
  final int? capacity;
  final DateTime? scheduledAt;
  const LiveRoomModel({
    required this.id,
    required this.title,
    required this.description,
    required this.roomType,
    required this.eligibilityLabel,
    required this.eligible,
    required this.isOpen,
    this.capacity,
    this.scheduledAt,
  });
  factory LiveRoomModel.fromJson(Map<String, dynamic> json) => LiveRoomModel(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    roomType: json['room_type']?.toString() ?? '',
    eligibilityLabel: json['eligibility_label']?.toString() ?? '',
    eligible: json['eligible'] == true,
    isOpen: json['is_open'] == true,
    capacity: (json['capacity'] as num?)?.toInt(),
    scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? ''),
  );
}

class ChatRoomModel {
  final String id;
  final String title;
  final String roomKind;
  final String? targetLanguageId;
  final DateTime? createdAt;

  const ChatRoomModel({
    required this.id,
    required this.title,
    required this.roomKind,
    this.targetLanguageId,
    this.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) => ChatRoomModel(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? 'Chat room',
    roomKind: json['room_kind']?.toString() ?? 'group',
    targetLanguageId: json['target_language_id']?.toString(),
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
  );
}

class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderUserId;
  final String messageKind;
  final String body;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderUserId,
    required this.messageKind,
    required this.body,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id']?.toString() ?? '',
        roomId: json['room_id']?.toString() ?? '',
        senderUserId: json['sender_user_id']?.toString() ?? '',
        messageKind: json['message_kind']?.toString() ?? 'text',
        body: json['body']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
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
