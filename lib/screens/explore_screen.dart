import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';
import '../core/theme.dart';
import '../models/culture_story_model.dart';
import '../services/content_api.dart';
import '../widgets/translatable_text.dart';

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

  static final List<CultureStoryModel> _fallbackStories = [
    const CultureStoryModel(
      id: 'fallback-cafe',
      title: 'La vie au café',
      location: 'Paris, France',
      category: 'Daily culture',
      sequenceNo: 1,
      isPublished: true,
      media: [
        CultureMediaModel(
          type: CultureMediaType.image,
          url:
              'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&q=80&w=1200',
          caption: 'Une terrasse parisienne',
        ),
        CultureMediaModel(
          type: CultureMediaType.image,
          url:
              'https://images.unsplash.com/photo-1522093007474-d86e9bf7ba6f?auto=format&fit=crop&q=80&w=1200',
          caption: 'Un moment de discussion',
        ),
      ],
      paragraphs: [
        [
          SentencePair(
            original:
                'Les cafés parisiens sont au cœur de la vie sociale en France.',
            translated:
                'Parisian cafes are at the heart of social life in France.',
          ),
          SentencePair(
            original:
                'On s’y assoit en terrasse pour regarder les passants, boire un expresso et discuter pendant des heures.',
            translated:
                'People sit on the terrace to watch passers-by, drink an espresso, and talk for hours.',
          ),
        ],
        [
          SentencePair(
            original:
                'Historiquement, les cafés étaient des lieux de rencontre pour les artistes, les écrivains et les philosophes.',
            translated:
                'Historically, cafes were meeting places for artists, writers, and philosophers.',
          ),
          SentencePair(
            original:
                'Aujourd’hui encore, commander un café peut être une petite pause, mais aussi un rituel quotidien.',
            translated:
                'Even today, ordering a coffee can be a short break, but also a daily ritual.',
          ),
        ],
      ],
    ),
    const CultureStoryModel(
      id: 'fallback-music',
      title: 'La Fête de la Musique',
      location: 'Toute la France',
      category: 'Festival',
      sequenceNo: 2,
      isPublished: true,
      media: [
        CultureMediaModel(
          type: CultureMediaType.image,
          url:
              'https://images.unsplash.com/photo-1508973379184-7517410fb0bc?auto=format&fit=crop&q=80&w=1200',
          caption: 'Un concert en plein air',
        ),
        CultureMediaModel(
          type: CultureMediaType.video,
          url:
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          caption: 'Vidéo culturelle',
        ),
      ],
      paragraphs: [
        [
          SentencePair(
            original:
                'La Fête de la Musique a lieu chaque année le 21 juin, le jour du solstice d’été.',
            translated:
                'The Music Festival takes place every year on June 21, the day of the summer solstice.',
          ),
          SentencePair(
            original:
                'Des musiciens amateurs et professionnels jouent dans les rues, les parcs, les cafés et les places publiques.',
            translated:
                'Amateur and professional musicians play in streets, parks, cafes, and public squares.',
          ),
        ],
        [
          SentencePair(
            original:
                'L’idée principale est simple : la musique doit être accessible à tout le monde.',
            translated:
                'The main idea is simple: music should be accessible to everyone.',
          ),
          SentencePair(
            original:
                'Dans beaucoup de villes, les habitants se promènent d’un concert à l’autre jusqu’à tard le soir.',
            translated:
                'In many cities, residents walk from one concert to another until late at night.',
          ),
        ],
      ],
    ),
    const CultureStoryModel(
      id: 'fallback-market',
      title: 'Les marchés de Provence',
      location: 'Provence, France',
      category: 'Food and place',
      sequenceNo: 3,
      isPublished: true,
      media: [
        CultureMediaModel(
          type: CultureMediaType.image,
          url:
              'https://images.unsplash.com/photo-1471194402529-8e0f5a675de6?auto=format&fit=crop&q=80&w=1200',
          caption: 'Un marché du matin',
        ),
        CultureMediaModel(
          type: CultureMediaType.image,
          url:
              'https://images.unsplash.com/photo-1509474520651-53cf6a80536f?auto=format&fit=crop&q=80&w=1200',
          caption: 'Produits locaux',
        ),
      ],
      paragraphs: [
        [
          SentencePair(
            original:
                'En Provence, le marché est souvent un rendez-vous de la semaine.',
            translated:
                'In Provence, the market is often a weekly meeting point.',
          ),
          SentencePair(
            original:
                'On y achète des olives, du fromage, des fruits, des herbes et parfois de la lavande.',
            translated:
                'People buy olives, cheese, fruit, herbs, and sometimes lavender there.',
          ),
        ],
        [
          SentencePair(
            original:
                'Les vendeurs aiment expliquer l’origine de leurs produits et proposer une dégustation.',
            translated:
                'Vendors like to explain where their products come from and offer a tasting.',
          ),
          SentencePair(
            original:
                'Pour beaucoup de visiteurs, c’est une façon naturelle de découvrir les accents, les saveurs et les habitudes locales.',
            translated:
                'For many visitors, it is a natural way to discover local accents, flavors, and habits.',
          ),
        ],
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _storiesFuture = _loadStories();
  }

  Future<List<CultureStoryModel>> _loadStories() async {
    try {
      final stories = await ContentApi.instance.getCultureStories();
      if (stories.isNotEmpty) return stories;
    } catch (_) {
      // Keep Explore usable while a deployed backend is still catching up.
    }
    return _fallbackStories;
  }

  Future<void> _refreshStories() async {
    setState(() {
      _currentStory = 0;
      _storiesFuture = _loadStories();
    });
    await _storiesFuture;
  }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: FluentianColors.primaryTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.global,
                      color: FluentianColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: FluentianColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Culture française',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CultureStoryModel>>(
                future: _storiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: FluentianColors.primary,
                      ),
                    );
                  }

                  final stories = snapshot.data ?? _fallbackStories;
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
                        return _CultureStoryView(story: stories[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            FutureBuilder<List<CultureStoryModel>>(
              future: _storiesFuture,
              builder: (context, snapshot) {
                final count = (snapshot.data ?? _fallbackStories).length;
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

  const _CultureStoryView({required this.story});

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
                      child: Text(
                        story.title,
                        style: GoogleFonts.inter(
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
                      child: Text(
                        story.location,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
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
                    child: TranslatableParagraph(sentences: paragraph),
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
        borderRadius: BorderRadius.circular(14),
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
            child: Text(
              'Tap any sentence to reveal its translation. Long press a paragraph for the full translation.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
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

class _CultureMediaCarousel extends StatefulWidget {
  final List<CultureMediaModel> media;

  const _CultureMediaCarousel({required this.media});

  @override
  State<_CultureMediaCarousel> createState() => _CultureMediaCarouselState();
}

class _CultureMediaCarouselState extends State<_CultureMediaCarousel> {
  final PageController _mediaController = PageController();
  int _currentMedia = 0;

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _mediaController,
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
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      widget.media[_currentMedia].caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
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
                    inactiveColor: Colors.white54,
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
          child: Icon(Iconsax.video_slash, color: Colors.white70, size: 44),
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
            Text(
              'No culture stories yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Published stories from the backend will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.45,
                color: FluentianColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Refresh'),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FluentianColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
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

  const _StoryIndicator({
    required this.count,
    required this.currentIndex,
    this.activeColor = FluentianColors.primary,
    this.inactiveColor = FluentianColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: selected ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: selected ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
