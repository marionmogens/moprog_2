import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/library_service.dart';
import '../utils/helpers.dart';

Future<void> renamePlaylistDialog(BuildContext context, Playlist p) async {
  final name = await promptText(
    context,
    title: 'Ganti nama playlist',
    initial: p.name,
    hint: 'Nama playlist',
  );
  if (name != null) LibraryService.instance.renamePlaylist(p, name);
}

/// Mengembalikan true kalau playlist jadi dihapus
Future<bool> deletePlaylistDialog(BuildContext context, Playlist p) async {
  final ok = await confirmDialog(
    context,
    title: 'Hapus playlist?',
    message: 'Playlist "${p.name}" akan dihapus. Lagu di dalamnya tidak '
        'terhapus dari favorit.',
  );
  if (ok) LibraryService.instance.deletePlaylist(p);
  return ok;
}