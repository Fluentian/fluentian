import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';

class CallScreen extends StatelessWidget {
  final bool isVideo;

  const CallScreen({super.key, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'End-to-end Encrypted',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 32), // Balance spacing
                ],
              ),
            ),
            const Spacer(),
            // Avatar or Video feed representation
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: FluentianColors.headerGradient,
                border: Border.all(color: Colors.white24, width: 4),
              ),
              child: const Center(
                child: Icon(Iconsax.user, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Language Partner',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '02:45', // mock duration
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
            ),
            const Spacer(),
            // Controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControl(
                    Iconsax.volume_high,
                    Colors.white24,
                    Colors.white,
                  ),
                  if (isVideo)
                    _buildControl(Iconsax.video, Colors.white24, Colors.white),
                  _buildControl(
                    Iconsax.microphone,
                    Colors.white24,
                    Colors.white,
                  ),
                  _buildControl(
                    Icons.call_end,
                    Colors.red,
                    Colors.white,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControl(
    IconData icon,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
