// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';
// Import file tema aplikasi
import 'package:data_guru1/theme.dart';
// Import enum untuk rute navigasi
import 'package:data_guru1/enums/routes.dart';

// Kelas untuk halaman utama aplikasi
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Widget untuk membuat kartu menu dengan ikon, label, dan rute navigasi
  Widget _buildMenuCard(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return Card(
      elevation: 4, // Tinggi bayangan kartu
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Bentuk kartu dengan sudut melengkung
      margin: const EdgeInsets.all(7), // Margin di sekitar kartu
      child: InkWell(
        borderRadius: BorderRadius.circular(16), // Bentuk efek splash saat ditekan
        onTap: () {
          // Navigasi ke halaman yang sesuai saat kartu ditekan
          Navigator.pushNamed(context, route);
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16), // Padding di dalam kartu
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ukuran kolom minimal
              children: [
                Icon(icon, size: 48, color: AppTheme.accentColor), // Ikon menu dengan warna aksen
                const SizedBox(height: 12), // Jarak antara ikon dan teks
                Text(
                  label, // Label menu
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Gaya teks label
                  textAlign: TextAlign.center, // Perataan teks ke tengah
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // Method untuk membangun UI halaman utama
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Data Bimble')), // Judul aplikasi di app bar
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800), // Batasi lebar maksimum konten
          child: GridView.count(
            padding: const EdgeInsets.all(16), // Padding di sekitar grid
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4, // Jumlah kolom berdasarkan lebar layar
            crossAxisSpacing: 12, // Jarak antar kolom
            mainAxisSpacing: 12, // Jarak antar baris
            shrinkWrap: true, // Menyesuaikan ukuran grid dengan konten
            children: [
              // Daftar menu aplikasi dengan ikon dan rute masing-masing
              _buildMenuCard(context, icon: Icons.person_add, label: 'Pendaftaran Murid', route: Routes.daftar_murid.path),
              _buildMenuCard(context, icon: Icons.school, label: 'Data Guru', route: Routes.guru.path),
              _buildMenuCard(context, icon: Icons.person, label: 'Data Murid', route: Routes.murid.path),
              _buildMenuCard(context, icon: Icons.calendar_today, label: 'Jadwal', route: Routes.jadwal.path),
              _buildMenuCard(context, icon: Icons.check_circle, label: 'Hasil', route: Routes.hasil.path),
            ],
          ),
        ),
      ),
    );
  }
}