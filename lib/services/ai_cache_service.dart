import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local device-level caching for AI Quick Actions
/// (Summarize, Example, Quiz) to eliminate unnecessary network hits.
class AiCacheService {
  AiCacheService._();
  static final AiCacheService instance = AiCacheService._();

  final Map<String, Map<String, dynamic>> _memoryCache = {};

  String _buildCacheKey(String action, String contentId, String languageCode) {
    return 'ai_cache_${action}_${contentId}_$languageCode';
  }

  /// Retrieve cached AI response payload if present.
  Future<Map<String, dynamic>?> getCachedResponse({
    required String action,
    required String contentId,
    required String languageCode,
  }) async {
    final key = _buildCacheKey(action, contentId, languageCode);

    // 1. Check in-memory cache first (0ms)
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    // 2. Check SharedPreferences persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _memoryCache[key] = decoded;
        return decoded;
      }
    } catch (e) {
      debugPrint('AiCacheService read error: $e');
    }

    return null;
  }

  /// Store AI response payload in memory and SharedPreferences.
  Future<void> saveResponse({
    required String action,
    required String contentId,
    required String languageCode,
    required Map<String, dynamic> payload,
  }) async {
    final key = _buildCacheKey(action, contentId, languageCode);
    _memoryCache[key] = payload;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(payload));
    } catch (e) {
      debugPrint('AiCacheService write error: $e');
    }
  }
}
