import '../widgets/translatable_text.dart';

enum CultureMediaType { image, video }

class CultureMediaModel {
  final CultureMediaType type;
  final String url;
  final String caption;

  const CultureMediaModel({
    required this.type,
    required this.url,
    required this.caption,
  });

  factory CultureMediaModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().toLowerCase();
    return CultureMediaModel(
      type: rawType == 'video'
          ? CultureMediaType.video
          : CultureMediaType.image,
      url: json['url']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
    );
  }
}

class CultureStoryModel {
  final String id;
  final String title;
  final String location;
  final String category;
  final int sequenceNo;
  final bool isPublished;
  final List<CultureMediaModel> media;
  final List<List<SentencePair>> paragraphs;

  const CultureStoryModel({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.sequenceNo,
    required this.isPublished,
    required this.media,
    required this.paragraphs,
  });

  factory CultureStoryModel.fromJson(Map<String, dynamic> json) {
    final mediaJson = json['media'];
    final paragraphsJson = json['paragraphs'];

    return CultureStoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      sequenceNo: json['sequence_no'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
      media: mediaJson is List
          ? mediaJson
                .whereType<Map<String, dynamic>>()
                .map(CultureMediaModel.fromJson)
                .where((item) => item.url.trim().isNotEmpty)
                .toList()
          : const [],
      paragraphs: paragraphsJson is List
          ? paragraphsJson
                .whereType<List>()
                .map(
                  (paragraph) => paragraph
                      .whereType<Map<String, dynamic>>()
                      .map(
                        (sentence) => SentencePair(
                          original: sentence['original']?.toString() ?? '',
                          translated: sentence['translated']?.toString() ?? '',
                        ),
                      )
                      .where((pair) => pair.original.trim().isNotEmpty)
                      .toList(),
                )
                .where((paragraph) => paragraph.isNotEmpty)
                .toList()
          : const [],
    );
  }
}
