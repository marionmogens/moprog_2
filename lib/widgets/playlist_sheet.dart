import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../utils/helpers.dart';
import 'playlist_cover.dart';

/// Bottom sheet untuk memilih playlist tujuan atau membuat playlist baru
Future<void> showAddToPlaylistSheet(BuildContext context, Song song) async {
  final messenger = ScaffoldMessenger.of(context);
  final lib = LibraryService.instance;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final cs = Theme.of(sheetContext).colorScheme;
      final maxHeight = MediaQuery.of(sheetContext).size.height * 0.7;

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tambah ke playlist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_rounded, color: cs.primary),
                ),
                title: const Text('Playlist baru',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final name = await promptText(
                    context,
                    title: 'Playlist baru',
                    hint: 'Nama playlist',
                    confirmLabel: 'Buat',
                  );
                  if (name == null) return;
                  lib.createPlaylist(name, firstSong: song);
                  showSnackOn(messenger, 'Ditambahkan ke "$name"');
                },
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in lib.playlists)
                      ListTile(
                        leading: PlaylistCover(playlist: p, size: 46),
                        title: Text(p.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${p.songs.length} lagu'),
                        trailing: p.songs.contains(song)
                            ? Icon(Icons.check_circle_rounded,
                            color: cs.primary)
                            : null,
                        onTap: () {
                          final added = lib.addToPlaylist(p, song);
                          Navigator.pop(sheetContext);
                          showSnackOn(
                            messenger,
                            added
                                ? 'Ditambahkan ke "${p.name}"'
                                : 'Lagu sudah ada di "${p.name}"',
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}