# Dokumentasi Aplikasi Data Bimble

## Deskripsi Aplikasi

Aplikasi Data Bimble adalah sistem manajemen data untuk lembaga bimbingan belajar yang memungkinkan pengelolaan data guru, murid, dan jadwal pembelajaran. Aplikasi ini dikembangkan menggunakan framework Flutter dengan database SQLite untuk penyimpanan data lokal.

## Fitur Utama

1. **Manajemen Data Guru**
   - Menambah, mengedit, dan menghapus data guru
   - Menyimpan informasi nama, mata pelajaran, status, waktu mengajar, jumlah murid, dan hari mengajar

2. **Manajemen Data Murid**
   - Pendaftaran murid baru
   - Mengedit dan menghapus data murid
   - Menyimpan informasi lengkap murid termasuk data pribadi, data orang tua, dan pilihan bimbingan

3. **Pengelolaan Jadwal**
   - Membuat jadwal pembelajaran
   - Filter jadwal berdasarkan hari dan waktu
   - Mengedit dan menghapus jadwal

4. **Tampilan Hasil**
   - Menampilkan hasil atau laporan terkait kegiatan bimbingan

## Struktur Aplikasi

### Model Data

1. **Model Guru**
   ```dart
   class Guru {
     final int? id;
     final String nama;
     final String mapel;
     final String status;
     final String waktu;
     final int jumlahMurid;
     final int hariMengajar;
     // ...
   }
   ```

2. **Model Murid**
   ```dart
   class Murid {
     final int? id;
     final String nama;
     final String alamat;
     final String noHp;
     final String tempatLahir;
     final String tanggalLahir;
     final String kelas;
     final String sekolah;
     final String namaOrangTua;
     final String noHpOrangTua;
     final List<String> pilihanBimbingan;
     // ...
   }
   ```

### Database

1. **DBProvider**
   - Implementasi singleton pattern untuk koneksi database
   - Membuat dan mengelola tabel untuk guru, murid, dan jadwal

2. **Repository**
   - Menyediakan metode CRUD (Create, Read, Update, Delete) untuk entitas guru, murid, dan jadwal
   - Menangani operasi database seperti query, insert, update, dan delete

### Halaman Utama

1. **HomePage**
   - Menampilkan menu utama aplikasi dengan kartu-kartu navigasi
   - Navigasi ke halaman Data Guru, Data Murid, Jadwal, dan Hasil

2. **DataGuruPage**
   - Menampilkan daftar guru dalam bentuk kartu
   - Opsi untuk menambah, mengedit, dan menghapus data guru

3. **DataMuridPage & DaftarMuridPage**
   - Menampilkan daftar murid dan formulir pendaftaran murid baru
   - Opsi untuk melihat detail, mengedit, dan menghapus data murid

4. **JadwalPage**
   - Menampilkan jadwal pembelajaran dalam bentuk tabel
   - Filter jadwal berdasarkan hari dan waktu
   - Opsi untuk menambah, mengedit, dan menghapus jadwal

5. **HasilPage**
   - Menampilkan hasil atau laporan terkait kegiatan bimbingan

## Alur Kerja Aplikasi

1. **Pendaftaran Murid**
   - Pengguna mengakses halaman Daftar Murid
   - Mengisi formulir dengan data murid dan orang tua
   - Memilih bimbingan yang diinginkan
   - Menyimpan data ke database

2. **Pengelolaan Guru**
   - Pengguna mengakses halaman Data Guru
   - Menambah guru baru dengan informasi lengkap
   - Mengedit atau menghapus data guru yang sudah ada

3. **Penjadwalan**
   - Pengguna mengakses halaman Jadwal
   - Membuat jadwal baru dengan memilih guru, hari, dan waktu
   - Mengedit atau menghapus jadwal yang sudah ada
   - Memfilter jadwal berdasarkan hari dan waktu

## Teknologi yang Digunakan

1. **Framework**: Flutter
2. **Bahasa Pemrograman**: Dart
3. **Database**: SQLite (sqflite)
4. **Dependensi Utama**:
   - sqflite: Untuk akses database SQLite
   - path: Untuk mengelola path file database
   - intl: Untuk format tanggal dan waktu
   - provider: Untuk state management
   - country_code_picker: Untuk pemilihan kode negara pada nomor telepon

## Cara Menjalankan Aplikasi

1. Pastikan Flutter SDK telah terinstal di komputer Anda
2. Clone repositori aplikasi
3. Jalankan perintah `flutter pub get` untuk mengunduh dependensi
4. Hubungkan perangkat atau jalankan emulator
5. Jalankan aplikasi dengan perintah `flutter run`

## Pengembangan Lebih Lanjut

Beberapa fitur yang dapat ditambahkan untuk pengembangan aplikasi di masa depan:

1. Autentikasi pengguna (login admin dan guru)
2. Sinkronisasi data dengan cloud database
3. Notifikasi untuk jadwal dan kegiatan penting
4. Fitur absensi murid dan guru
5. Laporan kemajuan belajar murid
6. Integrasi pembayaran untuk biaya bimbingan

---

Dokumentasi ini dibuat untuk memberikan pemahaman komprehensif tentang struktur dan fungsi Aplikasi Data Bimble. Untuk informasi lebih lanjut atau bantuan teknis, silakan hubungi pengembang aplikasi.