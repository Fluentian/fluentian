import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../local_db/app_database.dart';
import 'app_logger.dart';

/// Download-then-play cache for lesson media (audio clips), with an LRU
/// eviction policy capped at ~500MB. Backend media is served under
/// immutable, content-hashed URLs (see backend app/utils/storage.py), so a
/// cached file never goes stale -- once downloaded it's valid forever,
/// which is what makes this safe to cache aggressively.
class MediaCacheManager {
  MediaCacheManager._();
  static final MediaCacheManager instance = MediaCacheManager._();

  static const int maxCacheBytes = 500 * 1024 * 1024; // 500MB

  final AppDatabase _db = AppDatabase.instance;

  // Concurrent calls for the same not-yet-cached URL (e.g. a lesson screen
  // pre-warming audio while a download-for-offline pass touches the same
  // clip) would otherwise race into duplicate downloads -- wasteful given
  // this cache exists specifically to cut data usage. In-flight downloads
  // are tracked here so a second caller just awaits the first one's result.
  final Map<String, Future<String?>> _inFlightDownloads = {};

  /// Load [url] into [player], using a cached local file if available
  /// (downloading it first if not), falling back to direct network
  /// streaming if caching fails for any reason so playback still works.
  Future<void> loadIntoPlayer(AudioPlayer player, String url) async {
    final localPath = await getCachedFilePath(url);
    if (localPath != null) {
      await player.setFilePath(localPath);
    } else {
      await player.setUrl(url);
    }
  }

  /// Return a local file path for [url], downloading and caching it first
  /// if needed. Returns null (never throws) if download/caching fails, so
  /// callers can fall back to direct streaming.
  Future<String?> getCachedFilePath(String url, {String? lessonId}) async {
    try {
      final existing = await _db.getMediaCacheEntry(url);
      if (existing != null) {
        if (await File(existing.localPath).exists()) {
          await _db.touchMediaCacheEntry(url);
          return existing.localPath;
        }
        // Row exists but the file is gone (e.g. OS reclaimed temp
        // storage) -- drop the stale row and re-download below.
        await _db.deleteMediaCacheEntry(url);
      }

      final inFlight = _inFlightDownloads[url];
      if (inFlight != null) return await inFlight;

      final download = _download(url, lessonId: lessonId);
      _inFlightDownloads[url] = download;
      try {
        return await download;
      } finally {
        _inFlightDownloads.remove(url);
      }
    } catch (e) {
      await AppLogger.instance.error('Media cache miss for $url', e);
      return null;
    }
  }

  Future<String?> _download(String url, {String? lessonId}) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) return null;

    final dir = await getTemporaryDirectory();
    final mediaDir = Directory(p.join(dir.path, 'media_cache'));
    await mediaDir.create(recursive: true);

    final digest = sha256.convert(utf8.encode(url)).toString();
    final ext = _extensionFor(url);
    final file = File(p.join(mediaDir.path, '$digest$ext'));
    await file.writeAsBytes(response.bodyBytes);

    await _db.upsertMediaCacheEntry(
      MediaCacheEntriesCompanion.insert(
        url: url,
        localPath: file.path,
        sizeBytes: Value(response.bodyBytes.length),
        lessonId: Value(lessonId),
      ),
    );
    await _evictIfOverCap();
    return file.path;
  }

  String _extensionFor(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final ext = p.extension(path);
    return ext.isNotEmpty ? ext : '.bin';
  }

  Future<void> _evictIfOverCap() async {
    var total = await _db.getTotalMediaCacheBytes();
    if (total <= maxCacheBytes) return;

    final entries = await _db.getMediaCacheEntriesOldestFirst();
    for (final entry in entries) {
      if (total <= maxCacheBytes) break;
      try {
        final file = File(entry.localPath);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort deletion; still drop the bookkeeping row below so we
        // don't keep counting a file we've lost track of against the cap.
      }
      await _db.deleteMediaCacheEntry(entry.url);
      total -= entry.sizeBytes;
    }
  }

  Future<int> getCurrentCacheBytes() => _db.getTotalMediaCacheBytes();

  Future<void> removeLessonMedia(String lessonId) async {
    final entries = await _db.getMediaCacheEntriesForLesson(lessonId);
    for (final entry in entries) {
      try {
        final file = File(entry.localPath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
      await _db.deleteMediaCacheEntry(entry.url);
    }
  }
}
