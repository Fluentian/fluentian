import 'package:fluentian/services/opportunities_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an opportunity external CTA', () {
    final opportunity = Opportunity.fromJson({
      'id': 'opportunity-1',
      'title': 'French internship',
      'description': 'Apply with our partner.',
      'type': 'internship',
      'deadline': null,
      'cta_url': 'https://example.com/apply',
      'cta_label': 'Apply externally',
      'is_active': true,
    });

    expect(opportunity.ctaUrl, 'https://example.com/apply');
    expect(opportunity.ctaLabel, 'Apply externally');
  });
}
