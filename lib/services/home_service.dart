import 'package:flutter/material.dart';
import '../models/song.dart';
import 'itunes_service.dart';

/// Playlist pilihan di Beranda. Isinya diambil dari hasil pencarian [query]
/// (iTunes, cadangan Deezer), jadi selalu segar tanpa perlu data bawaan.
class CuratedPlaylist {
  final String id;
  final String title;
  final String subtitle;
  final String query;
  final List<Color> colors;

  List<Song> songs = [];
  bool loading = false;
  String? error;

  CuratedPlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.query,
    required this.colors,
  });

  String? get coverUrl => songs.isEmpty ? null : songs.first.artworkLarge;
}

class HomeService extends ChangeNotifier {
  HomeService._();
  static final HomeService instance = HomeService._();

  /// Dimatikan di tes supaya tidak memanggil internet
  static bool autoLoad = true;

  final List<CuratedPlaylist> playlists = [
    CuratedPlaylist(
      id: 'hits',
      title: 'Hits Populer',
      subtitle: 'Lagu yang lagi banyak didengar',
      query: 'top hits',
      colors: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
    ),
    CuratedPlaylist(
      id: 'indo',
      title: 'Pop Indonesia',
      subtitle: 'Dari musisi tanah air',
      query: 'pop indonesia',
      colors: const [Color(0xFFFF6B6B), Color(0xFFFFA06B)],
    ),
    CuratedPlaylist(
      id: 'chill',
      title: 'Chill Vibes',
      subtitle: 'Santai sejenak',
      query: 'chill acoustic',
      colors: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
    ),
    CuratedPlaylist(
      id: 'rock',
      title: 'Rock Klasik',
      subtitle: 'Riff yang tak lekang waktu',
      query: 'classic rock',
      colors: const [Color(0xFF455A64), Color(0xFF90A4AE)],
    ),
    CuratedPlaylist(
      id: 'hiphop',
      title: 'Hip Hop',
      subtitle: 'Beat dan lirik tajam',
      query: 'hip hop',
      colors: const [Color(0xFFFFA726), Color(0xFFFFD54F)],
    ),
    CuratedPlaylist(
      id: 'kpop',
      title: 'K-Pop',
      subtitle: 'Hits dari Korea',
      query: 'kpop',
      colors: const [Color(0xFFEC407A), Color(0xFFF48FB1)],
    ),
  ];

  bool _started = false;
  bool _running = false;

  /// Memuat semua playlist pilihan (3 sekaligus supaya tidak terkena
  /// pembatasan request). Hanya jalan sekali kecuali [force].
  Future<void> loadAll({bool force = false}) async {
    if (_running) return;
    if (_started && !force) return;
    _started = true;
    _running = true;
    try {
      for (var i = 0; i < playlists.length; i += 3) {
        final batch = playlists.skip(i).take(3);
        await Future.wait(batch.map(_load));
      }
    } finally {
      _running = false;
    }
  }

  Future<void> reload() => loadAll(force: true);

  Future<void> retry(CuratedPlaylist p) => _load(p);

  Future<void> _load(CuratedPlaylist p) async {
    p.loading = true;
    p.error = null;
    notifyListeners();
    try {
      p.songs = await ItunesService.searchSongs(p.query, limit: 12);
    } catch (e) {
      debugPrint('Gagal memuat ${p.title}: $e');
      p.error = 'Gagal memuat';
    }
    p.loading = false;
    notifyListeners();
  }
}