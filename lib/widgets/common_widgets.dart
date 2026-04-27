// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';

// Widget untuk menampilkan data dalam format tabel detail
class DetailTable extends StatelessWidget {
  final Map<String, String> details; // Map berisi pasangan key-value untuk ditampilkan
  const DetailTable({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(), // Kolom pertama menyesuaikan dengan lebar konten
        1: FixedColumnWidth(8), // Kolom kedua dengan lebar tetap 8 pixel
        2: FlexColumnWidth(), // Kolom ketiga mengisi sisa ruang yang tersedia
      },
      children: details.entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0), // Padding vertikal pada teks
              child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Label dengan gaya tebal
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Tanda titik dua
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(entry.value, style: const TextStyle(fontSize: 14)), // Nilai dengan gaya normal
            ),
          ],
        );
      }).toList(),
    );
  }
}

// Widget untuk kotak pencarian yang dapat digunakan di berbagai halaman
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller; // Controller untuk mengelola input teks
  final String hintText; // Teks petunjuk yang ditampilkan saat kotak pencarian kosong
  final ValueChanged<String> onChanged; // Callback yang dipanggil saat teks berubah
  const SearchBarWidget({super.key, required this.controller, required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Menggunakan controller yang diberikan
      decoration: InputDecoration(
        hintText: hintText, // Teks petunjuk
        prefixIcon: const Icon(Icons.search), // Ikon pencarian di depan
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Border dengan sudut melengkung
      ),
      onChanged: onChanged, // Memanggil callback saat teks berubah
    );
  }
}