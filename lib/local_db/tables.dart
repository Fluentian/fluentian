import 'package:drift/drift.dart';

/// Locally cached course metadata. Mirrors the backend's Course row closely
/// enough to render list/detail screens without a network round trip;
/// [contentVersion] is compared against manifest deltas to decide whether
/// this row needs a re-fetch.
class CachedCourses extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get levelMin => text()();
  TextColumn get levelMax => text()();
  IntColumn get contentVersion => integer().withDefault(const Constant(1))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(true))();
  TextColumn get contentLanguage => text().withDefault(const Constant('en'))();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedUnits extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get unitKind => text()();
  IntColumn get unitNo => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get contentVersion => integer().withDefault(const Constant(1))();
  TextColumn get contentLanguage => text().withDefault(const Constant('en'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// [detailJson] holds the full LessonDetailResponse (blocks + questions) as
/// a JSON blob once downloaded; it's null until the lesson has actually
/// been fetched (list screens only need the summary columns).
class CachedLessons extends Table {
  TextColumn get id => text()();
  TextColumn get unitId => text()();
  TextColumn get courseId => text()();
  TextColumn get lessonKind => text()();
  IntColumn get sequenceNo => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(5))();
  IntColumn get xpReward => integer().withDefault(const Constant(10))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(true))();
  IntColumn get contentVersion => integer().withDefault(const Constant(1))();
  TextColumn get detailJson => text().nullable()();
  DateTimeColumn get detailFetchedAt => dateTime().nullable()();
  TextColumn get contentLanguage => text().withDefault(const Constant('en'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row table tracking how far this device's local content store has
/// synced against the backend's global_content_version counter.
class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get lastSyncedGlobalVersion =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get contentLanguage => text().withDefault(const Constant('en'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Outbox for lesson-completion writes made while offline (or just to
/// decouple the UI from network latency). Each row carries the exact
/// request body including a client-generated idempotency key, so a
/// replayed sync after a retry can't double-award XP server-side.
class ProgressOutboxEntries extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get operation =>
      text().withDefault(const Constant('complete_lesson'))();
  TextColumn get lessonId => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get requestPayloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Bookkeeping for downloaded media (lesson audio/images) so the LRU cache
/// manager knows what's on disk, how big it is, and when it was last used.
class MediaCacheEntries extends Table {
  TextColumn get url => text()();
  TextColumn get localPath => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAccessedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get lessonId => text().nullable()();

  @override
  Set<Column> get primaryKey => {url};
}

/// Units the learner explicitly downloaded for offline use (as opposed to
/// media that was merely cached in passing while playing a lesson online).
/// Drives the "downloaded" badge and the wifi-only bulk download screen.
class UnitDownloads extends Table {
  TextColumn get unitId => text()();
  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {unitId};
}

class ContentTombstones extends Table {
  TextColumn get entityId => text()();
  TextColumn get entityType => text()();
  IntColumn get contentVersion => integer()();

  @override
  Set<Column> get primaryKey => {entityId, entityType};
}

/// Small JSON response cache for endpoints whose payload is not represented
/// by curriculum rows (course pages and localized lesson details). Keeping it
/// in the same Drift database avoids the legacy second SQLite store.
class ApiCacheEntries extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get jsonValue => text()();
  DateTimeColumn get cachedAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cacheKey};
}
