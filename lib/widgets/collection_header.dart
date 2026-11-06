import 'package:flutter/material.dart';

/// Header besar bergradasi untuk halaman isi playlist: cover di tengah,
/// judul yang mengecil saat di-scroll. Dipakai sebagai sliver.
class CollectionHeader extends StatelessWidget {
  final Widget cover;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final List<Widget> actions;

  const CollectionHeader({
    super.key,
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 330,
      backgroundColor: colors.first,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        collapseMode: CollapseMode.parallax,
        titlePadding: const EdgeInsets.only(bottom: 16, left: 56, right: 56),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 78),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: cover,
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}