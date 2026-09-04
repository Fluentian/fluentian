/// Every externally-hosted URL the app links to, in one place.
///
/// These were hardcoded across six files, which is how the Terms and Privacy
/// links ended up pointing at the *API* host rather than the marketing site.
/// Each value is overridable at build time with --dart-define so a staging
/// build does not need a code change.
library;

class Endpoints {
  const Endpoints._();

  /// Marketing / public website.
  static const String website = String.fromEnvironment(
    'WEBSITE_URL',
    defaultValue: 'https://fluentianapp.binovatechnologies.com',
  );

  /// API host. Legal pages are served by the API app, so they hang off this.
  static const String apiHost = String.fromEnvironment(
    'API_HOST_URL',
    defaultValue: 'https://api.fluentianapp.binovatechnologies.com',
  );

  /// LiveKit signalling host used by the call screens.
  static const String liveKitHost = String.fromEnvironment(
    'LIVEKIT_HOST_URL',
    defaultValue: 'https://live.binovatechnologies.com',
  );

  static String get terms => '$apiHost/terms';
  static String get privacy => '$apiHost/privacy';
  static String get help => '$website/help';

  /// Legal/support pages addressed by slug from Settings.
  static String legalPage(String slug) => '$apiHost/$slug';

  /// Link shared by the referral flow.
  static String get referralLink => '$website/';
}
