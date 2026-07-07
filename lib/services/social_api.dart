import 'api_client.dart';

class SpeakingCallSession {
  final String roomToken;
  final String providerRoomName;
  final String serverUrl;
  final int durationSeconds;
  final List<String> prompts;

  const SpeakingCallSession({
    required this.roomToken,
    required this.providerRoomName,
    required this.serverUrl,
    required this.durationSeconds,
    required this.prompts,
  });

  factory SpeakingCallSession.fromJson(Map<String, dynamic> json) {
    final prompts = json['prompts'];
    return SpeakingCallSession(
      roomToken: json['room_token']?.toString() ?? '',
      providerRoomName: json['provider_room_name']?.toString() ?? '',
      serverUrl: json['server_url']?.toString() ?? '',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 240,
      prompts: prompts is List
          ? prompts.map((item) => item.toString()).toList()
          : const [],
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
  }) async {
    final data = await _api.post('/social/speaking-calls', {
      'topic': topic,
      if (level != null && level.isNotEmpty) 'level': level,
      'call_kind': callKind,
    });
    return SpeakingCallSession.fromJson(data);
  }
}
