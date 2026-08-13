import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Legacy compatibility store.
///
/// Production content and media paths now use [AppDatabase]. This class is
/// retained temporarily for older tests/consumers and should not receive new
/// application call sites.
class OfflineContentCache {
  OfflineContentCache._([this._database]);
  factory OfflineContentCache.forTesting() =>
      OfflineContentCache._(NativeDatabase.memory());
  static final instance = OfflineContentCache._();

  QueryExecutor? _database;
  QueryExecutor get _executor => _database ??= LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(
      File(path.join(directory.path, 'fluentian_offline.sqlite')),
    );
  });
  Future<void>? _initializing;
  int hits = 0;
  int misses = 0;
  int bytesRead = 0;
  int bytesWritten = 0;

  Future<void> _initialize() => _initializing ??= _createSchema();

  Future<void> _createSchema() => _executor.ensureOpen(_OfflineSchema());

  Future<void> put(String key, Object value) async {
    await _initialize();
    final encoded = jsonEncode(value);
    final now = DateTime.now().millisecondsSinceEpoch;
    await _executor.runInsert(
      'INSERT OR REPLACE INTO content_cache '
      '(cache_key, json_value, cached_at, last_accessed_at) VALUES (?, ?, ?, ?)',
      [key, encoded, now, now],
    );
    bytesWritten += utf8.encode(encoded).length;
  }

  Future<T?> get<T>(String key) async {
    await _initialize();
    final rows = await _executor.runSelect(
      'SELECT json_value FROM content_cache WHERE cache_key = ?',
      [key],
    );
    if (rows.isEmpty) {
      misses++;
      return null;
    }
    try {
      final encoded = rows.first['json_value'] as String;
      await _executor.runUpdate(
        'UPDATE content_cache SET last_accessed_at = ? WHERE cache_key = ?',
        [DateTime.now().millisecondsSinceEpoch, key],
      );
      hits++;
      bytesRead += utf8.encode(encoded).length;
      return jsonDecode(encoded) as T;
    } catch (error) {
      misses++;
      await _executor.runDelete(
        'DELETE FROM content_cache WHERE cache_key = ?',
        [key],
      );
      if (kDebugMode) debugPrint('Discarded invalid offline cache: $error');
      return null;
    }
  }

  Future<void> enqueueMutation(
    String mutationId,
    String operation,
    Map<String, dynamic> payload,
  ) async {
    await _initialize();
    await _executor.runInsert(
      'INSERT OR IGNORE INTO progress_outbox '
      '(mutation_id, operation, json_payload, created_at) VALUES (?, ?, ?, ?)',
      [
        mutationId,
        operation,
        jsonEncode(payload),
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<List<Map<String, dynamic>>> pendingMutations() async {
    await _initialize();
    final rows = await _executor.runSelect(
      'SELECT mutation_id, operation, json_payload, attempt_count '
      'FROM progress_outbox ORDER BY created_at',
      const [],
    );
    return rows
        .map(
          (row) => {
            'mutation_id': row['mutation_id'],
            'operation': row['operation'],
            'payload': jsonDecode(row['json_payload'] as String),
            'attempt_count': row['attempt_count'],
          },
        )
        .toList();
  }

  Future<void> acknowledgeMutation(String mutationId) async {
    await _initialize();
    await _executor.runDelete(
      'DELETE FROM progress_outbox WHERE mutation_id = ?',
      [mutationId],
    );
  }

  Future<void> recordMedia(String url, String filePath, int sizeBytes) async {
    await _initialize();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _executor.runInsert(
      'INSERT OR REPLACE INTO media_cache '
      '(url, file_path, size_bytes, last_accessed_at) VALUES (?, ?, ?, ?)',
      [url, filePath, sizeBytes, now],
    );
  }

  Future<List<Map<String, dynamic>>> mediaOldestFirst() async {
    await _initialize();
    return _executor.runSelect(
      'SELECT url, file_path, size_bytes FROM media_cache ORDER BY last_accessed_at',
      const [],
    );
  }

  Future<void> removeMedia(String url) async {
    await _initialize();
    await _executor.runDelete('DELETE FROM media_cache WHERE url = ?', [url]);
  }

  double get hitRatio => hits + misses == 0 ? 0 : hits / (hits + misses);
}

class _OfflineSchema extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {
    await executor.ensureOpen(this);
    await executor.runCustom('''
      CREATE TABLE IF NOT EXISTS content_cache (
        cache_key TEXT PRIMARY KEY,
        json_value TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        last_accessed_at INTEGER NOT NULL
      )
    ''');
    await executor.runCustom('''
      CREATE TABLE IF NOT EXISTS progress_outbox (
        mutation_id TEXT PRIMARY KEY,
        operation TEXT NOT NULL,
        json_payload TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await executor.runCustom('''
      CREATE TABLE IF NOT EXISTS media_cache (
        url TEXT PRIMARY KEY,
        file_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        last_accessed_at INTEGER NOT NULL
      )
    ''');
  }
}
