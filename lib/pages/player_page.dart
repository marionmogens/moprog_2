import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';
import '../utils/helpers.dart';
import '../widgets/playlist_sheet.dart';
import '../widgets/queue_sheet.dart';

/// Membuka halaman pemutar dengan animasi naik dari bawah
void openPlayerPage(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const PlayerPage(),
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ));
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final _player = PlayerService.instance;
  final _lib = LibraryService.instance;
  double? _drag; // nilai slider saat digeser

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: Listenable.merge([_player, _lib]),
        builder: (context, _) {
          final song = _player.current;
          if (song == null) return const SizedBox.shrink();

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background: cover di-blur lalu ditimpa putih supaya pastel
              Image.network(
                song.artworkLarge,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.white),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  // Di layar lebar konten dibatasi 480px dan di tengah
                  padding: EdgeInsets.symmetric(
                    horizontal: math.max(
                        24, (MediaQuery.of(context).size.width - 480) / 2),
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      Expanded(
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final size = math.max(
                                  0.0,
                                  math.min(
                                      math.min(c.maxWidth, c.maxHeight), 340.0));
                              return _buildArtwork(song.artworkLarge, size);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(context, song),
                      const SizedBox(height: 12),
                      _buildPlayerCard(context, cs),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 32, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SEDANG DIPUTAR',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: kTextGrey,
                ),
              ),
              if (_player.contextLabel.isNotEmpty)
                Text(
                  _player.contextLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: kTextGrey),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Antrian lagu',
          onPressed: () => showQueueSheet(context),
          icon: Badge(
            label: Text('${_player.queue.length}'),
            isLabelVisible: _player.queue.isNotEmpty,
            child: const Icon(Icons.queue_music_rounded,
                size: 28, color: kTextDark),
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork(String url, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF1EFF7),
              child: const Icon(Icons.music_note, size: 80),
            ),
          ),
        ),
      ),
    );
  }

  /// Kartu putih: judul, artis, tombol favorit dan tambah ke playlist
  Widget _buildInfoCard(BuildContext context, Song song) {
    final isFav = _lib.isFavorite(song);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, color: kTextGrey),
                ),
                if (_player.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_player.error!,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
            onPressed: () => _lib.toggleFavorite(song),
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? Colors.redAccent : kTextDark,
            ),
          ),
          IconButton(
            tooltip: 'Tambah ke playlist',
            onPressed: () => showAddToPlaylistSheet(context, song),
            icon: const Icon(Icons.playlist_add_rounded, color: kTextDark),
          ),
        ],
      ),
    );
  }

  /// Kartu putih: slider, tombol kontrol, dan teks "Berikutnya"
  Widget _buildPlayerCard(BuildContext context, ColorScheme cs) {
    final next = _player.nextSong;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildProgress(cs),
          _buildControls(cs),
          if (next != null) ...[
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => showQueueSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.skip_next_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Berikutnya: ${next.title} • ${next.artist}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: kTextGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: kBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildProgress(ColorScheme cs) {
    final totalMs = math.max(_player.duration.inMilliseconds, 1).toDouble();

    return ValueListenableBuilder<Duration>(
      valueListenable: _player.position,
      builder: (context, pos, _) {
        final posMs = pos.inMilliseconds.toDouble().clamp(0, totalMs).toDouble();
        final value = _drag ?? posMs;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.primary.withValues(alpha: 0.15),
                thumbColor: cs.primary,
                overlayColor: cs.primary.withValues(alpha: 0.12),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                min: 0,
                max: totalMs,
                value: value,
                onChanged: (v) => setState(() => _drag = v),
                onChangeEnd: (v) async {
                  await _player.seek(Duration(milliseconds: v.toInt()));
                  if (mounted) setState(() => _drag = null);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(Duration(milliseconds: value.toInt())),
                      style: const TextStyle(color: kTextGrey, fontSize: 12)),
                  Text(formatDuration(_player.duration),
                      style: const TextStyle(color: kTextGrey, fontSize: 12)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 36,
          color: kTextDark,
          onPressed: _player.previous,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        const SizedBox(width: 12),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _player.loading
              ? const Padding(
            padding: EdgeInsets.all(22),
            child: CircularProgressIndicator(
                strokeWidth: 3, color: Colors.white),
          )
              : IconButton(
            iconSize: 38,
            color: Colors.white,
            onPressed: _player.togglePlay,
            icon: Icon(
              _player.isCompleted
                  ? Icons.replay_rounded
                  : _player.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          iconSize: 36,
          color: kTextDark,
          onPressed: _player.hasNext ? _player.next : null,
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}