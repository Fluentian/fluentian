import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../local_db/app_database.dart';

class OfflineMediaService {
  OfflineMediaService._();
  static final instance = OfflineMediaService._();

  static const maxCacheBytes = 500 * 1024 * 1024;
  final _store = AppDatabase.instance;

  Future<File?> download(String url, {bool wifiOnly = true}) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (wifiOnly && !connectivity.contains(ConnectivityResult.wifi)) {
      return null;
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    final root = await getApplicationSupportDirectory();
    final directory = Directory(path.join(root.path, 'offline_media'));
    await directory.create(recursive: true);
    final extension = path.extension(Uri.parse(url).path);
    final name = sha256.convert(response.bodyBytes).toString();
    final file = File(path.join(directory.path, '$name$extension'));
    await file.writeAsBytes(response.bodyBytes, flush: true);
    await _store.upsertMediaCacheEntry(
      MediaCacheEntriesCompanion.insert(
        url: url,
        localPath: file.path,
        sizeBytes: Value(response.bodyBytes.length),
      ),
    );
    await _evictToLimit();
    return file;
  }

  Future<int> estimateBytes(Iterable<String> urls) async {
    var total = 0;
    for (final url in urls) {
      try {
        final response = await http.head(Uri.parse(url));
        total += int.tryParse(response.headers['content-length'] ?? '') ?? 0;
      } catch (_) {}
    }
    return total;
  }

  Future<void> _evictToLimit() async {
    final entries = await _store.mediaOldestFirst();
    var total = entries.fold<int>(
      0,
      (sum, entry) => sum + (entry['size_bytes'] as int),
    );
    for (final entry in entries) {
      if (total <= maxCacheBytes) break;
      final file = File(entry['file_path'] as String);
      if (await file.exists()) await file.delete();
      total -= entry['size_bytes'] as int;
      await _store.removeMedia(entry['url'] as String);
    }
  }
}
