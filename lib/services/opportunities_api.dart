import 'package:fluentian/services/api_client.dart';
import 'package:fluentian/services/offline_content_cache.dart';

class Opportunity {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime? deadline;
  final String? imageUrl;
  final String? ctaUrl;
  final String? ctaLabel;
  final bool isActive;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.deadline,
    this.imageUrl,
    this.ctaUrl,
    this.ctaLabel,
    required this.isActive,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      imageUrl: ApiClient.resolveMediaUrl(json['image_url'] as String?),
      ctaUrl: json['cta_url'] as String?,
      ctaLabel: json['cta_label'] as String?,
      isActive: json['is_active'],
    );
  }
}

class OpportunitiesApi {
  final ApiClient _client = ApiClient.instance;
  final OfflineContentCache _cache = OfflineContentCache.instance;
  static const _cacheKey = 'opportunities:all';

  Future<List<Opportunity>> getOpportunities() async {
    List<dynamic> items;
    try {
      items = await _client.getList('/opportunities');
      if (items.isNotEmpty) {
        await _cache.put(_cacheKey, items);
      }
    } catch (_) {
      items = await _cache.get<List<dynamic>>(_cacheKey) ?? const [];
    }

    return items
        .map((json) => Opportunity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> applyForOpportunity(String id, Map<String, dynamic> data) async {
    await _client.post('/opportunities/$id/apply', data);
  }
}
