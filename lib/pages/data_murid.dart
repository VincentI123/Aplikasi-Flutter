// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';
// Import halaman edit murid
import 'edit_murid.dart';
// Import halaman tambah murid
import 'tambah_edit_murid.dart';
// Import halaman rincian murid
import 'RincianMuridPage.dart';
// Import repository untuk akses database
import '../database/repository.dart';
// Import widget umum yang digunakan di aplikasi
import '../widgets/common_widgets.dart';

// Widget halaman data murid dengan state yang dapat berubah
class DataMuridPage extends StatefulWidget {
  const DataMuridPage({super.key});

  @override
  _DataMuridPageState createState() => _DataMuridPageState();
}

class _DataMuridPageState extends State<DataMuridPage> {
  List<Map<String, dynamic>> _muridList = []; // Daftar murid yang ditampilkan
  final TextEditingController _searchController = TextEditingController(); // Controller untuk input pencarian
  List<Map<String, dynamic>> _allMurid = []; // Daftar semua murid (untuk pencarian)
  bool _isLoading = false; // Status loading data
  final Repository _repo = Repository(); // Instance repository untuk akses database

  @override
  void initState() {
    super.initState();
    _fetchDataMurid(); // Mengambil data murid saat halaman dibuka
  }

  // Method untuk mengambil data murid dari database
  Future<void> _fetchDataMurid() async {
    setState(() => _isLoading = true); // Menampilkan indikator loading
    final data = await _repo.getStudentList();
    // Membuat daftar baru yang dapat diubah dari data
    final mutableData = List<Map<String, dynamic>>.from(data);
    // Mengurutkan daftar berdasarkan nama (A-Z)
    mutableData.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    setState(() {
      _muridList = mutableData;
      _allMurid = mutableData;
      _isLoading = false; // Menyembunyikan indikator loading
    });
  }

  // Method untuk menghapus data murid
  Future<void> _deleteMurid(int id) async {
    await _repo.deleteStudent(id);
    _fetchDataMurid(); // Memuat ulang data setelah penghapusan
    // Menampilkan notifikasi sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Murid berhasil dihapus')),
    );
  }

  // Method untuk navigasi ke halaman tambah murid
  void _navigateToTambahMurid() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahMuridPage()),
    ).then((_) => _fetchDataMurid()); // Memuat ulang data setelah kembali dari halaman tambah
  }

  // Method untuk navigasi ke halaman edit murid
  void _navigateToEditMurid(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditMuridPage(muridId: id)),
    ).then((_) => _fetchDataMurid()); // Memuat ulang data setelah kembali dari halaman edit
  }

  // Method untuk mencari murid berdasarkan nama
  void _searchMurid(String query) {
    final filtered = _allMurid.where((murid) {
      final name = murid['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
    setState(() {
      _muridList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Murid')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTambahMurid,
        tooltip: 'Tambah Murid',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Cari Murid',
                onChanged: _searchMurid,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchDataMurid,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _muridList.isEmpty
                        ? const Center(child: Text('Tidak ada data murid.'))
                        : ListView.builder(
                            itemCount: _muridList.length,
                            itemBuilder: (context, index) {
                              final murid = _muridList[index];
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
                                      // Navigasi ke halaman RincianMuridPage
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RincianMuridPage(murid: murid),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            murid['name'],
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          DetailTable(
                                            details: {
                                              'Tingkatan':
                                                  murid['tingkatan'] ?? '-',
                                              'Sekolah':
                                                  murid['sekolah'] ?? '-',
                                              'Mata Pelajaran':
                                                  _buildMataPelajaranList(
                                                      murid['mata_pelajaran']),
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  tooltip: 'Edit Murid',
                                                  onPressed: () =>
                                                      _navigateToEditMurid(
                                                          murid['id']),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  tooltip: 'Hapus Murid',
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Konfirmasi Hapus'),
                                                        content: const Text(
                                                            'Apakah Anda yakin ingin menghapus murid ini?'),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                'Batal'),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                'Hapus'),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              _deleteMurid(
                                                                  murid['id']);
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

  // Helper function to build Mata Pelajaran as formatted string (with bullet points)
  String _buildMataPelajaranList(dynamic mataPelajaran) {
    if (mataPelajaran == null || mataPelajaran.toString().isEmpty) {
      return '-';
    }

    List<String> mataPelajaranList = [];
    
    if (mataPelajaran is String) {
      mataPelajaranList = mataPelajaran.split(',').map((item) => item.trim()).toList();
    } else if (mataPelajaran is List) {
      mataPelajaranList = List<String>.from(mataPelajaran);
    }

    // Define the desired order of subjects
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

    // Sort the list according to the predefined order
    mataPelajaranList.sort((a, b) => 
        mataPelajaranOrder.indexOf(a).compareTo(mataPelajaranOrder.indexOf(b)));

    return mataPelajaranList
        .map((pelajaran) => '• $pelajaran')
        .join('\n');
  }
}