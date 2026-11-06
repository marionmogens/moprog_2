import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'library_service.dart';

/// Satu pemutar untuk seluruh aplikasi. Karena dipegang di sini (bukan di
/// halaman), lagu tetap jalan saat kamu pindah tab atau menutup halaman detail.
class PlayerService extends ChangeNotifier {
  PlayerService._();
  static final PlayerService instance = PlayerService._();

  // AudioPlayer dibuat saat pertama kali dibutuhkan saja
  AudioPlayer? _audio;
  AudioPlayer get _player {
    var a = _audio;
    if (a == null) {
      a = AudioPlayer();
      _audio = a;
      a.setReleaseMode(ReleaseMode.stop);
      a.onPlayerStateChanged.listen((s) {
        state = s;
        notifyListeners();
      });
      a.onPositionChanged.listen((p) => position.value = p);
      a.onDurationChanged.listen((d) {
        duration = d;
        notifyListeners();
      });
      a.onPlayerComplete.listen((_) {
        if (hasNext) next(); // otomatis lanjut ke lagu berikutnya
      });
    }
    return a;
  }

  // ───── data yang dibaca UI ─────

  Song? current;
  PlayerState state = PlayerState.stopped;
  Duration duration = const Duration(seconds: 30); // preview = 30 detik
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  bool loading = false;
  String? error;

  /// Antrian yang ditambahkan user (diputar lebih dulu dari daftar biasa)
  final List<Song> queue = [];

  /// Nama daftar asal lagu, misalnya "Favorit" atau nama playlist
  String contextLabel = '';

  List<Song> _context = [];
  int _contextIndex = -1;
  bool _playingFromQueue = false;

  bool get isPlaying => state == PlayerState.playing;
  bool get isCompleted => state == PlayerState.completed;

  bool get hasNext =>
      queue.isNotEmpty ||
          (_context.isNotEmpty && _contextIndex + 1 < _context.length);

  bool get hasPrevious => _playingFromQueue
      ? _context.isNotEmpty && _contextIndex >= 0
      : _contextIndex > 0;

  /// Sisa lagu di daftar asal setelah lagu yang sedang diputar
  List<Song> get upcomingContext {
    if (_context.isEmpty ||
        _contextIndex < 0 ||
        _contextIndex + 1 >= _context.length) {
      return const [];
    }
    return _context.sublist(_contextIndex + 1);
  }

  /// Lagu yang akan diputar berikutnya (untuk teks "Berikutnya")
  Song? get nextSong {
    if (queue.isNotEmpty) return queue.first;
    if (_context.isNotEmpty && _contextIndex + 1 < _context.length) {
      return _context[_contextIndex + 1];
    }
    return null;
  }

  // ───── memutar ─────

  /// Putar lagu ke-[index] dari [list]; sisanya jadi lagu berikutnya.
  Future<void> playFrom(List<Song> list, int index, {String label = ''}) async {
    if (list.isEmpty || index < 0 || index >= list.length) return;
    _context = List<Song>.of(list);
    _contextIndex = index;
    contextLabel = label;
    _playingFromQueue = false;
    await _start(_context[index]);
  }

  Future<void> _start(Song song) async {
    current = song;
    error = null;
    loading = true;
    position.value = Duration.zero;
    duration = const Duration(seconds: 30);
    notifyListeners();
    try {
      await _player.stop();
      await _player.play(UrlSource(song.previewUrl));
      LibraryService.instance.registerPlay(song);
    } catch (e) {
      debugPrint('Audio error: $e');
      error = 'Gagal memutar lagu ini';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    final song = current;
    if (song == null) return;
    if (state == PlayerState.completed || state == PlayerState.stopped) {
      await _start(song);
    } else if (state == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> seek(Duration d) async {
    await _player.seek(d);
    position.value = d;
  }

  Future<void> next() async {
    if (queue.isNotEmpty) {
      final s = queue.removeAt(0);
      _playingFromQueue = true;
      await _start(s);
      return;
    }
    if (_context.isNotEmpty && _contextIndex + 1 < _context.length) {
      _contextIndex++;
      _playingFromQueue = false;
      await _start(_context[_contextIndex]);
    }
  }

  Future<void> previous() async {
    final song = current;
    if (song == null) return;
    // Kalau sudah lewat 3 detik atau tidak ada lagu sebelumnya: ulangi lagu ini
    if (position.value.inSeconds > 3 || !hasPrevious) {
      await _start(song);
      return;
    }
    if (_playingFromQueue) {
      _playingFromQueue = false;
      await _start(_context[_contextIndex]);
    } else {
      _contextIndex--;
      await _start(_context[_contextIndex]);
    }
  }

  /// Loncat ke lagu ke-[i] dari daftar "selanjutnya"
  Future<void> jumpToUpcoming(int i) async {
    final target = _contextIndex + 1 + i;
    if (target < 0 || target >= _context.length) return;
    _contextIndex = target;
    _playingFromQueue = false;
    await _start(_context[target]);
  }

  // ───── antrian ─────

  /// Tambah ke akhir antrian. Mengembalikan pesan untuk ditampilkan.
  String enqueue(Song s) {
    if (current == null) {
      playFrom([s], 0);
      return 'Memutar "${s.title}"';
    }
    if (queue.contains(s)) return 'Lagu sudah ada di antrian';
    queue.add(s);
    notifyListeners();
    return 'Ditambahkan ke antrian';
  }

  /// Taruh di urutan paling depan antrian.
  String enqueueNext(Song s) {
    if (current == null) {
      playFrom([s], 0);
      return 'Memutar "${s.title}"';
    }
    queue.remove(s);
    queue.insert(0, s);
    notifyListeners();
    return 'Akan diputar berikutnya';
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= queue.length) return;
    queue.removeAt(index);
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final s = queue.removeAt(oldIndex);
    queue.insert(newIndex, s);
    notifyListeners();
  }

  void clearQueue() {
    queue.clear();
    notifyListeners();
  }
}