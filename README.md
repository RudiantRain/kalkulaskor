# KalkulaSkor

Aplikasi Android untuk mencatat skor segala jenis permainan secara konsekutif
dan otomatis — dirancang untuk permainan kartu yang skornya diakumulasi tiap
babak sampai ada yang menyentuh target.

Dibuat oleh GPR E8/11 untuk mendukung kegiatan remian bapak-bapak GPR RT 02, Kedanyang, Gresik, Jawa Timur, Indonesia

---

## Fitur

### Pencatatan skor

- **2 sampai 4 pemain**, jumlah kolom mengikuti pengaturan.
- **Nama pemain bisa diubah** — ketuk kartu nama di bagian atas (maks. 6
  karakter agar muat di kolom).
- **Input satu babak sekaligus** — skor semua pemain diisi dalam satu form,
  lalu dijumlahkan otomatis ke total berjalan.
- **Validasi kelipatan** — skor yang bukan kelipatan yang ditentukan ditolak
  dengan pesan, form tetap terbuka agar bisa diperbaiki.
- **Koreksi salah input** — tombol riwayat menghapus baris skor terakhir
  dengan konfirmasi.
- **Penanda pemain terbawah** pada tiap babak, ditandai warna dan ikon.

### Aturan permainan yang bisa diatur

Form pengaturan muncul saat memulai pencatatan baru, dan aturannya tersimpan
bersama permainan.

| Pengaturan | Rentang | Default |
|---|---|---|
| Jumlah kolom (pemain) | 2 – 4 | 4 |
| Kelipatan skor | 1 – 1000 | 5 |
| Target skor (selesai) | 10 – 9999, tidak boleh kurang dari kelipatan | 500 |

Form ini muncul di tiga titik: saat pertama kali memakai aplikasi, setelah
permainan selesai dan dimulai ulang, serta dari menu **Mulai Ulang**. Kalau
sudah ada permainan tersimpan, form **tidak** muncul — aplikasi langsung
melanjutkan pencatatan yang sedang berjalan.

### Akhir permainan

- **Deteksi selesai otomatis** saat ada pemain menyentuh target skor
  (menang) atau target negatifnya (kalah).
- **Grafik garis naik-turunnya skor** — 2 sampai 4 garis, satu per pemain,
  menampilkan perkembangan tiap babak beserta skor akhirnya.
- **Notifikasi pemain yang sedang unggul** setiap kali skor ditambahkan.

### Penyimpanan

- Nama pemain, seluruh riwayat skor, dan aturan permainan **tersimpan
  otomatis** di perangkat.
- Aplikasi ditutup lalu dibuka lagi akan menawarkan **melanjutkan atau
  memulai ulang** permainan sebelumnya.

### Tampilan

- **Tema terang dan gelap**, pilihan tersimpan dan dipakai lagi saat aplikasi
  dibuka berikutnya.
- **Tutorial singkat** yang menyorot bagian-bagian utama layar, bisa dipanggil
  ulang kapan saja dari menu.

---

## Alur pemakaian

1. Buka aplikasi → **Mulai Sekarang**.
2. Isi form aturan: jumlah pemain, kelipatan skor, target skor.
3. Ketuk kartu nama untuk mengganti nama tiap pemain.
4. Selesai satu babak → **+ Tambah Skor** → isi skor semua pemain → **Simpan**.
5. Ulangi sampai ada yang menyentuh target. Grafik dan hasil akhir muncul
   otomatis.

---

## Arsitektur

Pola MVVM dengan GetX, dipisah per modul:

```
lib/
├── app/
│   ├── data/models/          # GameSettings (aturan + validasi + penyimpanan)
│   ├── modules/
│   │   ├── dashboard/
│   │   │   ├── bindings/     # dependency injection per rute
│   │   │   ├── controllers/  # seluruh state & logika permainan
│   │   │   └── views/
│   │   │       └── widgets/  # tiap dialog & grafik jadi widget sendiri
│   │   └── splash/
│   └── routes/               # definisi rute terpusat
└── shared/
    ├── controllers/          # ThemeController
    ├── helper/               # utilitas skor
    ├── theme/                # AppTheme + palet warna grafik
    └── widgets/
```

Prinsip yang dipegang: **View tidak menyimpan state** dan tidak memanggil
navigasi langsung — semuanya lewat controller. Tiap dialog adalah widget
terpisah, bukan fungsi yang membangun `AlertDialog` di dalam controller.

---

## Teknologi

| | |
|---|---|
| Framework | Flutter (Dart SDK `^3.12.2`) |
| State management & rute | [`get`](https://pub.dev/packages/get) 4.6.6 |
| Penyimpanan lokal | [`get_storage`](https://pub.dev/packages/get_storage) 2.1.1 |
| Tutorial in-app | [`showcaseview`](https://pub.dev/packages/showcaseview) ^5.1.0 |
| Ikon launcher | [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) ^0.14.4 |

Grafik skor digambar langsung dengan `CustomPainter` tanpa paket chart
tambahan. Warna garisnya memakai palet kategorikal terpisah untuk tema terang
dan gelap, yang sudah diuji keterbacaannya termasuk untuk penglihatan buta
warna — lihat catatan di [`chart_palette.dart`](lib/shared/theme/chart_palette.dart).

---

## Menjalankan

```bash
flutter pub get
flutter run
```

## Build APK rilis

```bash
flutter build apk --release
```

Hasilnya di `build/app/outputs/flutter-apk/app-release.apk`.

Build akan mencetak kunci mana yang dipakai:

```
KalkulaSkor: release build is signed with the RELEASE keystore.
```

Kalau muncul peringatan `signed with the DEBUG key`, artinya
`android/key.properties` belum ada — APK-nya tetap bisa diinstal manual, tapi
**tidak bisa diunggah ke Play Store**.

## Screenshot
<img src='https://github.com/RudiantRain/kalkulaskor/blob/main/assets/WhatsApp%20Image%202026-08-15%20at%2021.02.07.jpeg'><img src='https://github.com/RudiantRain/kalkulaskor/blob/main/assets/WhatsApp%20Image%202026-08-15%20at%2021.02.08.jpeg'>
<img src='https://github.com/RudiantRain/kalkulaskor/blob/main/assets/WhatsApp%20Image%202026-08-15%20at%2021.02.08%20(2).jpeg'><img src='https://github.com/RudiantRain/kalkulaskor/blob/main/assets/WhatsApp%20Image%202026-08-15%20at%2021.02.08%20(1).jpeg'>
