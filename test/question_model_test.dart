import 'package:flutter_test/flutter_test.dart';
import 'package:fluentian/models/course_model.dart';

QuestionModel question({
  required Map<String, dynamic> prompt,
  required Map<String, dynamic> grading,
  String kind = 'translation',
}) {
  return QuestionModel(
    id: 'question-id',
    lessonId: 'lesson-id',
    questionKind: kind,
    sequenceNo: 1,
    difficulty: 1,
    promptPayload: prompt,
    gradingPayload: grading,
    createdAt: DateTime.utc(2026),
  );
}

void main() {
  test('empty Admin options fall back to translation answer words', () {
    final model = question(
      prompt: {
        'question': 'Translate into French: "My name is Sophie."',
        'options': <String>[],
        'mcqOptions': <String>[],
      },
      grading: {'correct_answer': "Je m'appelle Sophie."},
    );

    expect(model.mcqOptions, ['Je', "m'appelle", 'Sophie']);
  });

  test('legacy words and accepted answers remain usable', () {
    final model = question(
      prompt: {
        'question': 'Translate this',
        'options': <String>[],
        'words': ['Comment', 'ça', 'va'],
      },
      grading: {
        'accepted_answers': ['Comment ça va ?'],
      },
    );

    expect(model.mcqCorrectAnswer, 'Comment ça va ?');
    expect(model.mcqOptions, ['Comment', 'ça', 'va']);
  });
}
