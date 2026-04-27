// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';
// Import repository untuk akses database
import '../database/repository.dart';
// Import halaman tambah jadwal
import 'tambah_jadwal_page.dart';
// Import halaman edit jadwal
import 'edit_jadwal_page.dart';

// Widget halaman jadwal dengan state yang dapat berubah
class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<Map<String, dynamic>> _jadwalList = []; // Daftar jadwal yang ditampilkan
  String _selectedDay = 'Semua Hari'; // Hari yang dipilih untuk filter
  String _selectedTime = 'Semua Jam'; // Jam yang dipilih untuk filter

  // Daftar pilihan hari untuk filter
  final List<String> _days = [
    'Semua Hari',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  // Daftar pilihan jam untuk filter
  final List<String> _times = [
    'Semua Jam',
    '09:30 - 11:00',
    '12:00 - 13:30',
    '13:30 - 15:00',
    '15:00 - 16:30',
    '16:30 - 18:00'
  ];

  final Repository _repo = Repository(); // Instance repository untuk akses database

  @override
  void initState() {
    super.initState();
    _fetchData(); // Mengambil data jadwal saat halaman dibuka
  }

  // Method untuk mengambil dan memfilter data jadwal
  Future<void> _fetchData() async {
    try {
      final jadwalData = await _repo.getScheduleList();
      // Membuat salinan yang dapat diubah dan mengurutkan berdasarkan nama guru (A-Z)
      final sortedData = List<Map<String, dynamic>>.from(jadwalData)
        ..sort((a, b) => a['guru'].toString().compareTo(b['guru'].toString()));
      
      setState(() {
        // Memfilter data berdasarkan hari dan jam yang dipilih
        _jadwalList = sortedData.where((jadwal) {
          // Split day and time strings into lists since they can contain multiple values
          List<String> dayList = jadwal['day'].toString().split(',');
          List<String> timeList = jadwal['time'].toString().split(',');
          
          bool dayMatch = _selectedDay == 'Semua Hari'
              ? true
              : dayList.contains(_selectedDay);
          bool timeMatch = _selectedTime == 'Semua Jam'
              ? true
              : timeList.contains(_selectedTime);
          return dayMatch && timeMatch;
        }).toList();
      });
    } catch (error) {
      // Menampilkan pesan error jika gagal memuat data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  // Method untuk navigasi ke halaman tambah jadwal
  void _addJadwal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahJadwalPage()),
    ).then((_) => _fetchData()); // Memuat ulang data setelah kembali dari halaman tambah
  }

  // Method untuk menghapus jadwal
  Future<void> _deleteJadwal(int id) async {
    try {
      await _repo.deleteSchedule(id);
      _fetchData(); // Memuat ulang data setelah penghapusan
      // Menampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil dihapus')),
      );
    } catch (e) {
      // Menampilkan pesan error jika gagal menghapus
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus jadwal: $e')),
      );
    }
  }

  // Method untuk navigasi ke halaman edit jadwal
  void _editJadwal(Map<String, dynamic> jadwal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditJadwalPage(jadwal: jadwal)),
    ).then((_) => _fetchData()); // Memuat ulang data setelah kembali dari halaman edit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addJadwal,
        tooltip: 'Tambah Jadwal',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter row: Hari dan Jam
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    items: _days.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value!;
                        _fetchData();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButton<String>(
                    value: _selectedTime,
                    items: _times.map((time) {
                      return DropdownMenuItem(value: time, child: Text(time));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTime = value!;
                        _fetchData();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: _jadwalList.isEmpty
                    ? const Center(child: Text('Tidak ada jadwal.'))
                    : ListView.builder(
                        itemCount: _jadwalList.length,
                        itemBuilder: (context, index) {
                          final jadwal = _jadwalList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: JadwalItem(
                                guru: jadwal['guru'],
                                subject: jadwal['subject'] ?? '',
                                muridList:
                                    (jadwal['murid'] as String).split(','),
                                day: jadwal['day'] ?? '',
                                time: jadwal['time'] ?? '',
                                onDelete: () => _deleteJadwal(jadwal['id']),
                                onEdit: () => _editJadwal(jadwal),
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

class JadwalItem extends StatelessWidget {
  final String guru;
  final List<String> muridList;
  final String subject;
  final String day;
  final String time;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const JadwalItem({
    super.key,
    required this.guru,
    required this.muridList,
    required this.subject,
    required this.day,
    required this.time,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          guru,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          subject,
          style: const TextStyle(fontSize: 16),
        ),
        const Divider(),
        ...muridList.map((murid) => Text(murid.trim())),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Edit Jadwal',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Hapus Jadwal',
              onPressed: onDelete,
            ),
          ],
        ),
      ],
    );
  }
}
