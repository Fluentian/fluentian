import 'package:flutter/material.dart';

import 'theme.dart';

/// A chooseable avatar: a character illustration on a ground.
///
/// The 20 presets used to carry 20 two-stop gradients in tailwind hues --
/// rose, sky, violet, orange, indigo, cyan, fuchsia -- no two related and
/// none of them from this app's palette. A rainbow of arbitrary gradients is
/// the fastest way for a screen to look generated, and the ground was never
/// what told two learners apart anyway: the illustration is.
///
/// The grounds now rotate through the system's five tints, flat, each with
/// its own ink border. `gradient` keeps its name and its two stops so the
/// avatar widgets did not have to change; both stops are the same colour.
class AvatarPreset {
  final String id;
  final String label;
  final String category;
  final String imageAsset;
  final List<Color> gradient;
  final Color borderColor;

  const AvatarPreset({
    required this.id,
    required this.label,
    required this.category,
    required this.imageAsset,
    required this.gradient,
    required this.borderColor,
  });
}

class AvatarPresets {
  AvatarPresets._();

  static const List<AvatarPreset> all = [
    // ── French Learners & Characters (20) ─────────────
    AvatarPreset(
      id: 'amelie',
      label: 'Amélie',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_amelie.png',
      gradient: [FluentianColors.primaryTint, FluentianColors.primaryTint],
      borderColor: FluentianColors.primary,
    ),
    AvatarPreset(
      id: 'lucas',
      label: 'Lucas',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_lucas.png',
      gradient: [FluentianColors.secondaryTint, FluentianColors.secondaryTint],
      borderColor: FluentianColors.secondary,
    ),
    AvatarPreset(
      id: 'chloe',
      label: 'Chloé',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_chloe.png',
      gradient: [FluentianColors.accentTint, FluentianColors.accentTint],
      borderColor: FluentianColors.accent,
    ),
    AvatarPreset(
      id: 'antoine',
      label: 'Antoine',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_antoine.png',
      gradient: [FluentianColors.warningTint, FluentianColors.warningTint],
      borderColor: FluentianColors.warning,
    ),
    AvatarPreset(
      id: 'camille',
      label: 'Camille',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_camille.png',
      gradient: [FluentianColors.errorTint, FluentianColors.errorTint],
      borderColor: FluentianColors.error,
    ),
    AvatarPreset(
      id: 'gabriel',
      label: 'Gabriel',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_gabriel.png',
      gradient: [FluentianColors.primaryTint, FluentianColors.primaryTint],
      borderColor: FluentianColors.primary,
    ),
    AvatarPreset(
      id: 'julie',
      label: 'Julie',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_julie.png',
      gradient: [FluentianColors.secondaryTint, FluentianColors.secondaryTint],
      borderColor: FluentianColors.secondary,
    ),
    AvatarPreset(
      id: 'louis',
      label: 'Louis',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_louis.png',
      gradient: [FluentianColors.accentTint, FluentianColors.accentTint],
      borderColor: FluentianColors.accent,
    ),
    AvatarPreset(
      id: 'manon',
      label: 'Manon',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_manon.png',
      gradient: [FluentianColors.warningTint, FluentianColors.warningTint],
      borderColor: FluentianColors.warning,
    ),
    AvatarPreset(
      id: 'hugo',
      label: 'Hugo',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_hugo.png',
      gradient: [FluentianColors.errorTint, FluentianColors.errorTint],
      borderColor: FluentianColors.error,
    ),
    AvatarPreset(
      id: 'lea',
      label: 'Léa',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_lea.png',
      gradient: [FluentianColors.primaryTint, FluentianColors.primaryTint],
      borderColor: FluentianColors.primary,
    ),
    AvatarPreset(
      id: 'noah',
      label: 'Noah',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_noah.png',
      gradient: [FluentianColors.secondaryTint, FluentianColors.secondaryTint],
      borderColor: FluentianColors.secondary,
    ),
    AvatarPreset(
      id: 'sophie',
      label: 'Sophie',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_sophie.png',
      gradient: [FluentianColors.accentTint, FluentianColors.accentTint],
      borderColor: FluentianColors.accent,
    ),
    AvatarPreset(
      id: 'pierre',
      label: 'Pierre',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_pierre.png',
      gradient: [FluentianColors.warningTint, FluentianColors.warningTint],
      borderColor: FluentianColors.warning,
    ),
    AvatarPreset(
      id: 'emma',
      label: 'Emma',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_emma.png',
      gradient: [FluentianColors.errorTint, FluentianColors.errorTint],
      borderColor: FluentianColors.error,
    ),
    AvatarPreset(
      id: 'maxime',
      label: 'Maxime',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_maxime.png',
      gradient: [FluentianColors.primaryTint, FluentianColors.primaryTint],
      borderColor: FluentianColors.primary,
    ),
    AvatarPreset(
      id: 'leo',
      label: 'Léo',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_leo.png',
      gradient: [FluentianColors.secondaryTint, FluentianColors.secondaryTint],
      borderColor: FluentianColors.secondary,
    ),
    AvatarPreset(
      id: 'sarah',
      label: 'Sarah',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_sarah.png',
      gradient: [FluentianColors.accentTint, FluentianColors.accentTint],
      borderColor: FluentianColors.accent,
    ),
    AvatarPreset(
      id: 'theo',
      label: 'Théo',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_theo.png',
      gradient: [FluentianColors.warningTint, FluentianColors.warningTint],
      borderColor: FluentianColors.warning,
    ),
    AvatarPreset(
      id: 'zoe',
      label: 'Zoé',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_zoe.png',
      gradient: [FluentianColors.errorTint, FluentianColors.errorTint],
      borderColor: FluentianColors.error,
    ),
  ];

  static AvatarPreset? getPreset(String? id) {
    if (id == null || id.isEmpty) return null;
    final clean = id.startsWith('preset:')
        ? id.substring(7)
        : id.startsWith('avatar:')
        ? id.substring(7)
        : id;
    try {
      return all.firstWhere((p) => p.id == clean);
    } catch (_) {
      return null;
    }
  }

  static AvatarPreset getDeterministic(String seed) {
    if (seed.isEmpty) return all.first;
    final index = seed.hashCode.abs() % all.length;
    return all[index];
  }
}
