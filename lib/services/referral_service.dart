import 'package:share_plus/share_plus.dart';
import 'product_analytics.dart';

class ReferralService {
  ReferralService._();
  static final instance = ReferralService._();

  Future<void> shareInvite(String username) async {
    // Until referral attribution has a public route, share the stable landing
    // page rather than a personalized URL that returns 404.
    const link = 'https://fluentianapp.binovatechnologies.com/';
    await ProductAnalytics.instance.event('invite_share_started');
    await Share.share(
      'Join me on Fluentian and learn French together! $link',
      subject: 'Learn French with Fluentian',
    );
    await ProductAnalytics.instance.event('invite_shared');
  }
}
