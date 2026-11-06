import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/song_tile.dart';
import 'player_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  void _play(BuildContext context, List<Song> list) {
    PlayerService.instance.playFrom(list, 0, label: 'Favorit');
    openPlayerPage(context);
  }

  @override
  Widget build(BuildContext context) {
    final lib = LibraryService.instance;

    return SafeArea(
      child: ListenableBuilder(
        listenable: lib,
        builder: (context, _) {
          final favs = lib.favorites;
          final hero = _Hero(
            count: favs.length,
            onPlay: favs.isEmpty ? null : () => _play(context, favs),
            onShuffle: favs.isEmpty
                ? null
                : () => _play(context, List<Song>.of(favs)..shuffle()),
          );

          if (favs.isEmpty) {
            return ListView(
              children: [
                hero,
                const SizedBox(height: 40),
                const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  text: 'Belum ada lagu favorit\n'
                      'Tekan ikon hati di lagu mana pun untuk menyimpannya.',
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: favs.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return hero;
              final index = i - 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SongTile(
                  song: favs[index],
                  onTap: () {
                    PlayerService.instance
                        .playFrom(favs, index, label: 'Favorit');
                    openPlayerPage(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final int count;
  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;
  const _Hero({required this.count, this.onPlay, this.onShuffle});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [purple, Color(0xFFEC407A)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lagu Favorit',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$count lagu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: purple,
                  ),
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Putar semua'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  onPressed: onShuffle,
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('Acak'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}