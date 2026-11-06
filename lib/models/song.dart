class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String year;
  final String previewUrl;
  final String artwork; // cover kecil (untuk daftar)
  final String artworkBig; // cover besar (untuk halaman detail)

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.year,
    required this.previewUrl,
    required this.artwork,
    required this.artworkBig,
  });

  /// Dari API iTunes
  factory Song.fromItunes(Map<String, dynamic> j) {
    final date = (j['releaseDate'] ?? '') as String;
    final small = (j['artworkUrl100'] ?? '') as String;
    return Song(
      id: j['trackId'] ?? 0,
      title: j['trackName'] ?? '-',
      artist: j['artistName'] ?? '-',
      album: j['collectionName'] ?? '-',
      genre: j['primaryGenreName'] ?? '-',
      year: date.length >= 4 ? date.substring(0, 4) : '-',
      previewUrl: j['previewUrl'] ?? '',
      artwork: small,
      artworkBig: small.replaceAll('100x100', '600x600'),
    );
  }

  /// Dari API Deezer (cadangan kalau iTunes menolak request)
  factory Song.fromDeezer(Map<String, dynamic> j) {
    final album = (j['album'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final artist = (j['artist'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final medium = (album['cover_medium'] ?? '') as String;
    return Song(
      id: j['id'] ?? 0,
      title: j['title'] ?? '-',
      artist: artist['name'] ?? '-',
      album: album['title'] ?? '-',
      genre: '-', // Deezer tidak memberi genre di hasil pencarian
      year: '-',
      previewUrl: j['preview'] ?? '',
      artwork: medium,
      artworkBig: (album['cover_big'] ?? medium) as String,
    );
  }

  /// Untuk disimpan ke penyimpanan lokal (favorit & playlist)
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'genre': genre,
    'year': year,
    'previewUrl': previewUrl,
    'artwork': artwork,
    'artworkBig': artworkBig,
  };

  factory Song.fromMap(Map<String, dynamic> m) => Song(
    id: m['id'] ?? 0,
    title: m['title'] ?? '-',
    artist: m['artist'] ?? '-',
    album: m['album'] ?? '-',
    genre: m['genre'] ?? '-',
    year: m['year'] ?? '-',
    previewUrl: m['previewUrl'] ?? '',
    artwork: m['artwork'] ?? '',
    artworkBig: m['artworkBig'] ?? '',
  );

  String get artworkSmall => artwork;
  String get artworkLarge => artworkBig;

  // Dua lagu dianggap sama kalau id-nya sama
  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}