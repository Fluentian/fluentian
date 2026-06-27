/// Course / Unit / Lesson / Block / Question models.
/// Payload fields accept Admin, seed, and import aliases via getters below.
library;

import '../services/api_client.dart';

class CourseModel {
  final String id;
  final String targetLanguageId;
  final String code;
  final String levelMin;
  final String levelMax;
  final bool isPublished;
  final DateTime createdAt;
  final List<UnitModel> units;

  const CourseModel({
    required this.id,
    required this.targetLanguageId,
    required this.code,
    required this.levelMin,
    required this.levelMax,
    required this.isPublished,
    required this.createdAt,
    required this.units,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json['id'] as String,
    targetLanguageId: json['target_language_id'] as String,
    code: json['code'] as String,
    levelMin: json['level_min'] as String,
    levelMax: json['level_max'] as String,
    isPublished: json['is_published'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
    units: (json['units'] as List<dynamic>? ?? [])
        .map((u) => UnitModel.fromJson(u as Map<String, dynamic>))
        .toList(),
  );
}

class UnitModel {
  final String id;
  final String courseId;
  final String unitKind;
  final int unitNo;
  final String title;
  final DateTime createdAt;
  final List<LessonModel> lessons;

  const UnitModel({
    required this.id,
    required this.courseId,
    required this.unitKind,
    required this.unitNo,
    required this.title,
    required this.createdAt,
    required this.lessons,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
    id: json['id'] as String,
    courseId: json['course_id'] as String,
    unitKind: json['unit_kind'] as String? ?? 'core',
    unitNo: json['unit_no'] as int,
    title: json['title'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    lessons: (json['lessons'] as List<dynamic>? ?? [])
        .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
        .toList(),
  );
}

class LessonModel {
  final String id;
  final String courseId;
  final String unitId;
  // dialogue, grammar, vocabulary, speaking, quiz, review
  final String lessonKind;
  final int sequenceNo;
  final String title;
  final int estimatedMinutes;
  final int xpReward;
  final bool isPublished;

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.unitId,
    required this.lessonKind,
    required this.sequenceNo,
    required this.title,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.isPublished,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
    id: json['id'] as String,
    courseId: json['course_id'] as String,
    unitId: json['unit_id'] as String,
    lessonKind: json['lesson_kind'] as String? ?? 'vocabulary',
    sequenceNo: json['sequence_no'] as int,
    title: json['title'] as String,
    estimatedMinutes: json['estimated_minutes'] as int? ?? 5,
    xpReward: json['xp_reward'] as int? ?? 10,
    isPublished: json['is_published'] as bool? ?? false,
  );
}

class LessonDetailModel extends LessonModel {
  final List<BlockModel> blocks;
  final List<QuestionModel> questions;

  const LessonDetailModel({
    required super.id,
    required super.courseId,
    required super.unitId,
    required super.lessonKind,
    required super.sequenceNo,
    required super.title,
    required super.estimatedMinutes,
    required super.xpReward,
    required super.isPublished,
    required this.blocks,
    required this.questions,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      unitId: json['unit_id'] as String,
      lessonKind: json['lesson_kind'] as String? ?? 'vocabulary',
      sequenceNo: json['sequence_no'] as int,
      title: json['title'] as String,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 5,
      xpReward: json['xp_reward'] as int? ?? 10,
      isPublished: json['is_published'] as bool? ?? false,
      blocks: (json['blocks'] as List<dynamic>? ?? [])
          .map((b) => BlockModel.fromJson(b as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BlockModel {
  final String id;
  final String lessonId;
  // explanation, vocabulary, example, audio, image, dialogue
  final String blockKind;
  final int sequenceNo;
  final Map<String, dynamic> blockPayload;
  final DateTime createdAt;

  const BlockModel({
    required this.id,
    required this.lessonId,
    required this.blockKind,
    required this.sequenceNo,
    required this.blockPayload,
    required this.createdAt,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) => BlockModel(
    id: json['id'] as String,
    lessonId: json['lesson_id'] as String,
    blockKind: json['block_kind'] as String,
    sequenceNo: json['sequence_no'] as int,
    blockPayload: Map<String, dynamic>.from(
      json['block_payload'] as Map? ?? {},
    ),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  /// For audio content blocks.
  String? get audioUrl =>
      ApiClient.resolveMediaUrl(blockPayload['audio_url']?.toString());

  bool get ttsEnabled {
    final value = blockPayload['tts_enabled'];
    return value == true || value?.toString().toLowerCase() == 'true';
  }

  String get ttsLanguage =>
      blockPayload['tts_language']?.toString().trim().isNotEmpty == true
      ? blockPayload['tts_language'].toString()
      : 'fr-FR';

  String get textToSpeak {
    final explicit = _firstString(blockPayload, [
      'tts_text',
      'audio_text',
      'speak_text',
    ]);
    if (explicit.isNotEmpty) return explicit;

    final frenchText = _firstString(blockPayload, [
      'target',
      'fr',
      'word',
      'phrase',
      'sentence',
      'example_fr',
    ]);
    if (frenchText.isNotEmpty) return frenchText;

    final examples = blockPayload['examples'];
    if (examples is List && examples.isNotEmpty) {
      final first = examples.first;
      if (first is Map) {
        return first['fr']?.toString().trim() ?? '';
      }
    }

    return '';
  }
}

class QuestionModel {
  final String id;
  final String lessonId;
  final String questionKind; // mcq, fill_blank, matching, true_false
  final int sequenceNo;
  final int difficulty;
  final Map<String, dynamic> promptPayload;
  final Map<String, dynamic> gradingPayload;
  final DateTime createdAt;

  const QuestionModel({
    required this.id,
    required this.lessonId,
    required this.questionKind,
    required this.sequenceNo,
    required this.difficulty,
    required this.promptPayload,
    required this.gradingPayload,
    required this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: json['id'] as String,
    lessonId: json['lesson_id'] as String,
    questionKind: json['question_kind'] as String,
    sequenceNo: json['sequence_no'] as int,
    difficulty: json['difficulty'] as int? ?? 1,
    promptPayload: Map<String, dynamic>.from(
      json['prompt_payload'] as Map? ?? {},
    ),
    gradingPayload: Map<String, dynamic>.from(
      json['grading_payload'] as Map? ?? {},
    ),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  bool get isMcq => questionKind == 'mcq_single' || questionKind == 'mcq_multi';

  bool get isOpenAnswer =>
      questionKind == 'fill_blank' ||
      questionKind == 'translation' ||
      questionKind == 'short_text' ||
      questionKind == 'dictation' ||
      questionKind == 'listening_comprehension';

  /// For MCQ questions — options from canonical or legacy keys.
  List<String> get mcqOptions {
    final opts =
        promptPayload['options'] ??
        promptPayload['mcqOptions'] ??
        promptPayload['chips'] ??
        promptPayload['word_bank'];
    if (opts is List) {
      return opts
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (questionKind == 'translation' || questionKind == 'reorder') {
      return _wordsFromAnswer(mcqCorrectAnswer);
    }
    return [];
  }

  List<String> _wordsFromAnswer(String answer) {
    final cleaned = answer.replaceAll(RegExp(r'[.,!?;:]'), '');
    return cleaned
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// For MCQ — returns the correct answer string from grading_payload.
  String get mcqCorrectAnswer {
    final fromGrading =
        gradingPayload['correct_answer'] ?? promptPayload['mcqCorrectAnswer'];
    if (fromGrading != null && fromGrading.toString().isNotEmpty) {
      return fromGrading.toString();
    }
    final idx = gradingPayload['correct_index'];
    final opts = mcqOptions;
    if (idx is int && idx >= 0 && idx < opts.length) {
      return opts[idx];
    }
    return '';
  }

  /// Accepted answers for fill-in / translation (server re-grades on submit).
  List<String> get acceptedAnswers {
    final raw = gradingPayload['accepted_answers'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).toList();
    }
    final single = mcqCorrectAnswer;
    if (single.isNotEmpty) return [single];
    return [];
  }

  /// Prompt text from payload (Admin, seed, or import).
  String get promptText =>
      promptPayload['question']?.toString() ??
      promptPayload['text']?.toString() ??
      promptPayload['prompt']?.toString() ??
      '';

  /// For image-based questions
  String? get imageUrl =>
      ApiClient.resolveMediaUrl(promptPayload['image_url']?.toString());

  /// For audio/listening/dictation/speaking questions
  String? get audioUrl =>
      ApiClient.resolveMediaUrl(promptPayload['audio_url']?.toString());

  bool get ttsEnabled {
    final value = promptPayload['tts_enabled'];
    return value == true || value?.toString().toLowerCase() == 'true';
  }

  String get ttsLanguage =>
      promptPayload['tts_language']?.toString().trim().isNotEmpty == true
      ? promptPayload['tts_language'].toString()
      : 'fr-FR';

  String get textToSpeak {
    final explicit = _firstString(promptPayload, [
      'tts_text',
      'audio_text',
      'speak_text',
    ]);
    if (explicit.isNotEmpty) return explicit;

    final targetText = _firstString(promptPayload, [
      'target',
      'fr',
      'sentence',
      'phrase',
      'dictation_text',
      'listening_text',
    ]);
    if (targetText.isNotEmpty) return targetText;

    if (questionKind == 'translation' || questionKind == 'reorder') {
      return mcqCorrectAnswer;
    }

    return '';
  }

  /// For MCQ Multi questions — returns list of correct options.
  List<String> get mcqMultiCorrectAnswers {
    final correct = gradingPayload['correct_answers'];
    if (correct is List) return correct.map((e) => e.toString()).toList();
    return [];
  }

  /// For Match Pairs — returns list of maps with 'left' and 'right' keys.
  List<Map<String, String>> get matchPairs {
    final pairs = promptPayload['pairs'];
    if (pairs is List) {
      return pairs.map((e) {
        if (e is Map) {
          return {
            'left': e['left']?.toString() ?? '',
            'right': e['right']?.toString() ?? '',
          };
        }
        return <String, String>{};
      }).toList();
    }
    return [];
  }
}

String _firstString(Map<String, dynamic> payload, List<String> keys) {
  for (final key in keys) {
    final value = payload[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return '';
}
