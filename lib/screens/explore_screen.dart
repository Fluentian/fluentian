import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';
import '../core/theme.dart';
import '../widgets/translatable_text.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Mock data for culture exploration
  final List<Map<String, dynamic>> _cultureItems = [
    {
      'type': 'image',
      'url': 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&q=80&w=1000',
      'title': 'Parisian Café Culture',
      'location': 'Paris, France',
      'paragraphs': [
        [
          SentencePair(
            original: "Les cafés parisiens sont le cœur de la vie sociale en France.",
            translated: "Parisian cafés are the heart of social life in France.",
          ),
          SentencePair(
            original: "On s'y assoit en terrasse pour regarder les passants, boire un expresso et discuter pendant des heures.",
            translated: "People sit on the terrace to watch passers-by, drink an espresso and chat for hours.",
          ),
        ],
        [
          SentencePair(
            original: "Historiquement, c'était le lieu de rencontre des artistes, des écrivains et des philosophes.",
            translated: "Historically, it was the meeting place for artists, writers, and philosophers.",
          ),
        ]
      ],
    },
    {
      'type': 'image',
      'url': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&q=80&w=1000',
      'title': 'La Fête de la Musique',
      'location': 'Throughout France',
      'paragraphs': [
        [
          SentencePair(
            original: "La Fête de la Musique a lieu chaque année le 21 juin.",
            translated: "The Music Festival takes place every year on June 21st.",
          ),
          SentencePair(
            original: "Des musiciens amateurs et professionnels jouent dans les rues, les parcs et les places de la ville.",
            translated: "Amateur and professional musicians play in the streets, parks, and city squares.",
          ),
        ],
        [
          SentencePair(
            original: "C'est une célébration vibrante qui marque le début de l'été.",
            translated: "It's a vibrant celebration that marks the beginning of summer.",
          ),
        ]
      ],
    },
    {
      'type': 'video',
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'title': 'La Provence et ses Champs de Lavande',
      'location': 'Provence, France',
      'paragraphs': [
        [
          SentencePair(
            original: "En été, les champs de la Provence se couvrent de fleurs violettes.",
            translated: "In summer, the fields of Provence are covered in purple flowers.",
          ),
          SentencePair(
            original: "La lavande est récoltée pour fabriquer des parfums, des savons et des huiles essentielles.",
            translated: "Lavender is harvested to make perfumes, soaps, and essential oils.",
          ),
        ],
      ],
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.explore_rounded, color: FluentianColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Explore Culture',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Interactive Gallery
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _cultureItems.length,
                itemBuilder: (context, index) {
                  final item = _cultureItems[index];
                  return _CultureCard(item: item);
                },
              ),
            ),
            
            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _cultureItems.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? FluentianColors.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CultureCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CultureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final List<List<SentencePair>> paragraphs = item['paragraphs'] as List<List<SentencePair>>;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Media Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item['type'] == 'image')
                      Image.network(
                        item['url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                        ),
                      )
                    else if (item['type'] == 'video')
                      _VideoPlayerWidget(url: item['url']),
                      
                    // Gradient Overlay for text visibility
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Location Tag
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            item['location'],
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FluentianColors.accentTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: FluentianColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Tap any sentence to translate',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: FluentianColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Translatable Paragraphs
                ...paragraphs.map((sentences) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TranslatableParagraph(sentences: sentences),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;

  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(color: FluentianColors.primary),
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
        alignment: Alignment.center,
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
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              ),
            ),
        ],
      ),
    );
  }
}
