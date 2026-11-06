import 'package:flutter/foundation.dart';

/// Penanda tab yang aktif di navigasi bawah (0 Beranda, 1 Favorit, 2 Playlist, 3 Profil).
/// Dipakai supaya halaman mana pun bisa berpindah tab.
class AppNav {
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);
}