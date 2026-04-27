// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';

// Kelas untuk mendefinisikan tema aplikasi
class AppTheme {
  // Definisi warna utama aplikasi
  static const Color primaryColor = Color(0xFFFFEB3B); // Kuning Terang
  static const Color secondaryColor = Color(0xFFFBC02D); // Kuning Emas
  static const Color accentColor = Color(0xFFFF9800); // Oranye

  // Getter untuk mendapatkan tema terang aplikasi
  static ThemeData get lightTheme {
    return ThemeData(
      // Mengatur kecerahan tema menjadi terang
      brightness: Brightness.light,
      // Mengatur warna utama aplikasi
      primaryColor: primaryColor,
      // Mengatur warna latar belakang scaffold
      scaffoldBackgroundColor: Colors.white,
      // Mengatur font default aplikasi
      fontFamily: 'Roboto',
      // Mengatur skema warna aplikasi
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color.fromARGB(255, 175, 111, 0),
        onPrimary: Colors.black,
        secondary: secondaryColor,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      // Mengatur tema untuk AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      // Mengatur tema untuk Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
      ),
      // Mengatur tema untuk Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
