import 'package:flutter/material.dart';

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
      gradient: [Color(0xFFFFD5DC), Color(0xFFF472B6)],
      borderColor: Color(0xFFF472B6),
    ),
    AvatarPreset(
      id: 'lucas',
      label: 'Lucas',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_lucas.png',
      gradient: [Color(0xFFB6E3F4), Color(0xFF38BDF8)],
      borderColor: Color(0xFF38BDF8),
    ),
    AvatarPreset(
      id: 'chloe',
      label: 'Chloé',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_chloe.png',
      gradient: [Color(0xFFC0AEDE), Color(0xFFA855F7)],
      borderColor: Color(0xFFA855F7),
    ),
    AvatarPreset(
      id: 'antoine',
      label: 'Antoine',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_antoine.png',
      gradient: [Color(0xFFFFDFBF), Color(0xFFF97316)],
      borderColor: Color(0xFFF97316),
    ),
    AvatarPreset(
      id: 'camille',
      label: 'Camille',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_camille.png',
      gradient: [Color(0xFFD1D4F9), Color(0xFF6366F1)],
      borderColor: Color(0xFF6366F1),
    ),
    AvatarPreset(
      id: 'gabriel',
      label: 'Gabriel',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_gabriel.png',
      gradient: [Color(0xFFB6E3F4), Color(0xFF0284C7)],
      borderColor: Color(0xFF0284C7),
    ),
    AvatarPreset(
      id: 'julie',
      label: 'Julie',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_julie.png',
      gradient: [Color(0xFFFFD5DC), Color(0xFFEC4899)],
      borderColor: Color(0xFFEC4899),
    ),
    AvatarPreset(
      id: 'louis',
      label: 'Louis',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_louis.png',
      gradient: [Color(0xFFFFDFBF), Color(0xFFEA580C)],
      borderColor: Color(0xFFEA580C),
    ),
    AvatarPreset(
      id: 'manon',
      label: 'Manon',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_manon.png',
      gradient: [Color(0xFFC0AEDE), Color(0xFF9333EA)],
      borderColor: Color(0xFF9333EA),
    ),
    AvatarPreset(
      id: 'hugo',
      label: 'Hugo',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_hugo.png',
      gradient: [Color(0xFFD1D4F9), Color(0xFF4F46E5)],
      borderColor: Color(0xFF4F46E5),
    ),
    AvatarPreset(
      id: 'lea',
      label: 'Léa',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_lea.png',
      gradient: [Color(0xFFFFD5DC), Color(0xFFDB2777)],
      borderColor: Color(0xFFDB2777),
    ),
    AvatarPreset(
      id: 'noah',
      label: 'Noah',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_noah.png',
      gradient: [Color(0xFFB6E3F4), Color(0xFF0EA5E9)],
      borderColor: Color(0xFF0EA5E9),
    ),
    AvatarPreset(
      id: 'sophie',
      label: 'Sophie',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_sophie.png',
      gradient: [Color(0xFFFFD5DC), Color(0xFFF43F5E)],
      borderColor: Color(0xFFF43F5E),
    ),
    AvatarPreset(
      id: 'pierre',
      label: 'Pierre',
      category: 'Scholars',
      imageAsset: 'assets/avatars/avatar_pierre.png',
      gradient: [Color(0xFFD1D4F9), Color(0xFF3B82F6)],
      borderColor: Color(0xFF3B82F6),
    ),
    AvatarPreset(
      id: 'emma',
      label: 'Emma',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_emma.png',
      gradient: [Color(0xFFC0AEDE), Color(0xFF7C3AED)],
      borderColor: Color(0xFF7C3AED),
    ),
    AvatarPreset(
      id: 'maxime',
      label: 'Maxime',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_maxime.png',
      gradient: [Color(0xFFFFDFBF), Color(0xFFD97706)],
      borderColor: Color(0xFFD97706),
    ),
    AvatarPreset(
      id: 'leo',
      label: 'Léo',
      category: 'Adventurers',
      imageAsset: 'assets/avatars/avatar_leo.png',
      gradient: [Color(0xFFB6E3F4), Color(0xFF06B6D4)],
      borderColor: Color(0xFF06B6D4),
    ),
    AvatarPreset(
      id: 'sarah',
      label: 'Sarah',
      category: 'French Learners',
      imageAsset: 'assets/avatars/avatar_sarah.png',
      gradient: [Color(0xFFFFD5DC), Color(0xFFE11D48)],
      borderColor: Color(0xFFE11D48),
    ),
    AvatarPreset(
      id: 'theo',
      label: 'Théo',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_theo.png',
      gradient: [Color(0xFFD1D4F9), Color(0xFF2563EB)],
      borderColor: Color(0xFF2563EB),
    ),
    AvatarPreset(
      id: 'zoe',
      label: 'Zoé',
      category: 'Creative',
      imageAsset: 'assets/avatars/avatar_zoe.png',
      gradient: [Color(0xFFC0AEDE), Color(0xFF8B5CF6)],
      borderColor: Color(0xFF8B5CF6),
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
