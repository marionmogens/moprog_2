import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/player_service.dart';
import '../utils/helpers.dart';

/// Bottom sheet antrian: lagu yang sedang diputar, antrian buatan user
/// (bisa diurutkan dan dihapus), dan sisa lagu dari daftar asal.
void showQueueSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _QueueSheet(),
  );
}

class _QueueSheet extends StatelessWidget {
  const _QueueSheet();

  SliverToBoxAdapter _header(String text, {Widget? trailing}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: kTextGrey,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = PlayerService.instance;
    final height = MediaQuery.of(context).size.height * 0.78;

    return SizedBox(
      height: height,
      child: ListenableBuilder(
        listenable: p,
        builder: (context, _) {
          final current = p.current;
          final upcoming = p.upcomingContext;
          final upcomingLabel = p.contextLabel.isEmpty
              ? 'SELANJUTNYA'
              : 'SELANJUTNYA DARI ${p.contextLabel.toUpperCase()}';

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
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
                    'Antrian lagu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (current != null) ...[
                      _header('SEDANG DIPUTAR'),
                      SliverToBoxAdapter(
                        child: _SongRow(song: current, highlight: true),
                      ),
                    ],
                    _header(
                      'ANTRIAN BERIKUTNYA (${p.queue.length})',
                      trailing: p.queue.isEmpty
                          ? null
                          : TextButton(
                        onPressed: p.clearQueue,
                        child: const Text('Kosongkan'),
                      ),
                    ),
                    if (p.queue.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Text(
                            'Antrian kosong. Tambahkan lagu lewat menu ⋮ '
                                'di daftar lagu.',
                            style: TextStyle(color: kTextGrey, height: 1.4),
                          ),
                        ),
                      ),
                    SliverReorderableList(
                      itemCount: p.queue.length,
                      onReorder: p.reorderQueue,
                      itemBuilder: (context, i) {
                        final s = p.queue[i];
                        return Material(
                          key: ValueKey('queue_${s.id}'),
                          color: Colors.white,
                          child: _SongRow(
                            song: s,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Hapus dari antrian',
                                  icon: const Icon(Icons.close_rounded,
                                      color: kTextGrey),
                                  onPressed: () => p.removeFromQueue(i),
                                ),
                                ReorderableDragStartListener(
                                  index: i,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.drag_handle_rounded,
                                        color: kTextGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (upcoming.isNotEmpty) ...[
                      _header(upcomingLabel),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, i) => _SongRow(
                            song: upcoming[i],
                            onTap: () => p.jumpToUpcoming(i),
                          ),
                          childCount: math.min(upcoming.length, 20),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SongRow extends StatelessWidget {
  final Song song;
  final bool highlight;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SongRow({
    required this.song,
    this.highlight = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                  child: Icon(Icons.music_note, color: cs.primary),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: highlight ? cs.primary : kTextDark,
                    ),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}