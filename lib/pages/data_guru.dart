// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';
// Import halaman edit guru
import 'edit_guru.dart';
// Import halaman tambah guru
import 'tambah_edit_guru.dart';
// Import repository untuk akses database
import '../database/repository.dart';
// Import widget umum yang digunakan di aplikasi
import '../widgets/common_widgets.dart';

// Widget halaman data guru dengan state yang dapat berubah
class DataGuruPage extends StatefulWidget {
  const DataGuruPage({super.key});

  @override
  _DataGuruPageState createState() => _DataGuruPageState();
}

class _DataGuruPageState extends State<DataGuruPage> {
  List<Map<String, dynamic>> _guruList = []; // Daftar guru yang ditampilkan
  final TextEditingController _searchController = TextEditingController(); // Controller untuk input pencarian
  List<Map<String, dynamic>> _allGuru = []; // Daftar semua guru (untuk pencarian)
  bool _isLoading = false; // Status loading data
  final Repository _repo = Repository(); // Instance repository untuk akses database

  @override
  void initState() {
    super.initState();
    _fetchDataGuru(); // Mengambil data guru saat halaman dibuka
  }

  // Method untuk mengambil data guru dari database
  Future<void> _fetchDataGuru() async {
    setState(() => _isLoading = true); // Menampilkan indikator loading
    try {
      final data = await _repo.getTeacherList();
      // Membuat daftar baru yang dapat diubah dari data
      final mutableData = List<Map<String, dynamic>>.from(data);
      // Mengurutkan daftar berdasarkan nama (A-Z)
      mutableData.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
      setState(() {
        _guruList = mutableData;
        _allGuru = mutableData;
      });
    } catch (e) {
      // Menampilkan pesan error jika gagal memuat data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data guru: $e')),
      );
    } finally {
      setState(() => _isLoading = false); // Menyembunyikan indikator loading
    }
  }

  // Method untuk menghapus data guru
  Future<void> _deleteGuru(int id) async {
    try {
      await _repo.deleteTeacher(id);
      _fetchDataGuru(); // Memuat ulang data setelah penghapusan
      // Menampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guru berhasil dihapus')),
      );
    } catch (e) {
      // Menampilkan pesan error jika gagal menghapus
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus guru: $e')),
      );
    }
  }

  // Method untuk navigasi ke halaman tambah guru
  void _navigateToTambahGuru() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahGuruPage()),
    ).then((_) => _fetchDataGuru()); // Memuat ulang data setelah kembali dari halaman tambah
  }

  // Method untuk navigasi ke halaman edit guru
  void _navigateToEditGuru(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGuruPage(id: id)),
    ).then((_) => _fetchDataGuru()); // Memuat ulang data setelah kembali dari halaman edit
  }

  // Method untuk mencari guru berdasarkan nama
  void _searchGuru(String query) {
    final filtered = _allGuru.where((guru) {
      final name = guru['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
    setState(() {
      _guruList = filtered;
    });
  }

  // Fungsi helper untuk membangun daftar waktu dengan format bullet point dan diurutkan.
  String _buildWaktuList(dynamic waktu) {
    if (waktu == null || waktu.toString().isEmpty) {
      return '-';
    }
    List<String> waktuList = [];
    if (waktu is String) {
      waktuList = waktu
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } else if (waktu is List) {
      waktuList = List<String>.from(waktu);
    }
    // Daftar urutan waktu yang diinginkan.
    List<String> waktuOrder = [
      '09:30 - 11:00',
      '12:00 - 13:30',
      '13:30 - 15:00',
      '15:00 - 16:30',
      '16:30 - 18:00'
    ];
    // Urutkan list berdasarkan indeks yang ada di waktuOrder.
    waktuList.sort((a, b) => waktuOrder.indexOf(a).compareTo(waktuOrder.indexOf(b)));
    return waktuList.map((waktuItem) => '• $waktuItem').join('\n');
  }

  // Fungsi helper untuk membangun daftar hari yang diurutkan.
  String _buildHariList(dynamic hari) {
    if (hari == null || hari.toString().isEmpty) return '-';
    List<String> hariList = [];
    if (hari is String) {
      hariList = hari
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } else if (hari is List) {
      hariList = List<String>.from(hari);
    }
    List<String> hariOrder = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    hariList.sort((a, b) => hariOrder.indexOf(a).compareTo(hariOrder.indexOf(b)));
    return hariList.join(', ');
  }

  // Fungsi helper untuk membangun daftar mata pelajaran yang diurutkan dengan format bullet point.
  String _buildMataPelajaranList(dynamic mataPelajaran) {
    if (mataPelajaran == null || mataPelajaran.toString().isEmpty) {
      return '-';
    }
    List<String> mataPelajaranList = [];
    if (mataPelajaran is String) {
      mataPelajaranList = mataPelajaran
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } else if (mataPelajaran is List) {
      mataPelajaranList = List<String>.from(mataPelajaran);
    }
    List<String> mataPelajaranOrder = [
      'Bahasa Indonesia',
      'PKN',
      'MTK/Math',
      'IPA/Science',
      'IPAS',
      'Mandarin',
      'English',
      'Kimia',
      'Fisika',
      'Calistung'
    ];
    mataPelajaranList.sort((a, b) => mataPelajaranOrder.indexOf(a).compareTo(mataPelajaranOrder.indexOf(b)));
    return mataPelajaranList.map((pelajaran) => '• $pelajaran').join('\n');
  }

  // Fungsi helper untuk membangun daftar tingkatan (kelas) yang diurutkan.
  String _buildTingkatanList(dynamic tingkatan) {
    if (tingkatan == null || tingkatan.toString().isEmpty) {
      return '-';
    }
    List<String> tingkatanList = [];
    if (tingkatan is String) {
      tingkatanList = tingkatan
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } else if (tingkatan is List) {
      tingkatanList = List<String>.from(tingkatan);
    }
    List<String> tingkatanOrder = ['Prenusery', 'TK', 'SD', 'SMP', 'SMA'];
    tingkatanList.sort((a, b) => tingkatanOrder.indexOf(a).compareTo(tingkatanOrder.indexOf(b)));
    return tingkatanList.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Guru')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTambahGuru,
        tooltip: 'Tambah Guru',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Cari Guru',
                onChanged: _searchGuru,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchDataGuru,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _guruList.isEmpty
                        ? const Center(child: Text('Tidak ada data guru.'))
                        : ListView.builder(
                            itemCount: _guruList.length,
                            itemBuilder: (context, index) {
                              final guru = _guruList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      // Jika ingin menambahkan navigasi ke halaman rincian guru, tambahkan di sini.
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            guru['name'],
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          DetailTable(
                                            details: {
                                              'Status': guru['status'].toString(),
                                              'Waktu': _buildWaktuList(guru['times']),
                                              'Hari': _buildHariList(guru['days']),
                                              'Jumlah Murid': guru['total_students'] ?? '-',
                                              'Kelas': _buildTingkatanList(guru['levels']),
                                              'Mata Pelajaran': _buildMataPelajaranList(guru['competency_subjects']),
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                                  tooltip: 'Edit Guru',
                                                  onPressed: () => _navigateToEditGuru(guru['id']),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  tooltip: 'Hapus Guru',
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Konfirmasi Hapus'),
                                                        content: const Text('Apakah Anda yakin ingin menghapus guru ini?'),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text('Batal'),
                                                            onPressed: () => Navigator.pop(context),
                                                          ),
                                                          TextButton(
                                                            child: const Text('Hapus'),
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              _deleteGuru(guru['id']);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
