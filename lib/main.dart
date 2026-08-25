import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/app_localization.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/level_setup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/local_push_service.dart';
import 'services/remote_push_service.dart';
import 'services/connectivity_sync_service.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FluentianApp());
  ConnectivitySyncService.instance.start();
}

class FluentianApp extends StatelessWidget {
  const FluentianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => AppLocaleController()),
      ],
      child: Consumer2<AuthProvider, AppLocaleController>(
        builder: (context, auth, localeController, _) {
          final user = auth.user;
          final fontScale = switch (user?.fontScale ?? 1) {
            0 => 0.92,
            2 => 1.12,
            _ => 1.0,
          };
          final reduceAnimations = user?.reduceAnimationsEnabled ?? false;
          final theme = user?.highContrastEnabled == true
              ? FluentianTheme.lightTheme.copyWith(
                  colorScheme: FluentianTheme.lightTheme.colorScheme.copyWith(
                    primary: FluentianColors.primaryDark,
                    secondary: FluentianColors.primaryDark,
                  ),
                  textTheme: FluentianTheme.lightTheme.textTheme.apply(
                    bodyColor: Colors.black,
                    displayColor: Colors.black,
                  ),
                )
              : FluentianTheme.lightTheme;

          return MaterialApp(
            title: 'Fluentian',
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ],
            theme: theme,
            locale: localeController.locale,
            supportedLocales: AppLocaleController.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(fontScale),
                  disableAnimations: reduceAnimations,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const _AppRoot(),
          );
        },
      ),
    );
  }
}

/// Root widget that boots the app and routes based on auth state.
class _AppRoot extends StatefulWidget {
  const _AppRoot();
  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _hasLoadedData = false;
  @override
  void initState() {
    super.initState();

    // Initialize auth on startup (restores tokens or clears stale ones)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        Widget child;
        final user = auth.user;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (auth.status == AuthStatus.authenticated && user != null) {
            LocalPushService.instance.configure(
              notificationsEnabled: user.notificationsEnabled,
              learningReminderEnabled: user.learningReminderEnabled,
              reminderTime: user.reminderTime,
            );
            RemotePushService.instance.configure(
              enabled: user.notificationsEnabled,
            );
          } else {
            LocalPushService.instance.configure(
              notificationsEnabled: false,
              learningReminderEnabled: false,
              reminderTime: '08:00',
            );
          }
        });
        switch (auth.status) {
          case AuthStatus.unknown:
            child = const SplashScreen(key: ValueKey('splash'));
            break;
          case AuthStatus.authenticated:
            if (!auth.hasCompletedSetup) {
              _hasLoadedData = false;
              child = const LevelSetupScreen(key: ValueKey('level_setup'));
            } else {
              if (!_hasLoadedData) {
                _hasLoadedData = true;
                final learnerLanguage = user?.baseLanguageCode ?? 'en';
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (context.mounted) {
                    final localeController = context
                        .read<AppLocaleController>();
                    if (localeController.locale.languageCode !=
                        learnerLanguage) {
                      await localeController.setLocale(Locale(learnerLanguage));
                    }
                    if (!context.mounted) return;
                    context.read<ContentProvider>().loadHomeData();
                    context.read<ContentProvider>().loadLessonProgress();
                  }
                });
              }
              child = const HomeScreen(key: ValueKey('home'));
            }
            break;
          case AuthStatus.unauthenticated:
            _hasLoadedData = false;
            if (auth.hasSeenIntro) {
              child = const SignInScreen(key: ValueKey('sign_in'));
            } else {
              child = const OnboardingScreen(key: ValueKey('onboarding'));
            }
            break;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: child,
        );
      },
    );
  }
}
