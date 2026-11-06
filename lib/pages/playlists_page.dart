import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/library_service.dart';
import '../utils/app_nav.dart';
import '../utils/helpers.dart';
import '../widgets/cover_card.dart';
import '../widgets/page_header.dart';
import '../widgets/playlist_actions.dart';
import '../widgets/playlist_cover.dart';
import 'playlist_detail_page.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  Future<void> _create(BuildContext context) async {
    final name = await promptText(
      context,
      title: 'Playlist baru',
      hint: 'Nama playlist',
      confirmLabel: 'Buat',
    );
    if (name == null) return;
    LibraryService.instance.createPlaylist(name);
    if (context.mounted) showSnack(context, 'Playlist "$name" dibuat');
  }

  void _open(BuildContext context, Playlist p) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PlaylistDetailPage(playlist: p),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lib = LibraryService.instance;

    return SafeArea(
      child: ListenableBuilder(
        listenable: lib,
        builder: (context, _) {
          final lists = lib.playlists;

          return Column(
            children: [
              PageHeader(
                title: 'Playlist',
                subtitle: lists.isEmpty
                    ? 'Kumpulkan lagumu di sini'
                    : '${lists.length} playlist',
                trailing: FilledButton.tonalIcon(
                  onPressed: () => _create(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Baru'),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.74,
                  ),
                  itemCount: lists.length + 2,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return _TileFrame(
                        title: 'Lagu Favorit',
                        subtitle: '${lib.favorites.length} lagu',
                        onTap: () => AppNav.tab.value = 1,
                        cover: const GradientCover(
                          colors: [Color(0xFF7C4DFF), Color(0xFFEC407A)],
                          size: 200,
                          icon: Icons.favorite_rounded,
                        ),
                      );
                    }
                    if (i == 1) {
                      return _NewTile(onTap: () => _create(context));
                    }
                    final p = lists[i - 2];
                    return _TileFrame(
                      title: p.name,
                      subtitle: '${p.songs.length} lagu',
                      onTap: () => _open(context, p),
                      cover: LayoutBuilder(
                        builder: (_, c) =>
                            PlaylistCover(playlist: p, size: c.maxWidth),
                      ),
                      menu: _CellMenu(playlist: p),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Satu sel di grid: cover persegi besar + judul + jumlah lagu
class _TileFrame extends StatelessWidget {
  final Widget cover;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? menu;

  const _TileFrame({
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: cover,
                  ),
                  if (menu != null) Positioned(top: 6, right: 6, child: menu!),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: kTextGrey)),
          ],
        ),
      ),
    );
  }
}

class _NewTile extends StatelessWidget {
  final VoidCallback onTap;
  const _NewTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Icon(Icons.add_rounded, size: 44, color: cs.primary),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Playlist baru',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            const Text('Buat koleksimu',
                style: TextStyle(fontSize: 12, color: kTextGrey)),
          ],
        ),
      ),
    );
  }
}

class _CellMenu extends StatelessWidget {
  final Playlist playlist;
  const _CellMenu({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: PopupMenuButton<String>(
        iconSize: 18,
        padding: const EdgeInsets.all(6),
        icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (v) {
          if (v == 'rename') renamePlaylistDialog(context, playlist);
          if (v == 'delete') deletePlaylistDialog(context, playlist);
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
    );
  }
}