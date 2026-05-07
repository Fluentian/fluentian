import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';

void main() {
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
    return MaterialApp(
      title: 'Fluentian',
      debugShowCheckedModeBanner: false,
      theme: FluentianTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Fluentian Starting Project',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
