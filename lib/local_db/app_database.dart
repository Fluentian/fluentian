import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'fluentian_offline.sqlite'));
    // Bundled sqlite3 binary (sqlite3_flutter_libs) rather than relying on
    // the OS's system library, so behavior is consistent across devices.
    applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    return NativeDatabase.createInBackground(file, setup: (db) {
      db.execute('PRAGMA foreign_keys = ON;');
    });
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
  int get schemaVersion => 1;

  // ── Sync state ────────────────────────────────────────

  Future<int> getLastSyncedGlobalVersion() async {
    final row = await (select(syncState)..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.lastSyncedGlobalVersion ?? 0;
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
    return into(progressOutboxEntries).insert(
      ProgressOutboxEntriesCompanion.insert(
        lessonId: lessonId,
        idempotencyKey: idempotencyKey,
        requestPayloadJson: requestPayloadJson,
      ),
    );
  }

  Future<List<ProgressOutboxEntry>> getPendingOutboxEntries() =>
      (select(progressOutboxEntries)..where((t) => t.status.equals('pending'))).get();

  Future<void> markOutboxEntrySynced(int localId) =>
      (delete(progressOutboxEntries)..where((t) => t.localId.equals(localId))).go();

  Future<void> markOutboxEntryFailed(int localId, String error) async {
    final entry = await (select(
      progressOutboxEntries,
    )..where((t) => t.localId.equals(localId))).getSingleOrNull();
    final nextRetryCount = (entry?.retryCount ?? 0) + 1;
    await (update(progressOutboxEntries)..where((t) => t.localId.equals(localId))).write(
      ProgressOutboxEntriesCompanion(
        status: const Value('failed'),
        retryCount: Value(nextRetryCount),
        lastError: Value(error),
      ),
    );
  }

  // ── Media cache (LRU bookkeeping) ─────────────────────

  Future<MediaCacheEntry?> getMediaCacheEntry(String url) =>
      (select(mediaCacheEntries)..where((t) => t.url.equals(url))).getSingleOrNull();

  Future<void> upsertMediaCacheEntry(MediaCacheEntriesCompanion entry) =>
      into(mediaCacheEntries).insertOnConflictUpdate(entry);

  Future<void> touchMediaCacheEntry(String url) =>
      (update(mediaCacheEntries)..where((t) => t.url.equals(url))).write(
        MediaCacheEntriesCompanion(lastAccessedAt: Value(DateTime.now())),
      );

  Future<void> deleteMediaCacheEntry(String url) =>
      (delete(mediaCacheEntries)..where((t) => t.url.equals(url))).go();

  Future<List<MediaCacheEntry>> getMediaCacheEntriesOldestFirst() =>
      (select(mediaCacheEntries)
            ..orderBy([(t) => OrderingTerm(expression: t.lastAccessedAt)]))
          .get();

  Future<int> getTotalMediaCacheBytes() async {
    final total = mediaCacheEntries.sizeBytes.sum();
    final query = selectOnly(mediaCacheEntries)..addColumns([total]);
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  // ── Unit downloads ────────────────────────────────────

  Future<void> markUnitDownloaded(String unitId) => into(unitDownloads)
      .insertOnConflictUpdate(UnitDownloadsCompanion.insert(unitId: unitId));

  Future<void> unmarkUnitDownloaded(String unitId) =>
      (delete(unitDownloads)..where((t) => t.unitId.equals(unitId))).go();

  Future<Set<String>> getDownloadedUnitIds() async {
    final rows = await select(unitDownloads).get();
    return rows.map((r) => r.unitId).toSet();
  }
}
