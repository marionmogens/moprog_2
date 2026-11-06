import 'package:flutter/material.dart';
import '../services/library_service.dart';

/// Avatar bulat berisi inisial nama dan warna pilihan user
class ProfileAvatar extends StatelessWidget {
  final double size;
  final bool ring;
  const ProfileAvatar({super.key, this.size = 44, this.ring = false});

  @override
  Widget build(BuildContext context) {
    final lib = LibraryService.instance;

    return ListenableBuilder(
      listenable: lib,
      builder: (context, _) {
        final color = LibraryService.avatarColors[
        lib.avatarColorIndex % LibraryService.avatarColors.length];
        final name = lib.profileName.trim();
        final initial = name.isEmpty ? '?' : name[0].toUpperCase();

        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: ring ? Border.all(color: Colors.white, width: 4) : null,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.65)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: size * 0.22,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}