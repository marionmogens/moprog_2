import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';
import '../models/song.dart';

/// Menyimpan favorit, playlist, riwayat, dan profil. Data disimpan permanen
/// di perangkat (shared_preferences), jadi tetap ada setelah aplikasi ditutup.
class LibraryService extends ChangeNotifier {
  LibraryService._();
  static final LibraryService instance = LibraryService._();

  static const avatarColors = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFFFF6B6B),
    Color(0xFF26A69A),
    Color(0xFFFFA726),
    Color(0xFF42A5F5),
    Color(0xFFEC407A),
  ];

  static const _maxRecent = 12;

  SharedPreferences? _prefs;

  final List<Song> favorites = [];
  final List<Playlist> playlists = [];
  final List<Song> recent = []; // terakhir diputar, yang terbaru di depan
  String profileName = 'Pengguna';
  int avatarColorIndex = 0;
  int playCount = 0;

  // ───── muat & simpan ─────

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      _prefs = p;

      List<Song> readSongs(String key) {
        final raw = p.getString(key);
        if (raw == null) return [];
        return (jsonDecode(raw) as List)
            .map((e) => Song.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      favorites
        ..clear()
        ..addAll(readSongs('favorites'));
      recent
        ..clear()
        ..addAll(readSongs('recent'));

      final plJson = p.getString('playlists');
      if (plJson != null) {
        playlists
          ..clear()
          ..addAll((jsonDecode(plJson) as List).map(
                  (e) => Playlist.fromMap(Map<String, dynamic>.from(e as Map))));
      }

      profileName = p.getString('profile_name') ?? 'Pengguna';
      avatarColorIndex = p.getInt('avatar_color') ?? 0;
      playCount = p.getInt('play_count') ?? 0;
    } catch (e) {
      debugPrint('Gagal memuat data: $e');
    }
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    try {
      await p.setString(
          'favorites', jsonEncode(favorites.map((s) => s.toMap()).toList()));
      await p.setString(
          'recent', jsonEncode(recent.map((s) => s.toMap()).toList()));
      await p.setString(
          'playlists', jsonEncode(playlists.map((e) => e.toMap()).toList()));
      await p.setString('profile_name', profileName);
      await p.setInt('avatar_color', avatarColorIndex);
      await p.setInt('play_count', playCount);
    } catch (e) {
      debugPrint('Gagal menyimpan data: $e');
    }
  }

  void _commit() {
    notifyListeners();
    _save();
  }

  // ───── riwayat ─────

  /// Dipanggil setiap kali sebuah lagu mulai diputar
  void registerPlay(Song s) {
    playCount++;
    recent.remove(s);
    recent.insert(0, s);
    if (recent.length > _maxRecent) recent.removeLast();
    _commit();
  }

  // ───── favorit ─────

  bool isFavorite(Song s) => favorites.contains(s);

  /// Mengembalikan true kalau sekarang menjadi favorit.
  bool toggleFavorite(Song s) {
    if (favorites.contains(s)) {
      favorites.remove(s);
      _commit();
      return false;
    }
    favorites.insert(0, s);
    _commit();
    return true;
  }

  void clearFavorites() {
    favorites.clear();
    _commit();
  }

  // ───── playlist ─────

  Playlist createPlaylist(String name, {Song? firstSong}) {
    return createPlaylistFrom(name, firstSong != null ? [firstSong] : []);
  }

  /// Membuat playlist baru berisi [songs] (misalnya menyalin playlist pilihan)
  Playlist createPlaylistFrom(String name, List<Song> songs) {
    final p = Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      songs: List<Song>.of(songs),
    );
    playlists.insert(0, p);
    _commit();
    return p;
  }

  void renamePlaylist(Playlist p, String name) {
    p.name = name;
    _commit();
  }

  void deletePlaylist(Playlist p) {
    playlists.remove(p);
    _commit();
  }

  /// Mengembalikan false kalau lagu sudah ada di playlist.
  bool addToPlaylist(Playlist p, Song s) {
    if (p.songs.contains(s)) return false;
    p.songs.add(s);
    _commit();
    return true;
  }

  void removeFromPlaylist(Playlist p, Song s) {
    p.songs.remove(s);
    _commit();
  }

  // ───── profil ─────

  void setProfile({required String name, required int colorIndex}) {
    profileName = name;
    avatarColorIndex = colorIndex;
    _commit();
  }

  void resetAll() {
    favorites.clear();
    playlists.clear();
    recent.clear();
    playCount = 0;
    _commit();
  }
}