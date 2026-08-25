import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import 'tables.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'fluentian_offline.sqlite'));
    // Bundled sqlite3 binary (sqlite3_flutter_libs) rather than relying on
    // the OS's system library, so behavior is consistent across devices.
    applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}

@DriftDatabase(
  tables: [
    CachedCourses,
    CachedUnits,
    CachedLessons,
    SyncState,
    ProgressOutboxEntries,
    MediaCacheEntries,
    UnitDownloads,
    ContentTombstones,
    ApiCacheEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  static AppDatabase? _instance;

  /// Process-wide singleton. Drift/sqlite3 manages its own connection pool
  /// internally; sharing one instance avoids opening the sqlite file twice.
  static AppDatabase get instance => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(cachedCourses, cachedCourses.contentLanguage);
        await m.addColumn(cachedUnits, cachedUnits.contentLanguage);
        await m.addColumn(cachedLessons, cachedLessons.contentLanguage);
        await m.addColumn(syncState, syncState.contentLanguage);
      }
      if (from < 3) {
        await m.addColumn(cachedCourses, cachedCourses.title);
        await m.addColumn(cachedCourses, cachedCourses.description);
        await m.addColumn(cachedUnits, cachedUnits.description);
      }
      if (from < 4) {
        await m.createTable(contentTombstones);
      }
      if (from < 5) {
        await m.createTable(apiCacheEntries);
      }
      if (from < 6) {
        await m.addColumn(
          progressOutboxEntries,
          progressOutboxEntries.operation,
        );
      }
    },
  );

  // ── Sync state ────────────────────────────────────────

  Future<int> getLastSyncedGlobalVersion() async {
    final row = await (select(
      syncState,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.lastSyncedGlobalVersion ?? 0;
  }

  Future<String> getLastSyncedLanguage() async {
    final row = await (select(
      syncState,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.contentLanguage ?? 'en';
  }

  Future<void> setLastSyncedGlobalVersion(int version) async {
    await into(syncState).insertOnConflictUpdate(
      SyncStateCompanion.insert(
        id: const Value(1),
        lastSyncedGlobalVersion: Value(version),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setSyncLanguage(String language) async {
    await into(syncState).insertOnConflictUpdate(
      SyncStateCompanion.insert(
        id: const Value(1),
        contentLanguage: Value(language),
      ),
    );
  }

  Future<void> clearCachedCurriculum() async {
    await transaction(() async {
      await delete(cachedLessons).go();
      await delete(cachedUnits).go();
      await delete(cachedCourses).go();
      await update(
        syncState,
      ).write(const SyncStateCompanion(lastSyncedGlobalVersion: Value(0)));
    });
  }

  Future<void> removeContent(String entityId, String entityType) async {
    await transaction(() async {
      if (entityType == 'course') {
        final units = await getUnitsForCourse(entityId);
        for (final unit in units) {
          await removeContent(unit.id, 'unit');
        }
        await (delete(cachedCourses)..where((t) => t.id.equals(entityId))).go();
      } else if (entityType == 'unit') {
        await (delete(
          cachedLessons,
        )..where((t) => t.unitId.equals(entityId))).go();
        await (delete(cachedUnits)..where((t) => t.id.equals(entityId))).go();
        await (delete(
          unitDownloads,
        )..where((t) => t.unitId.equals(entityId))).go();
      } else if (entityType == 'lesson') {
        await (delete(cachedLessons)..where((t) => t.id.equals(entityId))).go();
      }
      await into(contentTombstones).insertOnConflictUpdate(
        ContentTombstonesCompanion.insert(
          entityId: entityId,
          entityType: entityType,
          contentVersion: 0,
        ),
      );
    });
  }

  // ── Content upserts (used by the sync manager) ───────

  Future<void> upsertCourse(CachedCoursesCompanion course) =>
      into(cachedCourses).insertOnConflictUpdate(course);

  Future<void> upsertUnit(CachedUnitsCompanion unit) =>
      into(cachedUnits).insertOnConflictUpdate(unit);

  Future<void> upsertLesson(CachedLessonsCompanion lesson) =>
      into(cachedLessons).insertOnConflictUpdate(lesson);

  Future<void> saveLessonDetail(String lessonId, String detailJson) async {
    await (update(cachedLessons)..where((t) => t.id.equals(lessonId))).write(
      CachedLessonsCompanion(
        detailJson: Value(detailJson),
        detailFetchedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> putApiCache(String key, Object value) async {
    final encoded = jsonEncode(value);
    final now = DateTime.now();
    await into(apiCacheEntries).insertOnConflictUpdate(
      ApiCacheEntriesCompanion.insert(
        cacheKey: key,
        jsonValue: encoded,
        cachedAt: now,
        lastAccessedAt: now,
      ),
    );
  }

  Future<T?> getApiCache<T>(String key) async {
    final entry = await (select(
      apiCacheEntries,
    )..where((t) => t.cacheKey.equals(key))).getSingleOrNull();
    if (entry == null) return null;
    await (update(apiCacheEntries)..where((t) => t.cacheKey.equals(key))).write(
      ApiCacheEntriesCompanion(lastAccessedAt: Value(DateTime.now())),
    );
    try {
      return jsonDecode(entry.jsonValue) as T;
    } catch (_) {
      await (delete(
        apiCacheEntries,
      )..where((t) => t.cacheKey.equals(key))).go();
      return null;
    }
  }

  /// One-time bridge for installs that used the pre-Drift cache database in
  /// Application Support. It is read-only and best-effort; all new writes use
  /// this database in Application Documents.
  Future<void> migrateLegacyApiCacheIfPresent() async {
    if (await getApiCache<bool>('legacy_cache_migrated') == true) return;
    final support = await getApplicationSupportDirectory();
    final legacyFile = File(p.join(support.path, 'fluentian_offline.sqlite'));
    if (await legacyFile.exists()) {
      sqlite3.Database? legacy;
      try {
        legacy = sqlite3.sqlite3.open(
          legacyFile.path,
          mode: sqlite3.OpenMode.readOnly,
        );
        final rows = legacy.select(
          'SELECT cache_key, json_value FROM content_cache',
        );
        for (final row in rows) {
          await putApiCache(
            row['cache_key'] as String,
            jsonDecode(row['json_value'] as String),
          );
        }
      } catch (_) {
        // A partially-created old database must never block app startup.
      } finally {
        // sqlite3 2.x exposes dispose(); newer APIs use close().
        // ignore: deprecated_member_use
        legacy?.dispose();
      }
    }
    await putApiCache('legacy_cache_migrated', true);
  }

  // ── Reads (used by ContentProvider for local-first access) ──

  Future<List<CachedCourse>> getAllCourses() => select(cachedCourses).get();

  Future<CachedCourse?> getCourse(String id) =>
      (select(cachedCourses)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CachedUnit>> getUnitsForCourse(String courseId) =>
      (select(cachedUnits)
            ..where((t) => t.courseId.equals(courseId))
            ..orderBy([(t) => OrderingTerm(expression: t.unitNo)]))
          .get();

  Future<List<CachedLesson>> getLessonsForUnit(String unitId) =>
      (select(cachedLessons)
            ..where((t) => t.unitId.equals(unitId))
            ..orderBy([(t) => OrderingTerm(expression: t.sequenceNo)]))
          .get();

  Future<CachedLesson?> getLesson(String id) =>
      (select(cachedLessons)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ── Progress outbox ───────────────────────────────────

  Future<int> queueProgressWrite({
    required String lessonId,
    required String idempotencyKey,
    required String requestPayloadJson,
  }) {
    return queueMutation(
      operation: 'complete_lesson',
      lessonId: lessonId,
      idempotencyKey: idempotencyKey,
      requestPayloadJson: requestPayloadJson,
    );
  }

  Future<int> queueMutation({
    required String operation,
    required String lessonId,
    required String idempotencyKey,
    required String requestPayloadJson,
  }) {
    return into(progressOutboxEntries).insert(
      ProgressOutboxEntriesCompanion.insert(
        operation: Value(operation),
        lessonId: lessonId,
        idempotencyKey: idempotencyKey,
        requestPayloadJson: requestPayloadJson,
      ),
    );
  }

  Future<List<ProgressOutboxEntry>> getPendingOutboxEntries() => (select(
    progressOutboxEntries,
  )..where((t) => t.status.equals('pending'))).get();

  Future<int> getFailedOutboxCount() async => (select(
    progressOutboxEntries,
  )..where((t) => t.status.equals('failed'))).get().then((rows) => rows.length);

  Future<void> retryFailedOutbox() =>
      (update(
        progressOutboxEntries,
      )..where((t) => t.status.equals('failed'))).write(
        const ProgressOutboxEntriesCompanion(status: Value('pending')),
      );

  Future<void> markOutboxEntrySynced(int localId) => (delete(
    progressOutboxEntries,
  )..where((t) => t.localId.equals(localId))).go();

  Future<void> markOutboxEntryFailed(int localId, String error) async {
    final entry = await (select(
      progressOutboxEntries,
    )..where((t) => t.localId.equals(localId))).getSingleOrNull();
    final nextRetryCount = (entry?.retryCount ?? 0) + 1;
    await (update(
      progressOutboxEntries,
    )..where((t) => t.localId.equals(localId))).write(
      ProgressOutboxEntriesCompanion(
        status: const Value('failed'),
        retryCount: Value(nextRetryCount),
        lastError: Value(error),
      ),
    );
  }

  // ── Media cache (LRU bookkeeping) ─────────────────────

  Future<MediaCacheEntry?> getMediaCacheEntry(String url) => (select(
    mediaCacheEntries,
  )..where((t) => t.url.equals(url))).getSingleOrNull();

  Future<void> upsertMediaCacheEntry(MediaCacheEntriesCompanion entry) =>
      into(mediaCacheEntries).insertOnConflictUpdate(entry);

  Future<void> touchMediaCacheEntry(String url) =>
      (update(mediaCacheEntries)..where((t) => t.url.equals(url))).write(
        MediaCacheEntriesCompanion(lastAccessedAt: Value(DateTime.now())),
      );

  Future<void> deleteMediaCacheEntry(String url) =>
      (delete(mediaCacheEntries)..where((t) => t.url.equals(url))).go();

  Future<List<MediaCacheEntry>> getMediaCacheEntriesForLesson(
    String lessonId,
  ) => (select(
    mediaCacheEntries,
  )..where((t) => t.lessonId.equals(lessonId))).get();

  Future<List<MediaCacheEntry>> getMediaCacheEntriesOldestFirst() => (select(
    mediaCacheEntries,
  )..orderBy([(t) => OrderingTerm(expression: t.lastAccessedAt)])).get();

  Future<int> getTotalMediaCacheBytes() async {
    final total = mediaCacheEntries.sizeBytes.sum();
    final query = selectOnly(mediaCacheEntries)..addColumns([total]);
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  Future<List<Map<String, dynamic>>> mediaOldestFirst() async {
    final entries = await getMediaCacheEntriesOldestFirst();
    return entries
        .map(
          (entry) => {
            'url': entry.url,
            'file_path': entry.localPath,
            'size_bytes': entry.sizeBytes,
          },
        )
        .toList();
  }

  Future<void> removeMedia(String url) => deleteMediaCacheEntry(url);

  // ── Unit downloads ────────────────────────────────────

  Future<void> markUnitDownloaded(String unitId) => into(
    unitDownloads,
  ).insertOnConflictUpdate(UnitDownloadsCompanion.insert(unitId: unitId));

  Future<void> unmarkUnitDownloaded(String unitId) =>
      (delete(unitDownloads)..where((t) => t.unitId.equals(unitId))).go();

  Future<Set<String>> getDownloadedUnitIds() async {
    final rows = await select(unitDownloads).get();
    return rows.map((r) => r.unitId).toSet();
  }
}
