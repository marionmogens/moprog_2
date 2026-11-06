import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/home_service.dart';
import '../services/itunes_service.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';
import '../utils/app_nav.dart';
import '../utils/helpers.dart';
import '../widgets/cover_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/playlist_cover.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/pulse_box.dart';
import '../widgets/section_header.dart';
import '../widgets/song_tile.dart';
import 'curated_page.dart';
import 'playlist_detail_page.dart';
import 'player_page.dart';

/// Beranda: search bar di atas, lalu playlist dan lagu pilihan ala Spotify.
/// Saat mencari, isi beranda diganti hasil pencarian.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  List<Song> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    if (HomeService.autoLoad) HomeService.instance.loadAll();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ───── pencarian ─────

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
      _lastQuery = query;
    });

    try {
      final results = await ItunesService.searchSongs(query);
      if (!mounted) return;
      setState(() => _results = results);
    } catch (e) {
      debugPrint('Search error: $e');
      if (!mounted) return;
      setState(() {
        _results = [];
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _exitSearch() {
    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {
      _searched = false;
      _results = [];
      _error = null;
    });
  }

  // ───── aksi ─────

  void _play(List<Song> songs, int index, String label) {
    PlayerService.instance.playFrom(songs, index, label: label);
    openPlayerPage(context);
  }

  void _openCurated(CuratedPlaylist p) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CuratedPage(playlist: p),
    ));
  }

  void _openUserPlaylist(Playlist p) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PlaylistDetailPage(playlist: p),
    ));
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  // ───── tampilan ─────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(child: _buildSearchBar()),
                const SizedBox(width: 12),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => AppNav.tab.value = 3,
                  child: const ProfileAvatar(size: 50),
                ),
              ],
            ),
          ),
          Expanded(child: _searched ? _buildResults() : _buildHome()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(),
      style: const TextStyle(color: kTextDark),
      decoration: InputDecoration(
        hintText: 'Cari lagu, artis, atau album',
        hintStyle: const TextStyle(color: Color(0xFF9A9AA5)),
        prefixIcon: _searched
            ? IconButton(
          tooltip: 'Kembali ke beranda',
          icon: const Icon(Icons.arrow_back_rounded, color: kTextDark),
          onPressed: _exitSearch,
        )
            : const Icon(Icons.search_rounded, color: Color(0xFF9A9AA5)),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: Material(
            color: cs.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _search,
              child:
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ),
          ),
        ),
        filled: true,
        fillColor: kSoftBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }

  // ───── hasil pencarian ─────

  Widget _buildResults() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return EmptyState(icon: Icons.wifi_off_rounded, text: _error!);
    }
    if (_results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        text: 'Lagu tidak ditemukan',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: _results.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Text(
              'Hasil untuk "$_lastQuery"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
          );
        }
        final index = i - 1;
        return SongTile(
          song: _results[index],
          onTap: () => _play(_results, index, 'Hasil pencarian'),
        );
      },
    );
  }

  // ───── beranda ─────

  Widget _buildHome() {
    final home = HomeService.instance;
    final lib = LibraryService.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([home, lib]),
      builder: (context, _) {
        final sections = home.playlists;
        final first = sections.first;
        final rest = sections.skip(1).toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildGreeting(lib, home),
            _buildQuickAccess(lib, sections),
            if (lib.recent.isNotEmpty) ...[
              const SectionHeader(title: 'Terakhir diputar'),
              _songRow(lib.recent, 'Terakhir diputar'),
            ],
            const SectionHeader(title: 'Playlist pilihan untukmu'),
            _playlistRow(sections),
            SectionHeader(
              title: 'Lagu populer',
              actionLabel: 'Lihat semua',
              onAction: () => _openCurated(first),
            ),
            _popularList(first),
            for (final p in rest) ...[
              SectionHeader(
                title: p.title,
                actionLabel: 'Lihat semua',
                onAction: () => _openCurated(p),
              ),
              _sectionRow(p),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGreeting(LibraryService lib, HomeService home) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(),
                    style: const TextStyle(fontSize: 14, color: kTextGrey)),
                Text(
                  lib.profileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: kTextDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: home.reload,
            icon: const Icon(Icons.refresh_rounded, color: kTextGrey),
          ),
        ],
      ),
    );
  }

  /// Kotak pintasan 2 kolom (3 kolom di layar lebar) di bagian atas
  Widget _buildQuickAccess(LibraryService lib, List<CuratedPlaylist> curated) {
    final items = <_QuickItem>[
      _QuickItem(
        title: 'Lagu Favorit',
        leading: const GradientCover(
          colors: [Color(0xFF7C4DFF), Color(0xFFEC407A)],
          size: 56,
          radius: 0,
          icon: Icons.favorite_rounded,
        ),
        onTap: () => AppNav.tab.value = 1,
      ),
      for (final p in lib.playlists.take(2))
        _QuickItem(
          title: p.name,
          leading: PlaylistCover(playlist: p, size: 56, square: true),
          onTap: () => _openUserPlaylist(p),
        ),
    ];
    for (final c in curated) {
      if (items.length >= 6) break;
      items.add(_QuickItem(
        title: c.title,
        leading: GradientCover(
          colors: c.colors,
          imageUrl: c.coverUrl,
          size: 56,
          radius: 0,
        ),
        onTap: () => _openCurated(c),
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth > 700 ? 3 : 2;
          final w = (c.maxWidth - 12 * (cols - 1)) / cols;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final item in items)
                SizedBox(width: w, height: 56, child: _QuickTile(item: item)),
            ],
          );
        },
      ),
    );
  }

  Widget _songRow(List<Song> songs, String label) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => CoverCard(
          imageUrl: songs[i].artworkLarge,
          title: songs[i].title,
          subtitle: songs[i].artist,
          onTap: () => _play(songs, i, label),
        ),
      ),
    );
  }

  Widget _playlistRow(List<CuratedPlaylist> sections) {
    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final p = sections[i];
          return CoverCard(
            size: 160,
            imageUrl: p.coverUrl,
            colors: p.colors,
            title: p.title,
            subtitle: p.subtitle,
            showPlay: false,
            onTap: () => _openCurated(p),
          );
        },
      ),
    );
  }

  Widget _popularList(CuratedPlaylist p) {
    if (p.songs.isEmpty) return _placeholderFor(p, vertical: true);

    final songs = p.songs.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (var i = 0; i < songs.length; i++)
            SongTile(
              song: songs[i],
              onTap: () => _play(p.songs, i, p.title),
            ),
        ],
      ),
    );
  }

  Widget _sectionRow(CuratedPlaylist p) {
    if (p.songs.isEmpty) return _placeholderFor(p);
    return _songRow(p.songs, p.title);
  }

  /// Tampilan sementara: kerangka saat memuat, tombol coba lagi saat gagal
  Widget _placeholderFor(CuratedPlaylist p, {bool vertical = false}) {
    if (p.loading) {
      if (vertical) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              for (var i = 0; i < 4; i++)
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: PulseBox(height: 54, radius: 12),
                ),
            ],
          ),
        );
      }
      return SizedBox(
        height: 190,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            for (var i = 0; i < 4; i++)
              const Padding(
                padding: EdgeInsets.only(right: 14),
                child: PulseBox(width: 140, height: 140, radius: 18),
              ),
          ],
        ),
      );
    }
    if (p.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Text('Gagal memuat', style: TextStyle(color: kTextGrey)),
            TextButton(
              onPressed: () => HomeService.instance.retry(p),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _QuickItem {
  final String title;
  final Widget leading;
  final VoidCallback onTap;
  _QuickItem({required this.title, required this.leading, required this.onTap});
}

class _QuickTile extends StatelessWidget {
  final _QuickItem item;
  const _QuickTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSoftBg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: Row(
          children: [
            item.leading,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}