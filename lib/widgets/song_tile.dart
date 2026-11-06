import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';
import '../utils/helpers.dart';
import 'playlist_sheet.dart';

/// Satu baris lagu (gaya daftar ala Spotify): cover, judul, artis,
/// tombol favorit, dan menu ⋮. Baris lagu yang sedang diputar diberi warna lembut.
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  /// Kalau diisi, menu ⋮ punya opsi tambahan (misalnya "Hapus dari playlist")
  final VoidCallback? onRemove;
  final String removeLabel;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onRemove,
    this.removeLabel = 'Hapus',
  });

  void _onMenu(BuildContext context, String value) {
    final player = PlayerService.instance;
    switch (value) {
      case 'next':
        showSnack(context, player.enqueueNext(song));
        break;
      case 'queue':
        showSnack(context, player.enqueue(song));
        break;
      case 'playlist':
        showAddToPlaylistSheet(context, song);
        break;
      case 'fav':
        final nowFav = LibraryService.instance.toggleFavorite(song);
        showSnack(context,
            nowFav ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit');
        break;
      case 'remove':
        onRemove?.call();
        break;
    }
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: kTextGrey),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lib = LibraryService.instance;
    final player = PlayerService.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([lib, player]),
      builder: (context, _) {
        final isFav = lib.isFavorite(song);
        final isCurrent = player.current == song;
        final isPlaying = isCurrent && player.isPlaying;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isCurrent
                ? cs.primary.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            song.artworkSmall,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 54,
                              height: 54,
                              color: kSoftBg,
                              child: Icon(Icons.music_note, color: cs.primary),
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isPlaying
                                  ? Icons.graphic_eq_rounded
                                  : Icons.pause_rounded,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isCurrent ? cs.primary : kTextDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: kTextGrey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip:
                      isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                      onPressed: () => lib.toggleFavorite(song),
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : Colors.black38,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Colors.black38),
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onSelected: (v) => _onMenu(context, v),
                      itemBuilder: (_) => [
                        _item('next', Icons.playlist_play_rounded,
                            'Putar berikutnya'),
                        _item('queue', Icons.queue_music_rounded,
                            'Tambah ke antrian'),
                        _item('playlist', Icons.playlist_add_rounded,
                            'Tambah ke playlist'),
                        _item(
                          'fav',
                          isFav
                              ? Icons.favorite_border_rounded
                              : Icons.favorite_rounded,
                          isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                        ),
                        if (onRemove != null)
                          _item('remove', Icons.remove_circle_outline_rounded,
                              removeLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}