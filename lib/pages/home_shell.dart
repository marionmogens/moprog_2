import 'package:flutter/material.dart';
import '../utils/app_nav.dart';
import '../utils/helpers.dart';
import '../widgets/mini_player.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'playlists_page.dart';
import 'profile_page.dart';

/// Kerangka utama: 4 tab + pemutar mini di atas navigasi bawah
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _pages = <Widget>[
    HomePage(),
    FavoritesPage(),
    PlaylistsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<int>(
      valueListenable: AppNav.tab,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          // Di layar lebar, isi dibatasi 1000px dan diletakkan di tengah.
          // IndexedStack menjaga isi tiap tab saat pindah tab.
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: IndexedStack(index: index, children: _pages),
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: kBorder)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: const MiniPlayer(),
                  ),
                ),
                NavigationBarTheme(
                  data: NavigationBarThemeData(
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: 12,
                        fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? cs.primary : kTextGrey,
                      );
                    }),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        color: selected ? cs.primary : kTextGrey,
                      );
                    }),
                  ),
                  child: NavigationBar(
                    height: 68,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    indicatorColor: cs.primary.withValues(alpha: 0.12),
                    labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                    selectedIndex: index,
                    onDestinationSelected: (i) => AppNav.tab.value = i,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: 'Beranda',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.favorite_border_rounded),
                        selectedIcon: Icon(Icons.favorite_rounded),
                        label: 'Favorit',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.library_music_outlined),
                        selectedIcon: Icon(Icons.library_music_rounded),
                        label: 'Playlist',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline_rounded),
                        selectedIcon: Icon(Icons.person_rounded),
                        label: 'Profil',
                      ),
                    ],
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