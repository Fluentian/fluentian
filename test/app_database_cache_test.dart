import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:fluentian/local_db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'unified Drift database stores and reads JSON API cache entries',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.putApiCache('courses:am:all', [
        {'id': 'course-1', 'title': 'መሠረቶች'},
      ]);

      final cached = await database.getApiCache<List<dynamic>>(
        'courses:am:all',
      );
      expect(cached?.single['title'], 'መሠረቶች');
    },
  );

  test(
    'starter curriculum asset is bundled for first-launch seeding',
    () async {
      final asset = await rootBundle.loadString(
        'assets/starter_curriculum.json',
      );
      expect(asset, contains('FR_STARTER'));
      expect(asset, contains('Bonjour and salut'));
    },
  );

  test('outbox stores pending writes and retries failed writes', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final id = await database.queueMutation(
      operation: 'complete_lesson',
      lessonId: 'lesson-1',
      idempotencyKey: 'key-1',
      requestPayloadJson: '{"score":1}',
    );
    expect((await database.getPendingOutboxEntries()).single.localId, id);
    await database.markOutboxEntryFailed(id, 'temporary failure');
    expect(await database.getFailedOutboxCount(), 1);
    await database.retryFailedOutbox();
    expect(await database.getFailedOutboxCount(), 0);
    expect((await database.getPendingOutboxEntries()).single.retryCount, 1);
  });
}
