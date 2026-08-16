import 'package:fluentian/services/api_client.dart';

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

  static final List<Opportunity> _curatedOpportunities = [
    Opportunity(
      id: 'opp-eiffel-scholarship',
      title: 'Eiffel Excellence Master & PhD Scholarship',
      description:
          'Fully funded French Ministry for Europe and Foreign Affairs scholarship covering monthly allowance, travel, and health insurance for postgraduate studies in France.',
      type: 'scholarships',
      deadline: DateTime.now().add(const Duration(days: 90)),
      imageUrl:
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&q=80&w=1200',
      ctaUrl: 'https://www.campusfrance.org/en/the-eiffel-scholarship-program',
      ctaLabel: 'Apply on Campus France',
      isActive: true,
    ),
    Opportunity(
      id: 'opp-au-bilingual-intern',
      title: 'Bilingual Project Intern (English/French)',
      description:
          'African Union Commission internship in Addis Ababa. Assist diplomatic communications, bilateral translation, and francophone liaison teams.',
      type: 'jobs',
      deadline: DateTime.now().add(const Duration(days: 45)),
      imageUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=1200',
      ctaUrl: 'https://careers.au.int',
      ctaLabel: 'View AU Posting',
      isActive: true,
    ),
    Opportunity(
      id: 'opp-alliance-exchange',
      title: 'Alliance Française Cultural Immersion Program',
      description:
          'Join the semester-long French conversation & cultural exchange initiative hosted with Alliance Éthio-Française in Addis Ababa.',
      type: 'exchange',
      deadline: DateTime.now().add(const Duration(days: 60)),
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&q=80&w=1200',
      ctaUrl: 'https://allianceaddis.org',
      ctaLabel: 'Learn More',
      isActive: true,
    ),
    Opportunity(
      id: 'opp-un-volunteer-french',
      title: 'UN Online Translation & Literacy Volunteer',
      description:
          'Support francophone humanitarian educational material translation across East Africa with the United Nations Volunteers program.',
      type: 'volunteer',
      deadline: DateTime.now().add(const Duration(days: 30)),
      imageUrl:
          'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?auto=format&fit=crop&q=80&w=1200',
      ctaUrl: 'https://www.unv.org',
      ctaLabel: 'Apply to Volunteer',
      isActive: true,
    ),
  ];

  Future<List<Opportunity>> getOpportunities() async {
    try {
      final items = await _client.getList('/opportunities');
      final fetched = items
          .map((json) => Opportunity.fromJson(json as Map<String, dynamic>))
          .toList();
      if (fetched.isNotEmpty) return fetched;
    } catch (_) {
      // Fallback on curated opportunities when offline or empty
    }
    return _curatedOpportunities;
  }

  Future<void> applyForOpportunity(String id, Map<String, dynamic> data) async {
    await _client.post('/opportunities/$id/apply', data);
  }
}
