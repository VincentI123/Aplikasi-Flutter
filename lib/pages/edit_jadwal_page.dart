// Import package Flutter untuk membangun UI
import 'package:flutter/material.dart';
// Import repository untuk akses database
import '../database/repository.dart';

// Widget halaman edit jadwal dengan state yang dapat berubah
class EditJadwalPage extends StatefulWidget {
  // Parameter jadwal yang akan diedit
  final Map<String, dynamic> jadwal;

  const EditJadwalPage({super.key, required this.jadwal});

  @override
  _EditJadwalPageState createState() => _EditJadwalPageState();
}

class _EditJadwalPageState extends State<EditJadwalPage> {
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
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
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
    _initializeData(); // Inisialisasi data dari jadwal yang ada
    _fetchData(); // Mengambil data guru dan murid dari database
  }

  // Method untuk menginisialisasi data dari jadwal yang akan diedit
  void _initializeData() {
    // Initialize fields with existing data
    _selectedGuru = widget.jadwal['guru'];
    _selectedDays = widget.jadwal['day'].toString().split(',');
    _selectedTimes = widget.jadwal['time'].toString().split(',');
    _selectedSubjects = widget.jadwal['subject'].toString().split(','); // Changed to handle multiple subjects
    _selectedMurids.addAll(widget.jadwal['murid'].toString().split(','));
    
    // Fetch subjects for the selected teacher
    if (_selectedGuru != null) {
      _fetchSubjects(_selectedGuru!);
    }
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
      final subjects = await _repo.getSubjectsFromTeacher(guruName);
      setState(() {
        _subjects = subjects;
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
                    return CheckboxListTile(
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

  // Method untuk memperbarui jadwal ke database
  Future<void> _updateJadwal() async {
    setState(() {
      _autoValidate = true; // Mengaktifkan validasi otomatis
    });
    
    // Validasi manual untuk semua field
    bool isComplete = true;
    List<String> missingFields = [];
    
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Harap lengkapi data berikut: ${missingFields.join(', ')}"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      
      // Persiapkan data jadwal yang akan diupdate
      Map<String, dynamic> updatedJadwal = {
        'id': widget.jadwal['id'],
        'guru': _selectedGuru,
        'murid': _selectedMurids.join(','),
        'day': _selectedDays.join(','),
        'time': _selectedTimes.join(','),
        'subject': _selectedSubjects.join(','), // Changed to join multiple subjects
      };
      
      // Panggil method update jadwal dari repository
      await _repo.updateSchedule(updatedJadwal);
      
      Navigator.pop(context); // Tutup loading dialog
      
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (error) {
      Navigator.pop(context); // Tutup loading dialog
      
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui jadwal: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Jadwal')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate 
                ? AutovalidateMode.onUserInteraction 
                : AutovalidateMode.disabled,
            child: ListView(
              children: [
                // Bagian pemilihan guru
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
                
                const SizedBox(height: 24),
                
                // Bagian pemilihan murid
                GestureDetector(
                  onTap: _showMuridDialog,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Murid',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10, 
                        horizontal: 10
                      ),
                    ),
                    child: Text(
                      _selectedMurids.isEmpty
                          ? 'Belum ada murid yang dipilih'
                          : _selectedMurids.join(', '),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bagian pemilihan hari
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
                
                const SizedBox(height: 24),
                
                // Bagian pemilihan waktu
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
                
                const SizedBox(height: 24),
                
                // Bagian pemilihan mata pelajaran (changed from RadioListTile to CheckboxListTile)
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
                
                const SizedBox(height: 32),
                
                // Tombol simpan perubahan
                ElevatedButton(
                  onPressed: _updateJadwal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}