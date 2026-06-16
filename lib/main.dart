import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/level_setup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/local_push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FluentianApp());
}

class FluentianApp extends StatelessWidget {
  const FluentianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: MaterialApp(
        title: 'Fluentian',
        debugShowCheckedModeBanner: false,
        theme: FluentianTheme.lightTheme,
        home: const _AppRoot(),
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
  @override
  void initState() {
    super.initState();
    // Start background polling for native notifications
    LocalPushService.instance.initialize().then((_) {
      LocalPushService.instance.startPolling();
    });
    
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
        switch (auth.status) {
          case AuthStatus.unknown:
            child = const SplashScreen(key: ValueKey('splash'));
            break;
          case AuthStatus.authenticated:
            if (!auth.hasCompletedSetup) {
              child = const LevelSetupScreen(key: ValueKey('level_setup'));
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<ContentProvider>().loadHomeData();
                  context.read<ContentProvider>().loadLessonProgress();
                }
              });
              child = const HomeScreen(key: ValueKey('home'));
            }
            break;
          case AuthStatus.unauthenticated:
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
