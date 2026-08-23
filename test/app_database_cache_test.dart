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
}
