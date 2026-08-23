import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../core/app_localization.dart';
import '../core/avatar_presets.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import 'user_avatar.dart';

class AvatarPickerSheet extends StatefulWidget {
  final String? currentAvatarUrl;
  final ValueChanged<String>? onSelected;

  const AvatarPickerSheet({
    super.key,
    this.currentAvatarUrl,
    this.onSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    String? currentAvatarUrl,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(currentAvatarUrl: currentAvatarUrl),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  late String _selectedId;
  String _selectedCategory = 'All';
  bool _saving = false;

  final _categories = ['All', 'French', 'Characters', 'Vibes'];

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentAvatarUrl ?? AvatarPresets.all.first.id;
  }

  List<AvatarPreset> get _filteredPresets {
    if (_selectedCategory == 'All') return AvatarPresets.all;
    return AvatarPresets.all
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile({'avatar_url': _selectedId});
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      widget.onSelected?.call(_selectedId);
      Navigator.of(context).pop(_selectedId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? context.tr('Could not update avatar.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final selectedPreset = AvatarPresets.getPreset(_selectedId) ??
        AvatarPresets.all.first;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FluentianColors.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Iconsax.profile_circle,
                  color: FluentianColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      'Choose Your Avatar',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    LText(
                      'Pick a signature look for your profile & leaderboard',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Selected preview card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  selectedPreset.gradient.first.withValues(alpha: 0.12),
                  selectedPreset.gradient.last.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selectedPreset.borderColor.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                UserAvatar(
                  avatarUrl: selectedPreset.id,
                  name: user?.displayName ?? 'Learner',
                  size: 58,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LText(
                        selectedPreset.label,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      LText(
                        'Category: ${selectedPreset.category}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: FluentianColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: FluentianColors.successTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: FluentianColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      LText(
                        'Active',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: FluentianColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = category);
                    },
                    selectedColor: FluentianColors.primary,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : FluentianColors.textSecondary,
                    ),
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? FluentianColors.primary : Colors.transparent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Grid of avatars
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _filteredPresets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final preset = _filteredPresets[index];
                final isSelected = _selectedId == preset.id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedId = preset.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? FluentianColors.primaryTint
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? FluentianColors.primary
                            : Colors.grey.shade200,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UserAvatar(
                          avatarUrl: preset.id,
                          name: preset.label,
                          size: 44,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preset.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? FluentianColors.primary
                                : FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: FluentianColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Avatar',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
