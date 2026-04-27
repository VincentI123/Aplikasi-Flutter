import 'dart:developer';
import 'package:flutter/material.dart';
import '../database/repository.dart';

class Guru {
  final String name;
  final int status;
  final int jenisPelajaran;
  final int waktu;
  final int hari;
  final int kelas;
  final int jumlahAnak;

  Guru({
    required this.name,
    required this.status,
    required this.jenisPelajaran,
    required this.waktu,
    required this.hari,
    required this.kelas,
    required this.jumlahAnak,
  });
}

class Kriteria {
  final String name;
  final double weight;
  final bool isBenefit;
  Kriteria({required this.name, required this.weight, required this.isBenefit});
}

class HasilPage extends StatefulWidget {
  const HasilPage({super.key});
  @override
  _HasilPageState createState() => _HasilPageState();
}

class _HasilPageState extends State<HasilPage> {
  List<Guru> guruList = [];
  bool _isLoading = false;
  final Repository _repo = Repository();

  final Map<String, int> statusGuruMap = {'Part-time': 1, 'Full-time': 2};
  final Map<String, int> jenisPelajaranMap = {
    'Matematika': 1,
    'Bahasa Inggris': 2,
    'Bahasa Indonesia': 3,
    'IPA': 4,
    'IPS': 5
  };
  final Map<String, int> waktuMap = {
    '08:00 - 12:00': 3,
    '12:00 - 16:00': 2,
    '16:00 - 20:00': 1,
  };
  final Map<String, int> hariMap = {
    'Senin': 1,
    'Selasa': 2,
    'Rabu': 3,
    'Kamis': 4,
    'Jumat': 5,
    'Sabtu': 6,
    'Minggu': 7
  };
  final Map<String, int> kelasMap = {'SD': 1, 'SMP': 2, 'SMA': 3};

  final List<Kriteria> kriteriaList = [
    Kriteria(name: 'Status Guru', weight: 4, isBenefit: true),
    Kriteria(name: 'Mata Pelajaran', weight: 3, isBenefit: true),
    Kriteria(name: 'Waktu', weight: 5, isBenefit: true),
    Kriteria(name: 'Hari', weight: 4, isBenefit: true),
    Kriteria(name: 'Jumlah Anak', weight: 3, isBenefit: false),
    Kriteria(name: 'Kelas', weight: 4, isBenefit: true),
  ];

  @override
  void initState() {
    super.initState();
    _fetchGuruData();
  }

  Future<void> _fetchGuruData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getTeacherList();
      setState(() {
        guruList = data.map((guru) {
          return Guru(
            name: guru['name'] ?? 'Unknown',
            status: statusGuruMap[guru['status'].toString()] ?? 1,
            jenisPelajaran:
                jenisPelajaranMap[guru['competency_subjects'].toString()] ?? 1,
            waktu: waktuMap[guru['times'].toString()] ?? 1,
            hari: hariMap[guru['days'].toString()] ?? 1,
            kelas: kelasMap[guru['levels'].toString()] ?? 1,
            jumlahAnak: int.tryParse(guru['total_students'].toString()) ?? 1,
          );
        }).toList();
      });
    } catch (e) {
      log('Error fetching guru data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data guru: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _calculateSAW() {
    if (guruList.isEmpty) return [];
    Map<String, List<double>> normalizedData = {};
    for (int i = 0; i < kriteriaList.length; i++) {
      List<double> values = guruList.map((guru) {
        double value;
        switch (i) {
          case 0:
            value = guru.status.toDouble();
            break;
          case 1:
            value = guru.jenisPelajaran.toDouble();
            break;
          case 2:
            value = guru.waktu.toDouble();
            break;
          case 3:
            value = guru.hari.toDouble();
            break;
          case 4:
            value = guru.jumlahAnak.toDouble();
            break;
          case 5:
            value = guru.kelas.toDouble();
            break;
          default:
            value = 0.0;
        }
        return value;
      }).toList();
      double maxVal = values.reduce((a, b) => a > b ? a : b);
      double minVal = values.reduce((a, b) => a < b ? a : b);
      List<double> normalized = [];
      for (double v in values) {
        double normValue;
        if (kriteriaList[i].isBenefit) {
          normValue = (maxVal == 0) ? 0.0 : v / maxVal;
        } else {
          normValue = (v == 0) ? 0.0 : minVal / v;
        }
        normalized.add(normValue);
      }
      normalizedData[kriteriaList[i].name] = normalized;
    }
    List<Map<String, dynamic>> hasil = [];
    for (int i = 0; i < guruList.length; i++) {
      double score = 0.0;
      for (int j = 0; j < kriteriaList.length; j++) {
        score +=
            normalizedData[kriteriaList[j].name]![i] * kriteriaList[j].weight;
      }
      hasil.add({'name': guruList[i].name, 'score': score});
    }
    hasil.sort((a, b) => b['score'].compareTo(a['score']));
    for (int i = 0; i < hasil.length; i++) {
      hasil[i]['rank'] = i + 1;
    }
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _calculateSAW();
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Perhitungan SAW')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : guruList.isEmpty
              ? const Center(child: Text('Tidak ada data guru.'))
              : RefreshIndicator(
                  onRefresh: _fetchGuruData,
                  child: ListView.builder(
                    itemCount: hasil.length,
                    itemBuilder: (context, index) {
                      final item = hasil[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Skor Akhir: ${item['score'].toStringAsFixed(2)} | Peringkat: ${item['rank']}'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
