import 'package:flutter/material.dart';
import '../models/playlist.dart';

/// Cover playlist: memakai cover lagu pertama, atau ikon kalau masih kosong
class PlaylistCover extends StatelessWidget {
  final Playlist playlist;
  final double size;

  /// true = tanpa sudut membulat (dipakai di kotak pintasan yang sudah membulat)
  final bool square;

  const PlaylistCover({
    super.key,
    required this.playlist,
    this.size = 62,
    this.square = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final placeholder = Container(
      color: cs.primary.withValues(alpha: 0.1),
      child: Icon(Icons.queue_music_rounded,
          color: cs.primary, size: size * 0.45),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(square ? 0 : size * 0.22),
      child: SizedBox(
        width: size,
        height: size,
        child: playlist.songs.isEmpty
            ? placeholder
            : Image.network(
          size > 100
              ? playlist.songs.first.artworkLarge
              : playlist.songs.first.artworkSmall,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        ),
      ),
    );
  }
}