import 'package:share_plus/share_plus.dart';
import 'product_analytics.dart';

class ReferralService {
  ReferralService._();
  static final instance = ReferralService._();

  Future<void> shareInvite(String username) async {
    final code = username.trim().toLowerCase();
    final link = 'https://fluentianapp.binovatechnologies.com/invite/$code';
    await ProductAnalytics.instance.event('invite_share_started');
    await Share.share(
      'Join me on Fluentian and learn French together! $link',
      subject: 'Learn French with Fluentian',
    );
    await ProductAnalytics.instance.event('invite_shared');
  }
}
