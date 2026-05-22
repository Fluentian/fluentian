import 'package:fluentian/services/api_client.dart';
import 'package:uuid/uuid.dart';

class Opportunity {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime? deadline;
  final bool isActive;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.deadline,
    required this.isActive,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isActive: json['is_active'],
    );
  }
}

class OpportunitiesApi {
  final ApiClient _client = ApiClient();

  Future<List<Opportunity>> getOpportunities() async {
    final response = await _client.get('/opportunities');
    final List<dynamic> items = response.data['items'];
    return items.map((json) => Opportunity.fromJson(json)).toList();
  }

  Future<void> applyForOpportunity(String id, Map<String, dynamic> data) async {
    await _client.post('/opportunities/$id/apply', data: data);
  }
}
