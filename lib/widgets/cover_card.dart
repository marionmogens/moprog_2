import 'package:flutter/material.dart';
import '../utils/helpers.dart';

/// Kotak cover bergradasi. Kalau ada gambar, gambar menutup gradasi
/// (gradasi tetap terlihat selama gambar belum selesai dimuat).
class GradientCover extends StatelessWidget {
  final List<Color> colors;
  final String? imageUrl;
  final double size;
  final double radius;
  final IconData icon;

  const GradientCover({
    super.key,
    required this.colors,
    this.imageUrl,
    required this.size,
    this.radius = 18,
    this.icon = Icons.music_note_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
            ),
            Center(
              child: Icon(icon,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: size * 0.35),
            ),
            if (url != null && url.isNotEmpty)
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Kartu kotak dengan cover besar, judul, dan subjudul (untuk baris horizontal)
class CoverCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double size;
  final List<Color> colors;
  final bool showPlay;

  const CoverCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
    this.size = 140,
    this.colors = const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
    this.showPlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: GradientCover(
                      colors: colors,
                      imageUrl: imageUrl,
                      size: size,
                    ),
                  ),
                  if (showPlay)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}