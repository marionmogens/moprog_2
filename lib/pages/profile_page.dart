import 'package:flutter/material.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';
import '../utils/helpers.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/queue_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _edit(BuildContext context) async {
    final lib = LibraryService.instance;
    final controller = TextEditingController(text: lib.profileName);
    var colorIndex = lib.avatarColorIndex;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                maxLength: 24,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              const Text('Warna avatar', style: TextStyle(color: kTextGrey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < LibraryService.avatarColors.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => colorIndex = i),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: LibraryService.avatarColors[i],
                        child: colorIndex == i
                            ? const Icon(Icons.check,
                            size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                lib.setProfile(
                  name: name.isEmpty ? lib.profileName : name,
                  colorIndex: colorIndex,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lib = LibraryService.instance;
    final player = PlayerService.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([lib, player]),
      builder: (context, _) {
        final color = LibraryService.avatarColors[
        lib.avatarColorIndex % LibraryService.avatarColors.length];

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Banner warna + avatar yang menimpa tepi bawahnya
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 170,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withValues(alpha: 0.5)],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(36)),
                      ),
                    ),
                    const Positioned(
                      bottom: -54,
                      child: ProfileAvatar(size: 108, ring: true),
                    ),
                  ],
                ),
                const SizedBox(height: 66),
                Center(
                  child: Text(
                    lib.profileName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: kTextDark,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Center(
                  child: Text('Pecinta musik',
                      style: TextStyle(color: kTextGrey)),
                ),
                const SizedBox(height: 14),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _edit(context),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit profil'),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: cardDecoration(radius: 24),
                    child: Row(
                      children: [
                        _Stat(
                          icon: Icons.favorite_rounded,
                          value: lib.favorites.length,
                          label: 'Favorit',
                          color: Colors.redAccent,
                        ),
                        const _VDivider(),
                        _Stat(
                          icon: Icons.queue_music_rounded,
                          value: lib.playlists.length,
                          label: 'Playlist',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const _VDivider(),
                        _Stat(
                          icon: Icons.headphones_rounded,
                          value: lib.playCount,
                          label: 'Diputar',
                          color: const Color(0xFF26A69A),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 28, 20, 10),
                  child: Text(
                    'PUSTAKA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: kTextGrey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: cardDecoration(radius: 24),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _ActionRow(
                          icon: Icons.queue_music_rounded,
                          title: 'Antrian lagu',
                          subtitle: player.queue.isEmpty
                              ? 'Antrian kosong'
                              : '${player.queue.length} lagu menunggu',
                          onTap: () => showQueueSheet(context),
                        ),
                        const Divider(height: 1, indent: 70, color: kBorder),
                        _ActionRow(
                          icon: Icons.heart_broken_rounded,
                          title: 'Hapus semua favorit',
                          subtitle: 'Mengosongkan daftar favorit',
                          danger: true,
                          onTap: () async {
                            final ok = await confirmDialog(
                              context,
                              title: 'Hapus semua favorit?',
                              message:
                              'Semua lagu di daftar favorit akan dihapus.',
                            );
                            if (ok) lib.clearFavorites();
                          },
                        ),
                        const Divider(height: 1, indent: 70, color: kBorder),
                        _ActionRow(
                          icon: Icons.restart_alt_rounded,
                          title: 'Reset semua data',
                          subtitle: 'Hapus favorit, playlist, dan statistik',
                          danger: true,
                          onTap: () async {
                            final ok = await confirmDialog(
                              context,
                              title: 'Reset semua data?',
                              message: 'Favorit, playlist, riwayat, dan '
                                  'statistik akan dihapus permanen.',
                              confirmLabel: 'Reset',
                            );
                            if (ok) {
                              lib.resetAll();
                              player.clearQueue();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kTextDark,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 52, color: kBorder);
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = danger ? Colors.redAccent : cs.primary;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: danger ? Colors.redAccent : kTextDark,
                      ),
                    ),
                    Text(subtitle,
                        style:
                        const TextStyle(fontSize: 12, color: kTextGrey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}