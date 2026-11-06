import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';
import '../utils/helpers.dart';
import '../widgets/collection_header.dart';
import '../widgets/cover_card.dart';
import '../widgets/mini_player.dart';
import '../widgets/play_all_buttons.dart';
import '../widgets/pulse_box.dart';
import '../widgets/song_tile.dart';
import 'player_page.dart';

/// Isi satu playlist pilihan dari Beranda
class CuratedPage extends StatelessWidget {
  final CuratedPlaylist playlist;
  const CuratedPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final home = HomeService.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      body: ListenableBuilder(
        listenable: home,
        builder: (context, _) {
          final songs = playlist.songs;

          return CustomScrollView(
            slivers: [
              CollectionHeader(
                colors: playlist.colors,
                title: playlist.title,
                subtitle: playlist.subtitle,
                cover: GradientCover(
                  colors: playlist.colors,
                  imageUrl: playlist.coverUrl,
                  size: 170,
                  radius: 24,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Text(
                        songs.isEmpty ? 'Memuat lagu...' : '${songs.length} lagu',
                        style: const TextStyle(color: kTextGrey),
                      ),
                    ),
                    PlayAllButtons(songs: songs, label: playlist.title),
                    if (songs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: TextButton.icon(
                          onPressed: () {
                            LibraryService.instance
                                .createPlaylistFrom(playlist.title, songs);
                            showSnack(context, 'Disimpan ke playlist kamu');
                          },
                          icon: const Icon(Icons.library_add_rounded),
                          label: const Text('Simpan ke playlist saya'),
                        ),
                      ),
                  ],
                ),
              ),
              if (songs.isEmpty)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) => SongTile(
                        song: songs[i],
                        onTap: () {
                          PlayerService.instance
                              .playFrom(songs, i, label: playlist.title);
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

  Widget _buildEmpty() {
    if (playlist.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            for (var i = 0; i < 6; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: PulseBox(height: 54, radius: 12),
              ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Text('Gagal memuat lagu', style: TextStyle(color: kTextGrey)),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => HomeService.instance.retry(playlist),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}