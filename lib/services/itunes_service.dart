import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';

/// Mencari lagu. Coba iTunes dulu, kalau gagal (misalnya HTTP 403)
/// otomatis beralih ke Deezer. Keduanya memberi preview 30 detik.
class ItunesService {
  static const _headers = {
    // Beberapa server menolak User-Agent bawaan Dart, jadi pakai yang umum
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0 Safari/537.36',
    'Accept': 'application/json',
  };

  static Future<List<Song>> searchSongs(String query, {int limit = 25}) async {
    try {
      return await _searchItunes(query, limit);
    } catch (e) {
      debugPrint('iTunes gagal ($e), beralih ke Deezer');
      try {
        return await _searchDeezer(query, limit);
      } catch (e2) {
        debugPrint('Deezer juga gagal ($e2)');
        throw Exception(
            'Gagal memuat lagu dari iTunes maupun Deezer.\n'
                'Periksa koneksi internet atau coba ganti jaringan.');
      }
    }
  }

  static Future<List<Song>> _searchItunes(String query, int limit) async {
    final url = Uri.https('itunes.apple.com', '/search', {
      'term': query,
      'entity': 'song',
      'limit': '$limit',
    });

    final response = await http
        .get(url, headers: _headers)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('iTunes HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return (data['results'] as List? ?? [])
        .map((e) => Song.fromItunes(e as Map<String, dynamic>))
        .where((s) => s.previewUrl.isNotEmpty)
        .toList();
  }

  static Future<List<Song>> _searchDeezer(String query, int limit) async {
    final url = Uri.https('api.deezer.com', '/search', {
      'q': query,
      'limit': '$limit',
    });

    final response = await http
        .get(url, headers: _headers)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Deezer HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data['error'] != null) {
      throw Exception('Deezer: ${data['error']}');
    }

    return (data['data'] as List? ?? [])
        .map((e) => Song.fromDeezer(e as Map<String, dynamic>))
        .where((s) => s.previewUrl.isNotEmpty)
        .toList();
  }
}