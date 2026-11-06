# Music Player

Aplikasi pemutar musik sederhana berbasis Flutter. Cari lagu, putar preview 30 detik, simpan ke favorit dan playlist, atur antrian lagu, dan kelola profilmu, dengan tampilan terang yang terinspirasi Spotify.

> Proyek ini dibuat untuk tugas kuliah (`pertemuan_11b`). Lagu diambil dari API publik, jadi yang diputar adalah **preview 30 detik**, bukan lagu penuh.

## Fitur

**Beranda**
- Search bar di paling atas untuk mencari lagu, artis, atau album
- Sapaan sesuai jam (pagi, siang, sore, malam) dengan nama profilmu
- Kotak pintasan ke Lagu Favorit, playlist buatanmu, dan playlist pilihan
- Baris **Terakhir diputar** yang terisi otomatis dari riwayat putarmu
- **Playlist pilihan** (Hits Populer, Pop Indonesia, Chill Vibes, Rock Klasik, Hip Hop, K-Pop) dan baris lagu per kategori
- Tombol "Simpan ke playlist saya" untuk menyalin playlist pilihan

**Pemutar**
- Putar, jeda, geser posisi lagu, lagu sebelumnya, dan lagu berikutnya
- Lanjut otomatis ke lagu berikutnya saat lagu selesai
- Pemutar mini di atas navigasi bawah, jadi lagu tetap jalan saat pindah tab
- Latar halaman pemutar mengikuti warna cover album (di-blur)

**Favorit**
- Tekan ikon hati di lagu mana pun, di daftar maupun di halaman pemutar
- Tombol "Putar semua" dan "Acak"

**Playlist**
- Buat, ganti nama, dan hapus playlist
- Tambah atau hapus lagu dari playlist lewat menu ⋮
- Tampilan grid dengan cover besar

**Antrian lagu**
- "Putar berikutnya" dan "Tambah ke antrian" dari menu ⋮ di tiap lagu
- Urutkan antrian dengan drag, hapus per lagu, atau kosongkan semuanya
- Menampilkan sisa lagu dari daftar asal dan bisa langsung loncat ke lagu tertentu

**Profil**
- Ubah nama dan warna avatar
- Statistik: jumlah favorit, playlist, dan lagu yang pernah diputar
- Reset data (hapus semua favorit atau seluruh data)

Favorit, playlist, riwayat, dan profil **tersimpan permanen** di perangkat. Antrian lagu tidak tersimpan setelah aplikasi ditutup.

## Teknologi

| Bagian | Yang dipakai |
|---|---|
| Framework | Flutter (Material 3), minimal versi 3.27 |
| Bahasa | Dart |
| Sumber lagu | iTunes Search API, dengan cadangan Deezer API |
| Pemutar audio | [`audioplayers`](https://pub.dev/packages/audioplayers) |
| Request HTTP | [`http`](https://pub.dev/packages/http) |
| Penyimpanan lokal | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| State management | `ChangeNotifier` bawaan Flutter (tanpa package tambahan) |

## Struktur folder

```
pertemuan_11b/
├── pubspec.yaml
├── README.md
├── test/
│   └── widget_test.dart
└── lib/
    ├── main.dart                     # pintu masuk, tema, memuat data tersimpan
    ├── models/
    │   ├── song.dart                 # data satu lagu
    │   └── playlist.dart             # data satu playlist
    ├── services/
    │   ├── itunes_service.dart       # cari lagu (iTunes, cadangan Deezer)
    │   ├── home_service.dart         # isi playlist pilihan di Beranda
    │   ├── library_service.dart      # favorit, playlist, riwayat, profil + simpan permanen
    │   └── player_service.dart       # pemutar audio + antrian lagu
    ├── utils/
    │   ├── app_nav.dart              # penanda tab yang aktif
    │   └── helpers.dart              # warna, dekorasi kartu, snackbar, dialog
    ├── pages/
    │   ├── home_shell.dart           # kerangka 4 tab + pemutar mini
    │   ├── home_page.dart            # tab Beranda + pencarian
    │   ├── favorites_page.dart       # tab Favorit
    │   ├── playlists_page.dart       # tab Playlist
    │   ├── profile_page.dart         # tab Profil
    │   ├── playlist_detail_page.dart # isi satu playlist buatan user
    │   ├── curated_page.dart         # isi satu playlist pilihan
    │   └── player_page.dart          # halaman pemutar penuh
    └── widgets/
        ├── song_tile.dart            # baris satu lagu
        ├── mini_player.dart          # pemutar kecil di bawah
        ├── queue_sheet.dart          # panel antrian
        ├── playlist_sheet.dart       # panel "Tambah ke playlist"
        ├── playlist_actions.dart     # dialog ganti nama dan hapus playlist
        ├── playlist_cover.dart       # cover playlist
        ├── play_all_buttons.dart     # tombol "Putar semua" dan "Acak"
        ├── cover_card.dart           # kartu cover untuk baris horizontal
        ├── collection_header.dart    # header besar halaman isi playlist
        ├── section_header.dart       # judul bagian di Beranda
        ├── page_header.dart          # judul besar di atas tab
        ├── profile_avatar.dart       # avatar inisial
        ├── pulse_box.dart            # placeholder saat memuat
        └── empty_state.dart          # tampilan saat daftar kosong
```

### Cara kerja singkat

```
main.dart → HomeShell (4 tab + MiniPlayer)
                │
   halaman & widget memakai:
   ├─ LibraryService   → favorit, playlist, riwayat, profil (disimpan ke perangkat)
   ├─ PlayerService    → satu pemutar audio untuk seluruh aplikasi + antrian
   ├─ HomeService      → isi playlist pilihan di Beranda
   └─ ItunesService    → pencarian (iTunes dulu, kalau gagal beralih ke Deezer)
```

Halaman dan widget hanya mengurus tampilan. Data dan logika ada di `services/`, jadi mengganti sumber lagu cukup mengubah `itunes_service.dart`.

## Cara menjalankan

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) versi 3.27 atau lebih baru
- Editor seperti Android Studio atau VS Code
- Untuk Windows: aktifkan **Developer Mode** (`start ms-settings:developers`), karena plugin Flutter membutuhkannya

### Langkah

```bash
# 1. Ambil dependencies
flutter pub get

# 2. Jalankan (pilih salah satu)
flutter run -d windows
flutter run -d chrome
flutter run            # perangkat atau emulator yang terhubung
```

Kalau memulai dari project kosong, tambahkan package dulu:

```bash
flutter pub add http audioplayers shared_preferences
```

### Android

Tambahkan izin internet di `android/app/src/main/AndroidManifest.xml`, di atas tag `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Tanpa izin ini aplikasi bisa jalan saat debug, tetapi gagal memuat data saat build release.

### Menjalankan tes

```bash
flutter test
```

Tes memakai data tiruan dan tidak memanggil internet.

## Catatan penting

- **Preview 30 detik.** iTunes dan Deezer hanya menyediakan potongan 30 detik per lagu lewat API publiknya. Untuk lagu penuh dibutuhkan layanan berlisensi.
- **Sumber cadangan.** iTunes membatasi jumlah request per alamat IP. Kalau menjawab `HTTP 403` atau `429`, aplikasi otomatis beralih ke Deezer. Hasil dari Deezer tidak punya genre dan tahun rilis.
- **Isi playlist pilihan dinamis.** Daftar lagunya diambil dari hasil pencarian saat aplikasi dibuka, jadi bisa berbeda dari waktu ke waktu dan butuh koneksi internet.
- **Geser dengan mouse.** Di desktop, baris cover horizontal di Beranda digeser dengan drag mouse atau Shift + scroll.
- **Tidak ada foto profil.** Avatar memakai inisial nama dengan pilihan warna. Foto profil membutuhkan package `image_picker`.

## Pemecahan masalah

| Masalah | Penyebab dan solusi |
|---|---|
| `HTTP 403` saat mencari | iTunes membatasi IP. Tunggu 1 sampai 2 menit, matikan VPN, atau coba jaringan lain. Aplikasi sudah otomatis memakai Deezer sebagai cadangan. |
| Hasil pencarian kosong dan muncul pesan gagal | Kedua sumber gagal. Periksa koneksi internet, firewall, atau antivirus yang memblokir aplikasi. |
| Lagu tidak bunyi | Stop aplikasi, jalankan `flutter clean`, lalu `flutter run` lagi (plugin audio perlu dibuild ulang). Cek juga volume aplikasi di Windows Volume Mixer. |
| `Target of URI doesn't exist` | File ada di folder yang salah. Cocokkan dengan bagan struktur folder di atas. |
| `withValues` tidak dikenali | Flutter lebih lama dari 3.27. Perbarui Flutter dengan `flutter upgrade`, atau ganti `.withValues(alpha: x)` menjadi `.withOpacity(x)`. |
| Build Windows gagal soal symlink | Aktifkan Developer Mode di pengaturan Windows. |
| Error `MyApp` di `widget_test.dart` | Itu file tes bawaan versi lama. Ganti isinya dengan `test/widget_test.dart` dari proyek ini. |

## Pengembangan lanjutan

Beberapa ide kalau proyek ingin dikembangkan:

- Simpan antrian lagu agar tidak hilang saat aplikasi ditutup
- Foto profil dengan `image_picker`
- Mode gelap
- Pencarian riwayat dan saran pencarian
- Mode ulang (repeat) dan acak (shuffle) di pemutar
- Pemutaran di latar belakang dan kontrol dari layar kunci

## Sumber data

- [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/)
- [Deezer API](https://developers.deezer.com/api)

Hak cipta lagu, cover, dan preview audio dimiliki oleh pemegang hak masing-masing. Proyek ini hanya untuk keperluan belajar.