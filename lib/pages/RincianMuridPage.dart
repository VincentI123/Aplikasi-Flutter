import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class RincianMuridPage extends StatelessWidget {
  final Map<String, dynamic> murid;

  // Constructor untuk menerima data murid
  const RincianMuridPage({super.key, required this.murid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rincian Murid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama: ${murid['name']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Tampilkan tabel rincian data
            DetailTable(
              details: {
                'Tingkatan': murid['tingkatan'] ?? '-',
                'Sekolah': murid['sekolah'] ?? '-',
                'Mata Pelajaran': murid['mata_pelajaran'] ?? '-',
                'Tempat Lahir': murid['tempat_lahir'] ?? '-',
                'Tanggal Lahir': murid['tanggal_lahir'] ?? '-',
                'Nama Orang Tua/Wali': murid['nama_orangtua'] ?? '-',
                'No HP Orang Tua/Wali': murid['no_hp_orangtua'] ?? '-',
              },
            ),
            // Tambahkan informasi lainnya jika diperlukan
          ],
        ),
      ),
    );
  }
}
