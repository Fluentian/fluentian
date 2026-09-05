import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/avatar_presets.dart';
import '../core/theme.dart';
import '../services/api_client.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final bool isOnline;
  final bool showOnlineIndicator;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 48,
    this.onTap,
    this.showEditBadge = false,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = avatarUrl?.trim();
    final preset = AvatarPresets.getPreset(cleanUrl);
    final resolvedBorderColor =
        borderColor ?? preset?.borderColor ?? Colors.white.withValues(alpha: 0.25);

    Widget avatarContent;

    if (preset != null) {
      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: resolvedBorderColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: preset.gradient.last.withValues(alpha: 0.25),
              blurRadius: size * 0.2,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            preset.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackInitial(),
          ),
        ),
      );
    } else if (cleanUrl != null &&
        (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://'))) {
      final mediaUrl = ApiClient.resolveMediaUrl(cleanUrl);
      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: resolvedBorderColor,
            width: borderWidth,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            mediaUrl ?? cleanUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackInitial(),
          ),
        ),
      );
    } else {
      // Deterministic gradient initial avatar
      avatarContent = _buildFallbackInitial();
    }

    if (showEditBadge || showOnlineIndicator) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          if (showEditBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  color: FluentianColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: size * 0.2,
                ),
              ),
            ),
          if (showOnlineIndicator)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: isOnline
                      ? FluentianColors.success
                      : FluentianColors.border,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildFallbackInitial() {
    final deterministic = AvatarPresets.getDeterministic(name);
    final initial = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'U';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: deterministic.gradient,
        ),
        border: Border.all(
          color: borderColor ?? deterministic.borderColor,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.ibmPlexSans(
            fontSize: size * 0.44,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
