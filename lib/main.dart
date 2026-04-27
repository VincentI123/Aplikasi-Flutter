// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';
// Import file tema aplikasi
import 'theme.dart';
// Import halaman-halaman aplikasi
import 'pages/daftar_murid.dart';
import 'pages/data_guru.dart';
import 'pages/data_murid.dart';
import 'pages/jadwal_page.dart';
import 'pages/hasil_page.dart';
import 'pages/home_page.dart';
// Import enum untuk rute navigasi
import 'enums/routes.dart';

// Fungsi utama sebagai titik masuk aplikasi
void main() {
  // Menjalankan aplikasi Flutter dengan widget MyApp sebagai root
  runApp(const MyApp());
}

// Kelas utama aplikasi yang mewarisi StatelessWidget
class MyApp extends StatelessWidget {
  // Constructor dengan parameter key yang diteruskan ke kelas induk
  const MyApp({super.key});

  @override
  // Method untuk membangun UI aplikasi
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi yang muncul di task manager
      title: 'Aplikasi Data Sekolah',
      // Menghilangkan banner debug di pojok kanan atas
      debugShowCheckedModeBanner: false,
      // Menggunakan tema terang yang didefinisikan di file theme.dart
      theme: AppTheme.lightTheme,
      // Rute awal saat aplikasi dibuka
      initialRoute: '/',
      // Mendefinisikan semua rute navigasi dalam aplikasi
      routes: {
        '/': (context) => const HomePage(), // Halaman utama
        Routes.daftar_murid.path: (context) => const DaftarMuridPage(), // Halaman pendaftaran murid
        Routes.guru.path: (context) => const DataGuruPage(), // Halaman data guru
        Routes.murid.path: (context) => const DataMuridPage(), // Halaman data murid
        Routes.jadwal.path: (context) => const JadwalPage(), // Halaman jadwal
        Routes.hasil.path: (context) => const HasilPage(), // Halaman hasil
      },
    );
  }
}

