class LiveKitConfig {
  LiveKitConfig._();

  static const serverUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: 'wss://live.binovatechnologies.com',
  );
}
