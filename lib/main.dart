import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'pages/home_shell.dart';
import 'services/library_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muat favorit, playlist, dan profil yang tersimpan sebelum aplikasi tampil
  await LibraryService.instance.init();
  runApp(const MusicApp());
}

/// Di Windows/desktop, daftar horizontal (baris cover di Beranda) harus bisa
/// digeser dengan mouse. Tanpa ini, hanya sentuhan yang bisa menggeser.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeShell(),
    );
  }
}