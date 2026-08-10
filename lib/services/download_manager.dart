import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../local_db/app_database.dart';
import '../models/course_model.dart';
import 'app_logger.dart';
import 'download_settings.dart';
import 'media_cache_manager.dart';
import 'sync_manager.dart';

enum DownloadOutcome { downloaded, wifiRequired, failed }

class DownloadResult {
  final DownloadOutcome outcome;
  final int lessonsDownloaded;
  const DownloadResult(this.outcome, {this.lessonsDownloaded = 0});
}

/// Explicit "download this unit for offline use" flow: caches every
/// lesson's full detail plus its audio, gated by the wifi-only setting.
/// Distinct from the passive caching SyncManager/MediaCacheManager already
/// do in the background -- this is a deliberate, user-initiated action
/// that also marks the unit as "downloaded" for the offline UI.
class DownloadManager {
  DownloadManager._();
  static final DownloadManager instance = DownloadManager._();

  final AppDatabase _db = AppDatabase.instance;
  final SyncManager _syncManager = SyncManager.instance;
  final MediaCacheManager _mediaCache = MediaCacheManager.instance;
  final DownloadSettings _settings = DownloadSettings.instance;

  Future<bool> _isOnWifi() async {
    final results = await Connectivity().checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  Future<Set<String>> getDownloadedUnitIds() => _db.getDownloadedUnitIds();

  /// Download every lesson in [unit] (full detail + audio) for offline use.
  /// Respects the wifi-only setting unless [ignoreWifiSetting] is true
  /// (used for an explicit "download anyway" confirmation from the UI).
  Future<DownloadResult> downloadUnit(
    UnitModel unit, {
    bool ignoreWifiSetting = false,
  }) async {
    if (!ignoreWifiSetting && await _violatesWifiOnly()) {
      return const DownloadResult(DownloadOutcome.wifiRequired);
    }

    var count = 0;
    try {
      for (final lesson in unit.lessons) {
        // Re-check on every lesson, not just once up front: a multi-lesson
        // unit download can take a while, and the device may switch from
        // wifi to cellular partway through -- checking only once would
        // silently keep burning mobile data for the rest of the unit.
        if (!ignoreWifiSetting && await _violatesWifiOnly()) {
          return DownloadResult(DownloadOutcome.wifiRequired, lessonsDownloaded: count);
        }
        final detailJson = await _syncManager.fetchAndCacheLessonDetail(lesson.id);
        await _downloadLessonMedia(detailJson);
        count++;
      }
      await _db.markUnitDownloaded(unit.id);
      return DownloadResult(DownloadOutcome.downloaded, lessonsDownloaded: count);
    } catch (e) {
      await AppLogger.instance.error('downloadUnit(${unit.id}) failed', e);
      return DownloadResult(DownloadOutcome.failed, lessonsDownloaded: count);
    }
  }

  Future<bool> _violatesWifiOnly() async {
    final wifiOnly = await _settings.getWifiOnly();
    return wifiOnly && !await _isOnWifi();
  }

  Future<void> removeUnitDownload(String unitId) => _db.unmarkUnitDownloaded(unitId);

  Future<void> _downloadLessonMedia(Map<String, dynamic> detailJson) async {
    for (final url in _audioUrlsIn(detailJson)) {
      await _mediaCache.getCachedFilePath(url);
    }
  }

  Iterable<String> _audioUrlsIn(Map<String, dynamic> detailJson) sync* {
    final blocks = (detailJson['blocks'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final block in blocks) {
      final url = _audioUrlFromPayload(block['block_payload']);
      if (url != null) yield url;
    }
    final questions = (detailJson['questions'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    for (final question in questions) {
      final url = _audioUrlFromPayload(question['prompt_payload']);
      if (url != null) yield url;
    }
  }

  String? _audioUrlFromPayload(Object? payload) {
    if (payload is! Map) return null;
    final url = payload['audio_url']?.toString();
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Best-effort size estimate for [unit], in bytes, via HEAD requests to
  /// every audio URL (no body downloaded). Returns null if it can't be
  /// determined (e.g. lesson detail isn't reachable at all).
  Future<int?> estimateUnitDownloadBytes(UnitModel unit) async {
    try {
      var total = 0;
      var sawAny = false;
      for (final lesson in unit.lessons) {
        final cached = await _db.getLesson(lesson.id);
        final Map<String, dynamic> detailJson;
        if (cached?.detailJson != null) {
          detailJson = jsonDecode(cached!.detailJson!) as Map<String, dynamic>;
        } else {
          detailJson = await _syncManager.fetchAndCacheLessonDetail(lesson.id);
        }
        for (final url in _audioUrlsIn(detailJson)) {
          final bytes = await _headContentLength(url);
          if (bytes != null) {
            total += bytes;
            sawAny = true;
          }
        }
      }
      return sawAny ? total : 0;
    } catch (e) {
      await AppLogger.instance.error('estimateUnitDownloadBytes(${unit.id}) failed', e);
      return null;
    }
  }

  Future<int?> _headContentLength(String url) async {
    try {
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final header = response.headers['content-length'];
      return header != null ? int.tryParse(header) : null;
    } catch (_) {
      return null;
    }
  }
}
