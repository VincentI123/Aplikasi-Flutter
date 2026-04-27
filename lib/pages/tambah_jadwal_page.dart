// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';
// Import repository untuk akses database
import '../database/repository.dart';

// Widget halaman tambah jadwal dengan state yang dapat berubah
class TambahJadwalPage extends StatefulWidget {
  const TambahJadwalPage({super.key});

  @override
  _TambahJadwalPageState createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  // Key untuk form validation
  final _formKey = GlobalKey<FormState>();
  // Flag untuk mengontrol validasi otomatis
  bool _autoValidate = false;
  
  // Variabel untuk menyimpan data yang dipilih
  String? _selectedGuru;
  List<String> _selectedDays = [];
  List<String> _selectedTimes = [];
  List<String> _selectedSubjects = []; // Changed from String? to List<String>
  final List<String> _selectedMurids = [];

  // Daftar pilihan hari
  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  // Daftar pilihan jam
  final List<String> _times = [
    '09:30 - 11:00',
    '12:00 - 13:30',
    '13:30 - 15:00',
    '15:00 - 16:30',
    '16:30 - 18:00'
  ];

  // Daftar data guru, murid, dan mata pelajaran
  List<Map<String, dynamic>> _guruList = [];
  List<Map<String, dynamic>> _muridList = [];
  List<String> _subjects = [];

  // Instance repository untuk akses database
  final Repository _repo = Repository();

  @override
  void initState() {
    super.initState();
    _fetchData(); // Mengambil data guru dan murid dari database saat halaman dibuka
  }

  // Method untuk mengambil data guru dan murid dari database
  Future<void> _fetchData() async {
    try {
      final guruData = await _repo.getTeacherList();
      final muridData = await _repo.getStudentList();
      setState(() {
        _guruList = guruData;
        _muridList = muridData;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  // Method untuk mengambil mata pelajaran berdasarkan guru yang dipilih
  Future<void> _fetchSubjects(String guruName) async {
    try {
      // Pass the teacher name to get their specific subjects
      final subjects = await _repo.getSubjectsFromTeacher(guruName);
      setState(() {
        _subjects = subjects;
        _selectedSubjects = []; // Reset selected subjects when teacher changes
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  // Method untuk menampilkan dialog pemilihan murid
  void _showMuridDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Murid'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: _muridList.map((murid) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    bool isChecked = _selectedMurids.contains(murid['name']);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CheckboxListTile(
                        title: Text(murid['name']),
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              if (!_selectedMurids.contains(murid['name'])) {
                                _selectedMurids.add(murid['name']);
                              }
                            } else {
                              _selectedMurids.remove(murid['name']);
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  // Method untuk menyimpan jadwal ke database
  Future<void> _saveJadwal() async {
    setState(() {
      _autoValidate = true; // Mengaktifkan validasi otomatis saat submit
    });
    
    // Validasi manual untuk semua field
    bool isComplete = true;
    List<String> missingFields = [];
    
    // Cek semua field yang diperlukan
    if (_selectedGuru == null) {
      isComplete = false;
      missingFields.add("Guru");
    }
    if (_selectedMurids.isEmpty) {
      isComplete = false;
      missingFields.add("Murid");
    }
    if (_selectedDays.isEmpty) {
      isComplete = false;
      missingFields.add("Hari");
    }
    if (_selectedTimes.isEmpty) {
      isComplete = false;
      missingFields.add("Waktu");
    }
    if (_selectedSubjects.isEmpty) {
      isComplete = false;
      missingFields.add("Mata Pelajaran");
    }
    
    // Jika ada field yang belum diisi, tampilkan pesan error
    if (!isComplete) {
      String errorMessage = "Harap lengkapi data berikut: ${missingFields.join(', ')}";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Jika semua validasi berhasil
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // Persiapkan data jadwal yang akan disimpan
      Map<String, dynamic> jadwal = {
        'guru': _selectedGuru,
        'murid': _selectedMurids.join(','),
        'day': _selectedDays.join(','),
        'time': _selectedTimes.join(','),
        'subject': _selectedSubjects.join(','),
      };
      
      // Panggil method insert jadwal dari repository
      await _repo.insertSchedule(jadwal);
      
      // Tutup loading indicator
      Navigator.pop(context);
      
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Kembali ke halaman sebelumnya
      Navigator.pop(context);
    } catch (error) {
      // Tutup loading indicator jika masih ditampilkan
      Navigator.pop(context);
      
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan jadwal: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Jadwal')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: ListView(
              children: [
                // Bagian pemilihan guru (Radio Button)
                const Text(
                  'Pilih Guru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._guruList.map((guru) {
                  return RadioListTile<String>(
                    title: Text(guru['name']),
                    value: guru['name'],
                    groupValue: _selectedGuru,
                    onChanged: (value) {
                      setState(() {
                        _selectedGuru = value;
                        if (value != null) {
                          _fetchSubjects(value); // Ambil mata pelajaran saat guru dipilih
                        }
                      });
                    },
                  );
                }).toList(),
                if (_autoValidate && _selectedGuru == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih guru', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 24),

                // Bagian pemilihan murid
                GestureDetector(
                  onTap: _showMuridDialog,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Murid',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    child: Text(
                      _selectedMurids.isEmpty
                          ? 'Belum ada murid yang dipilih'
                          : _selectedMurids.join(', '),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                if (_autoValidate && _selectedMurids.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text('Harap pilih minimal satu murid', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 10),
                // Tampilkan chip untuk murid yang dipilih
                Wrap(
                  spacing: 8.0,
                  children: _selectedMurids.map((murid) {
                    return Chip(
                      label: Text(murid),
                      onDeleted: () => setState(() {
                        _selectedMurids.remove(murid);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Bagian pemilihan hari (Checkbox)
                const Text(
                  'Pilih Hari',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._days.map((day) {
                  return CheckboxListTile(
                    title: Text(day),
                    value: _selectedDays.contains(day),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
                if (_autoValidate && _selectedDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu hari', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 24),

                // Bagian pemilihan waktu (Checkbox)
                const Text(
                  'Pilih Waktu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._times.map((time) {
                  return CheckboxListTile(
                    title: Text(time),
                    value: _selectedTimes.contains(time),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTimes.add(time);
                        } else {
                          _selectedTimes.remove(time);
                        }
                      });
                    },
                  );
                }).toList(),
                if (_autoValidate && _selectedTimes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu waktu', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 24),

                // Bagian pemilihan mata pelajaran (Checkbox instead of Radio Button)
                const Text(
                  'Pilih Mata Pelajaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._subjects.map((subject) {
                  return CheckboxListTile(
                    title: Text(subject),
                    value: _selectedSubjects.contains(subject),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedSubjects.add(subject);
                        } else {
                          _selectedSubjects.remove(subject);
                        }
                      });
                    },
                  );
                }).toList(),
                if (_autoValidate && _selectedSubjects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu mata pelajaran', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 32),

                // Tombol simpan jadwal
                ElevatedButton(
                  onPressed: _saveJadwal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan Jadwal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
