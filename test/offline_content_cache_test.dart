import 'package:flutter_test/flutter_test.dart';
import 'package:fluentian/services/offline_content_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists structured lesson content for offline reuse', () async {
    final cache = OfflineContentCache.forTesting();
    await cache.put('lesson:am:lesson-1', {
      'id': 'lesson-1',
      'title': 'ሰላምታ',
      'blocks': <dynamic>[],
    });

    final restored = await cache.get<Map<String, dynamic>>(
      'lesson:am:lesson-1',
    );
    expect(restored?['id'], 'lesson-1');
    expect(restored?['title'], 'ሰላምታ');
    expect(cache.hitRatio, greaterThan(0));
  });

  test('keeps progress mutations until the server acknowledges them', () async {
    final cache = OfflineContentCache.forTesting();
    await cache.enqueueMutation('mutation-1', 'complete_lesson', {
      'lesson_id': 'lesson-1',
      'score': 1.0,
    });
    expect(await cache.pendingMutations(), hasLength(1));
    await cache.acknowledgeMutation('mutation-1');
    expect(await cache.pendingMutations(), isEmpty);
  });
}
