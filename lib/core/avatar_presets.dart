import 'package:flutter/material.dart';

class AvatarPreset {
  final String id;
  final String label;
  final String category;
  final String emoji;
  final List<Color> gradient;
  final Color borderColor;

  const AvatarPreset({
    required this.id,
    required this.label,
    required this.category,
    required this.emoji,
    required this.gradient,
    required this.borderColor,
  });
}

class AvatarPresets {
  AvatarPresets._();

  static const List<AvatarPreset> all = [
    // ── French Culture & Icons ────────────────────────
    AvatarPreset(
      id: 'french_beret',
      label: 'Parisian Artist',
      category: 'French',
      emoji: '🎨',
      gradient: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      borderColor: Color(0xFF818CF8),
    ),
    AvatarPreset(
      id: 'eiffel_explorer',
      label: 'Eiffel Explorer',
      category: 'French',
      emoji: '🗼',
      gradient: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      borderColor: Color(0xFF60A5FA),
    ),
    AvatarPreset(
      id: 'cafe_croissant',
      label: 'Café Connoisseur',
      category: 'French',
      emoji: '🥐',
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
      borderColor: Color(0xFFFBBF24),
    ),
    AvatarPreset(
      id: 'baguette_baker',
      label: 'Boulanger',
      category: 'French',
      emoji: '🥖',
      gradient: [Color(0xFFEA580C), Color(0xFFC2410C)],
      borderColor: Color(0xFFFB923C),
    ),
    AvatarPreset(
      id: 'provence_lavender',
      label: 'Provence Lavender',
      category: 'French',
      emoji: '🌸',
      gradient: [Color(0xFFA855F7), Color(0xFF7E22CE)],
      borderColor: Color(0xFFC084FC),
    ),
    AvatarPreset(
      id: 'bordeaux_grapes',
      label: 'Bordeaux Vintner',
      category: 'French',
      emoji: '🍇',
      gradient: [Color(0xFF831843), Color(0xFF500724)],
      borderColor: Color(0xFFBE185D),
    ),
    AvatarPreset(
      id: 'marseille_sailor',
      label: 'Marseille Sailor',
      category: 'French',
      emoji: '⛵',
      gradient: [Color(0xFF0284C7), Color(0xFF0369A1)],
      borderColor: Color(0xFF38BDF8),
    ),
    AvatarPreset(
      id: 'alps_skier',
      label: 'Alps Alpine',
      category: 'French',
      emoji: '⛷️',
      gradient: [Color(0xFF0D9488), Color(0xFF0F766E)],
      borderColor: Color(0xFF2DD4BF),
    ),

    // ── Learner Characters ────────────────────────────
    AvatarPreset(
      id: 'owl_polyglot',
      label: 'Polyglot Owl',
      category: 'Characters',
      emoji: '🦉',
      gradient: [Color(0xFF10B981), Color(0xFF047857)],
      borderColor: Color(0xFF34D399),
    ),
    AvatarPreset(
      id: 'fox_linguist',
      label: 'Clever Fox',
      category: 'Characters',
      emoji: '🦊',
      gradient: [Color(0xFFF97316), Color(0xFFEA580C)],
      borderColor: Color(0xFFFB923C),
    ),
    AvatarPreset(
      id: 'lion_scholar',
      label: 'Brave Scholar',
      category: 'Characters',
      emoji: '🦁',
      gradient: [Color(0xFFEAB308), Color(0xFFCA8A04)],
      borderColor: Color(0xFFFDE047),
    ),
    AvatarPreset(
      id: 'bear_learner',
      label: 'Gentle Bear',
      category: 'Characters',
      emoji: '🐻',
      gradient: [Color(0xFF78350F), Color(0xFF451A03)],
      borderColor: Color(0xFF92400E),
    ),
    AvatarPreset(
      id: 'cat_philosopher',
      label: 'Montmartre Cat',
      category: 'Characters',
      emoji: '🐱',
      gradient: [Color(0xFF64748B), Color(0xFF334155)],
      borderColor: Color(0xFF94A3B8),
    ),
    AvatarPreset(
      id: 'panda_student',
      label: 'Calm Panda',
      category: 'Characters',
      emoji: '🐼',
      gradient: [Color(0xFF1E293B), Color(0xFF0F172A)],
      borderColor: Color(0xFF475569),
    ),

    // ── Ambition & Passions ───────────────────────────
    AvatarPreset(
      id: 'cosmic_polyglot',
      label: 'Cosmic Explorer',
      category: 'Vibes',
      emoji: '🚀',
      gradient: [Color(0xFF4338CA), Color(0xFF1E1B4B)],
      borderColor: Color(0xFF6366F1),
    ),
    AvatarPreset(
      id: 'opera_virtuoso',
      label: 'Opera Virtuoso',
      category: 'Vibes',
      emoji: '🎭',
      gradient: [Color(0xFFBE123C), Color(0xFF881337)],
      borderColor: Color(0xFFFB7185),
    ),
    AvatarPreset(
      id: 'cinema_director',
      label: 'Cannes Cinephile',
      category: 'Vibes',
      emoji: '🎬',
      gradient: [Color(0xFF18181B), Color(0xFF09090B)],
      borderColor: Color(0xFF71717A),
    ),
    AvatarPreset(
      id: 'tour_cyclist',
      label: 'Tour Cyclist',
      category: 'Vibes',
      emoji: '🚴',
      gradient: [Color(0xFFE11D48), Color(0xFF9F1239)],
      borderColor: Color(0xFFFDA4AF),
    ),
    AvatarPreset(
      id: 'book_scholar',
      label: 'Sorbonne Scholar',
      category: 'Vibes',
      emoji: '📚',
      gradient: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
      borderColor: Color(0xFF3B82F6),
    ),
    AvatarPreset(
      id: 'star_achiever',
      label: 'Star Achiever',
      category: 'Vibes',
      emoji: '⭐',
      gradient: [Color(0xFFF59E0B), Color(0xFFB45309)],
      borderColor: Color(0xFFFCD34D),
    ),
    AvatarPreset(
      id: 'crown_champion',
      label: 'French Champion',
      category: 'Vibes',
      emoji: '👑',
      gradient: [Color(0xFFD97706), Color(0xFF92400E)],
      borderColor: Color(0xFFFBBF24),
    ),
    AvatarPreset(
      id: 'globe_trotter',
      label: 'Globe Trotter',
      category: 'Vibes',
      emoji: '🌍',
      gradient: [Color(0xFF059669), Color(0xFF047857)],
      borderColor: Color(0xFF10B981),
    ),
    AvatarPreset(
      id: 'coffee_lover',
      label: 'Café de Flore',
      category: 'French',
      emoji: '☕',
      gradient: [Color(0xFF7C2D12), Color(0xFF431407)],
      borderColor: Color(0xFF9A3412),
    ),
    AvatarPreset(
      id: 'spark_genius',
      label: 'Spark Genius',
      category: 'Vibes',
      emoji: '💡',
      gradient: [Color(0xFFCA8A04), Color(0xFF854D0E)],
      borderColor: Color(0xFFFACC15),
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
