import 'song.dart';

class Playlist {
  final String id;
  String name;
  final List<Song> songs;

  Playlist({required this.id, required this.name, List<Song>? songs})
      : songs = songs ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'songs': songs.map((s) => s.toMap()).toList(),
  };

  factory Playlist.fromMap(Map<String, dynamic> m) => Playlist(
    id: m['id'] ?? '',
    name: m['name'] ?? 'Playlist',
    songs: (m['songs'] as List? ?? [])
        .map((e) => Song.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}