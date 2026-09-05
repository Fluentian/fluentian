import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';
import '../models/culture_story_model.dart';
import '../providers/auth_provider.dart';
import '../services/content_api.dart';
import '../services/social_api.dart';
import '../services/tts_service.dart';
import '../widgets/translatable_text.dart';
import '../widgets/common_widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _storyController = PageController(
    viewportFraction: 0.92,
  );
  late Future<List<CultureStoryModel>> _storiesFuture;
  int _currentStory = 0;



  @override
  void initState() {
    super.initState();
    _storiesFuture = _loadStories();
  }

  Future<List<CultureStoryModel>> _loadStories() async {
    return ContentApi.instance.getCultureStories();
  }

  Future<void> _refreshStories() async {
    setState(() {
      _currentStory = 0;
      _storiesFuture = _loadStories();
    });
    await _storiesFuture;
  }

  Future<void> _openWord(
    String word,
    SentencePair sentence,
    String storyId,
  ) async {
    final cleaned = word.replaceAll(
      RegExp(r'^[^\p{L}]+|[^\p{L}\-’]+$', unicode: true),
      '',
    );
    if (cleaned.isEmpty) return;
    var saving = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FluentianColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: FluentianColors.headerGradient,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Icon(Iconsax.book_saved, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText(
                          cleaned,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.textPrimary,
                          ),
                        ),
                        LText(
                          'From this Explore story',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _WordContext(
                label: 'IN CONTEXT',
                text: sentence.original,
                icon: Iconsax.message_text,
              ),
              const SizedBox(height: 10),
              _WordContext(
                label: 'TRANSLATION',
                text: sentence.translated,
                icon: Iconsax.translate,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          setSheetState(() => saving = true);
                          try {
                            await SocialApi.instance.saveVocabulary(
                              word: cleaned,
                              storyId: storyId,
                              sourceSentence: sentence.original,
                              translatedSentence: sentence.translated,
                            );
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: LText(
                                  '$cleaned added to your word bank',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            if (sheetContext.mounted) {
                              setSheetState(() => saving = false);
                            }
                          }
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.add_circle),
                  label: const LText('Save to my word bank'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWordBank() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const _VocabularyScreen()),
  );

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: FluentianColors.headerGradient,
                borderRadius: BorderRadius.circular(0),
                boxShadow: [
                  FluentianShadows.subtle,
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Icon(
                      Iconsax.global,
                      color: FluentianColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText(
                          'Explore France',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        LText(
                          'Stories, sounds, and everyday culture',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.onInkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('My word bank'),
                    onPressed: _showWordBank,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .14),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Iconsax.book_saved),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CultureStoryModel>>(
                future: _storiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const FluentianShimmer(
                      child: SkeletonCultureStory(),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ExploreEmptyState(onRetry: _refreshStories);
                  }
                  final stories = snapshot.data ?? const <CultureStoryModel>[];
                  if (stories.isEmpty) {
                    return _ExploreEmptyState(onRetry: _refreshStories);
                  }

                  return RefreshIndicator(
                    color: FluentianColors.primary,
                    onRefresh: _refreshStories,
                    child: PageView.builder(
                      controller: _storyController,
                      itemCount: stories.length,
                      onPageChanged: (index) => setState(() {
                        _currentStory = index;
                      }),
                      itemBuilder: (context, index) {
                        return _CultureStoryView(
                          story: stories[index],
                          onWordTap: (word, sentence) =>
                              _openWord(word, sentence, stories[index].id),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            FutureBuilder<List<CultureStoryModel>>(
              future: _storiesFuture,
              builder: (context, snapshot) {
                final count =
                    (snapshot.data ?? const <CultureStoryModel>[]).length;
                if (count <= 1) return const SizedBox(height: 20);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                  child: _StoryIndicator(
                    count: count,
                    currentIndex: _currentStory.clamp(0, count - 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CultureStoryView extends StatelessWidget {
  final CultureStoryModel story;
  final void Function(String word, SentencePair sentence) onWordTap;

  const _CultureStoryView({required this.story, required this.onWordTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CultureMediaCarousel(media: story.media),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LText(
                        story.title,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MetaChip(icon: Iconsax.book, label: story.category),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Iconsax.location,
                      size: 16,
                      color: FluentianColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: LText(
                        story.location,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _TranslateHintCard(),
                const SizedBox(height: 14),
                ...story.paragraphs.map(
                  (paragraph) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TranslatableParagraph(
                      sentences: paragraph,
                      onWordTap: onWordTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslateHintCard extends StatelessWidget {
  const _TranslateHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: FluentianColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.translate,
            size: 18,
            color: FluentianColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LText(
              'Tap any sentence to reveal its translation. Long press a paragraph for the full translation.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: FluentianColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordContext extends StatelessWidget {
  final String label, text;
  final IconData icon;
  const _WordContext({
    required this.label,
    required this.text,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: FluentianColors.pageBg,
      borderRadius: BorderRadius.circular(0),
      border: Border.all(color: FluentianColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: FluentianColors.primary),
            const SizedBox(width: 7),
            LText(
              label,
              style: FluentianTheme.label(size: 10, color: FluentianColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LText(
          text,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: FluentianColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _VocabularyScreen extends StatefulWidget {
  const _VocabularyScreen();
  @override
  State<_VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<_VocabularyScreen> {
  late Future<List<VocabularyItem>> _items;
  @override
  void initState() {
    super.initState();
    _items = SocialApi.instance.getVocabulary();
  }

  void _reload() => setState(() => _items = SocialApi.instance.getVocabulary());

  Future<void> _speak(String text) async {
    try {
      final settingsUser = context.read<AuthProvider>().user;
      final speed = settingsUser?.ttsSpeed ?? 1.0;
      await TtsService.instance.speak(
        text,
        speed: speed,
        voiceId: settingsUser?.preferredVoiceId ?? 'claire',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LText(
            'Could not play pronunciation. Check the device speech settings.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openWord(VocabularyItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * .84,
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FluentianColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: FluentianColors.headerGradient,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LText(
                              'SAVED WORD',
                              style: FluentianTheme.label(size: 10, color: FluentianColors.onInkMuted),
                            ),
                            const SizedBox(height: 6),
                            LText(
                              item.word,
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white,
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (item.translation.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              LText(
                                item.translation,
                                style: GoogleFonts.ibmPlexSans(
                                  color: FluentianColors.onInkMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton.filled(
                        tooltip: context.tr('Hear pronunciation'),
                        onPressed: () => _speak(item.word),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: FluentianColors.primary,
                          minimumSize: const Size(50, 50),
                        ),
                        icon: const Icon(Iconsax.volume_high),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _WordContext(
                  label: 'FRENCH CONTEXT',
                  text: item.sourceSentence.isEmpty
                      ? item.word
                      : item.sourceSentence,
                  icon: Iconsax.message_text,
                ),
                if (item.translatedSentence.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _WordContext(
                    label: 'TRANSLATION',
                    text: item.translatedSentence,
                    icon: Iconsax.translate,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FluentianColors.primaryTint,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.lamp_on,
                        color: FluentianColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LText(
                          'Listen, then say the word and the full sentence aloud.',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await SocialApi.instance.deleteVocabulary(item.id);
                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          _reload();
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const LText('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _speak(
                          item.sourceSentence.isEmpty
                              ? item.word
                              : item.sourceSentence,
                        ),
                        icon: const Icon(Iconsax.volume_high),
                        label: const LText('Hear sentence'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: FluentianColors.pageBg,
    appBar: AppBar(
      title: const LText('My word bank'),
      backgroundColor: FluentianColors.pageBg,
      surfaceTintColor: Colors.transparent,
    ),
    body: FutureBuilder<List<VocabularyItem>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: FluentianColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.warning_2,
                      size: 36,
                      color: FluentianColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LText(
                    "Couldn't load your word bank",
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LText(
                    'Check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      height: 1.45,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Iconsax.refresh),
                    label: const LText('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: FluentianColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.book_saved,
                      size: 36,
                      color: FluentianColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LText(
                    'Your word bank is ready',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LText(
                    'Tap any word in an Explore story to save it with its real context.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      height: 1.45,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) async {
                await SocialApi.instance.deleteVocabulary(item.id);
                _reload();
              },
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
                child: InkWell(
                  onTap: () => _openWord(item),
                  borderRadius: BorderRadius.circular(0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: FluentianColors.primary.withValues(alpha: .13),
                      ),
                      boxShadow: [FluentianShadows.subtle],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: FluentianColors.primaryTint,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: LText(
                            item.word.characters.first.toUpperCase(),
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LText(
                                item.word,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LText(
                                item.sourceSentence,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: FluentianColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: FluentianColors.primaryTint,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: FluentianColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class _CultureMediaCarousel extends StatefulWidget {
  final List<CultureMediaModel> media;

  const _CultureMediaCarousel({required this.media});

  @override
  State<_CultureMediaCarousel> createState() => _CultureMediaCarouselState();
}

class _CultureMediaCarouselState extends State<_CultureMediaCarousel> {
  final PageController _mediaController = PageController();
  int _currentMedia = 0;

  void _goToMedia(int index) {
    if (widget.media.isEmpty) return;
    final target = index.clamp(0, widget.media.length - 1);
    _mediaController.animateToPage(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: FluentianColors.divider,
          borderRadius: BorderRadius.circular(0),
        ),
        child: const Center(
          child: Icon(
            Iconsax.gallery_slash,
            size: 42,
            color: FluentianColors.textSecondary,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _mediaController,
              physics: const PageScrollPhysics(),
              itemCount: widget.media.length,
              onPageChanged: (index) => setState(() {
                _currentMedia = index;
              }),
              itemBuilder: (context, index) {
                final item = widget.media[index];
                if (item.type == CultureMediaType.video) {
                  return _VideoMedia(url: item.url);
                }
                return Image.network(
                  item.url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: FluentianColors.divider,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: FluentianColors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: FluentianColors.divider,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: FluentianColors.textSecondary,
                          size: 42,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.media.length > 1) ...[
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: LText(
                    '${_currentMedia + 1}/${widget.media.length}',
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (_currentMedia > 0)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: _CarouselArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _goToMedia(_currentMedia - 1),
                  ),
                ),
              if (_currentMedia < widget.media.length - 1)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: _CarouselArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _goToMedia(_currentMedia + 1),
                  ),
                ),
            ],
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: LText(
                      widget.media[_currentMedia].caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        height: 1.25,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StoryIndicator(
                    count: widget.media.length,
                    currentIndex: _currentMedia,
                    activeColor: Colors.white,
                    inactiveColor: FluentianColors.onInkMuted,
                    onTap: _goToMedia,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoMedia extends StatefulWidget {
  final String url;

  const _VideoMedia({required this.url});

  @override
  State<_VideoMedia> createState() => _VideoMediaState();
}

class _VideoMediaState extends State<_VideoMedia> {
  late final VideoPlayerController _controller;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize()
          .then((_) {
            if (!mounted) return;
            _controller
              ..setLooping(true)
              ..setVolume(0)
              ..play();
            setState(() => _isReady = true);
          })
          .catchError((_) {
            if (mounted) setState(() => _hasError = true);
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: FluentianColors.darkCard,
        child: const Center(
          child: Icon(Iconsax.video_slash, color: FluentianColors.onInkMuted, size: 44),
        ),
      );
    }

    if (!_isReady) {
      return Container(
        color: FluentianColors.darkCard,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            Container(
              color: Colors.black.withValues(alpha: 0.22),
              child: const Center(
                child: Icon(Iconsax.play_circle, color: Colors.white, size: 58),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExploreEmptyState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ExploreEmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.gallery_slash,
              size: 42,
              color: FluentianColors.textSecondary,
            ),
            const SizedBox(height: 12),
            LText(
              'No culture stories yet',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            LText(
              'Published stories from the backend will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                height: 1.45,
                color: FluentianColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const LText('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FluentianColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: LText(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: FluentianColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int>? onTap;

  const _StoryIndicator({
    required this.count,
    required this.currentIndex,
    this.activeColor = FluentianColors.primary,
    this.inactiveColor = FluentianColors.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = index == currentIndex;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap == null ? null : () => onTap!(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: selected ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
    child: Material(
      color: Colors.black.withValues(alpha: 0.48),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    ),
  );
}
