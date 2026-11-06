import 'package:flutter/material.dart';
import '../pages/player_page.dart';
import '../services/player_service.dart';
import '../utils/helpers.dart';

/// Pemutar mini di atas navigasi bawah. Muncul kalau ada lagu yang diputar.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = PlayerService.instance;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: p,
      builder: (context, _) {
        final song = p.current;
        if (song == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Container(
            decoration: cardDecoration(radius: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => openPlayerPage(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                song.artworkSmall,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 46,
                                  height: 46,
                                  color: const Color(0xFFF1EFF7),
                                  child: Icon(Icons.music_note,
                                      color: cs.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: kTextDark,
                                    ),
                                  ),
                                  Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, color: kTextGrey),
                                  ),
                                ],
                              ),
                            ),
                            if (p.loading)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3),
                                ),
                              )
                            else
                              IconButton(
                                iconSize: 32,
                                color: cs.primary,
                                onPressed: p.togglePlay,
                                icon: Icon(
                                  p.isCompleted
                                      ? Icons.replay_rounded
                                      : p.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                              ),
                            IconButton(
                              iconSize: 28,
                              color: kTextDark,
                              onPressed: p.hasNext ? p.next : null,
                              icon: const Icon(Icons.skip_next_rounded),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<Duration>(
                        valueListenable: p.position,
                        builder: (_, pos, __) {
                          final total = p.duration.inMilliseconds;
                          final value = total <= 0
                              ? 0.0
                              : (pos.inMilliseconds / total)
                              .clamp(0.0, 1.0)
                              .toDouble();
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 3,
                            color: cs.primary,
                            backgroundColor: cs.primary.withValues(alpha: 0.12),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}