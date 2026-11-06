import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';
import '../utils/helpers.dart';
import '../widgets/collection_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/mini_player.dart';
import '../widgets/play_all_buttons.dart';
import '../widgets/playlist_actions.dart';
import '../widgets/playlist_cover.dart';
import '../widgets/song_tile.dart';
import 'player_page.dart';

class PlaylistDetailPage extends StatelessWidget {
  final Playlist playlist;
  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final lib = LibraryService.instance;
    const colors = [Color(0xFF7C4DFF), Color(0xFF5E35B1)];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      body: ListenableBuilder(
        listenable: lib,
        builder: (context, _) {
          final songs = playlist.songs;

          return CustomScrollView(
            slivers: [
              CollectionHeader(
                colors: colors,
                title: playlist.name,
                subtitle: '${songs.length} lagu',
                cover: PlaylistCover(playlist: playlist, size: 170),
                actions: [
                  PopupMenuButton<String>(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onSelected: (v) async {
                      if (v == 'rename') {
                        await renamePlaylistDialog(context, playlist);
                      } else if (v == 'delete') {
                        final deleted =
                        await deletePlaylistDialog(context, playlist);
                        if (deleted && context.mounted) Navigator.pop(context);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(children: [
                          Icon(Icons.edit_rounded, size: 20, color: kTextGrey),
                          SizedBox(width: 12),
                          Text('Ganti nama'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 20, color: Colors.redAccent),
                          SizedBox(width: 12),
                          Text('Hapus playlist'),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: PlayAllButtons(songs: songs, label: playlist.name),
                ),
              ),
              if (songs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: EmptyState(
                      icon: Icons.library_music_rounded,
                      text: 'Playlist masih kosong\n'
                          'Tambahkan lagu lewat menu ⋮ → Tambah ke playlist.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) => SongTile(
                        song: songs[i],
                        removeLabel: 'Hapus dari playlist',
                        onRemove: () =>
                            lib.removeFromPlaylist(playlist, songs[i]),
                        onTap: () {
                          PlayerService.instance
                              .playFrom(songs, i, label: playlist.name);
                          openPlayerPage(context);
                        },
                      ),
                      childCount: songs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}