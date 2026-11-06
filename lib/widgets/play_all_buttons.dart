import 'package:flutter/material.dart';
import '../models/song.dart';
import '../pages/player_page.dart';
import '../services/player_service.dart';

/// Tombol "Putar semua" dan "Acak" untuk daftar lagu
class PlayAllButtons extends StatelessWidget {
  final List<Song> songs;
  final String label;
  const PlayAllButtons({super.key, required this.songs, required this.label});

  void _play(BuildContext context, List<Song> list) {
    PlayerService.instance.playFrom(list, 0, label: label);
    openPlayerPage(context);
  }

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _play(context, songs),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Putar semua'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _play(context, List<Song>.of(songs)..shuffle()),
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('Acak'),
            ),
          ),
        ],
      ),
    );
  }
}