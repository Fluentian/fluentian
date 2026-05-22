import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/sign_in_screen.dart';

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
    // Initialize auth on startup (restores tokens or clears stale ones)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.unknown:
            // Show splash while we determine auth state
            return const SplashScreen();
          case AuthStatus.authenticated:
            // Pre-load home data as soon as user is confirmed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ContentProvider>().loadHomeData();
              context.read<ContentProvider>().loadLessonProgress();
            });
            return const HomeScreen();
          case AuthStatus.unauthenticated:
            return const SignInScreen();
        }
      },
    );
  }
}
