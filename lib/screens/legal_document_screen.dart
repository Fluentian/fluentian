import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/theme.dart';

/// Shows a legal document (Privacy Policy, Terms and Conditions, etc.)
/// in-app instead of redirecting to an external browser -- the standard
/// pattern in most production apps.
class LegalDocumentScreen extends StatefulWidget {
  final String title;
  final String url;

  const LegalDocumentScreen({super.key, required this.title, required this.url});

  static Route<void> route({required String title, required String url}) {
    return MaterialPageRoute(
      builder: (_) => LegalDocumentScreen(title: title, url: url),
    );
  }

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(FluentianColors.pageBg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: LText(
          widget.title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: FluentianColors.pageBg,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          if (!_hasError) WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            const Center(child: CircularProgressIndicator()),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 40,
                      color: FluentianColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    LText(
                      'Could not load this page. Check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
