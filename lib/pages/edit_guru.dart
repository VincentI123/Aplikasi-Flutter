import 'package:flutter/material.dart';
import '../database/repository.dart';

// Widget StatefulWidget untuk halaman edit guru
// Halaman ini digunakan untuk mengedit data guru yang sudah ada di database
// Menerima parameter id guru yang akan diedit
class EditGuruPage extends StatefulWidget {
  // Parameter wajib berupa ID guru yang akan diedit
  // ID ini digunakan untuk mengambil data guru dari database
  final int id;
  const EditGuruPage({super.key, required this.id});

  @override
  _EditGuruPageState createState() => _EditGuruPageState();
}

class _EditGuruPageState extends State<EditGuruPage> {
  // Key untuk validasi form - digunakan untuk mengakses dan memvalidasi form
  final _formKey = GlobalKey<FormState>();
  // Controller untuk input nama guru - mengelola nilai input field nama
  final _nameController = TextEditingController();
  // Flag untuk mengontrol validasi otomatis - jika true, validasi akan dijalankan setiap kali user berinteraksi dengan form
  bool _autoValidate = false; 

  // List untuk menyimpan pilihan mata pelajaran, waktu, hari, dan kelas
  // Menggunakan List<String> karena user dapat memilih lebih dari satu opsi
  List<String> _selectedSubject = []; // Menyimpan mata pelajaran yang dipilih
  List<String> _selectedTime = []; // Menyimpan waktu mengajar yang dipilih
  List<String> _selectedDays = []; // Menyimpan hari mengajar yang dipilih
  List<String> _selectedClass = []; // Menyimpan kelas yang dipilih
  // Variabel untuk menyimpan status guru yang dipilih (Full-time atau Part-time)
  // Menggunakan String? karena nilainya bisa null saat form pertama kali dibuka
  String? _statusGuru; 

  // Variabel untuk menyimpan jumlah anak/murid yang diajar
  // Menggunakan int? karena nilainya bisa null saat form pertama kali dibuka
  int? _selectedChild;
  // Daftar pilihan jumlah anak/murid - opsi yang tersedia untuk dipilih
  final List<int> _childOptions = [1, 2, 3, 4, 5];

  // Instance repository untuk akses database
  // Repository digunakan sebagai perantara antara UI dan database
  // Berisi method-method untuk operasi CRUD (Create, Read, Update, Delete)
  final Repository _repo = Repository();

  // Daftar pilihan mata pelajaran yang tersedia
  // List ini berisi semua mata pelajaran yang dapat dipilih oleh guru
  final List<String> _subjectOptions = [
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
  // Daftar pilihan waktu mengajar yang tersedia
  // List ini berisi semua slot waktu mengajar yang dapat dipilih oleh guru
  final List<String> _timeOptions = [
    '09:30 - 11:00',
    '12:00 - 13:30',
    '13:30 - 15:00',
    '15:00 - 16:30',
    '16:30 - 18:00'
  ];
  // Daftar pilihan status guru yang tersedia
  // List ini berisi opsi status guru (penuh waktu atau paruh waktu)
  final List<String> _statusOptions = ['Full-time', 'Part-time'];
  // Daftar pilihan hari mengajar yang tersedia
  // List ini berisi semua hari dalam seminggu yang dapat dipilih untuk mengajar
  final List<String> _daysOptions = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu'
  ];
  // Daftar pilihan kelas/tingkatan yang tersedia
  // List ini berisi semua tingkatan kelas yang dapat diajar oleh guru
  final List<String> _classOptions = ['Prenusery','TK', 'SD', 'SMP', 'SMA'];

  @override
  void initState() {
    super.initState();
    // Memanggil method untuk memuat data guru saat widget pertama kali diinisialisasi
    _loadGuruData();
  }

  // Method untuk memuat data guru dari database berdasarkan ID
  // Menggunakan async-await karena operasi database bersifat asynchronous
  Future<void> _loadGuruData() async {
    try {
      // Mengambil data guru dari repository berdasarkan ID
      final guru = await _repo.getTeacher(widget.id);
      // Memperbarui state dengan data guru yang diperoleh
      setState(() {
        // Mengisi controller nama dengan data dari database
        _nameController.text = guru['name'] ?? '';
        // Mengisi status guru, memastikan nilai yang diperoleh ada dalam daftar opsi
        _statusGuru = _statusOptions.contains(guru['status'].toString())
            ? guru['status'].toString()
            : null;
        // Mengisi daftar mata pelajaran, memecah string menjadi list
        _selectedSubject = guru['competency_subjects']?.split(', ') ?? [];
        // Mengisi daftar waktu mengajar, memecah string menjadi list
        _selectedTime = guru['times']?.split(', ') ?? [];
        // Mengisi daftar hari mengajar, memecah string menjadi list
        _selectedDays = guru['days']?.split(', ') ?? [];
        // Mengisi daftar kelas, memecah string menjadi list
        _selectedClass = guru['levels']?.split(', ') ?? [];
        // Mengisi nilai jumlah anak jika tersedia, mengkonversi string ke integer
        _selectedChild = int.tryParse(guru['total_students'] ?? '');
      });
    } catch (e) {
      // Menampilkan pesan error jika gagal memuat data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data guru: $e')),
      );
    }
  }

  // Method untuk memperbarui data guru ke database
  // Menggunakan async-await karena operasi database bersifat asynchronous
  Future<void> _updateGuru() async {
    // Validasi form menggunakan FormState
    if (_formKey.currentState!.validate()) {
      // Validasi tambahan untuk field yang tidak dapat divalidasi dengan validator biasa
      // Seperti radio button dan checkbox yang tidak memiliki validator bawaan
      String errorMessage = '';
      
      // Memeriksa apakah semua field wajib sudah diisi
      if (_statusGuru == null) {
        errorMessage = 'Pilih status guru';
      } else if (_selectedSubject.isEmpty) {
        errorMessage = 'Pilih minimal satu mata pelajaran';
      } else if (_selectedTime.isEmpty) {
        errorMessage = 'Pilih minimal satu waktu mengajar';
      } else if (_selectedDays.isEmpty) {
        errorMessage = 'Pilih minimal satu hari mengajar';
      } else if (_selectedClass.isEmpty) {
        errorMessage = 'Pilih minimal satu kelas';
      } else if (_selectedChild == null) {
        errorMessage = 'Pilih jumlah anak';
      }

      // Jika ada error, tampilkan pesan dan hentikan proses update
      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return;
      }

      // Membuat map data guru yang akan diupdate ke database
      // Map ini berisi semua field yang diperlukan untuk tabel guru
      Map<String, dynamic> guru = {
        'id': widget.id, // ID guru yang akan diupdate
        'name': _nameController.text, // Nama guru dari text field
        'status': _statusGuru, // Status guru (Full-time/Part-time)
        'competency_subjects': _selectedSubject.join(', '), // Gabungkan array mata pelajaran menjadi string dengan separator koma
        'times': _selectedTime.join(', '), // Gabungkan array waktu menjadi string
        'days': _selectedDays.join(', '), // Gabungkan array hari menjadi string
        'total_students': _selectedChild.toString(), // Konversi jumlah anak ke string
        'levels': _selectedClass.join(', '), // Gabungkan array kelas menjadi string
      };

      try {
        // Memanggil method updateTeacher dari repository untuk menyimpan perubahan ke database
        await _repo.updateTeacher(guru);
        // Menampilkan pesan sukses jika berhasil update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data guru berhasil diperbarui')),
        );
        // Kembali ke halaman sebelumnya setelah berhasil update
        Navigator.pop(context);
      } catch (e) {
        // Menampilkan pesan error jika gagal update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data guru: $e')),
        );
      }
    }
  }

  // Function untuk menambah atau menghapus item dari list pilihan
  // Digunakan untuk mengelola checkbox (mata pelajaran, waktu, hari, kelas)
  // Parameter: selectedList - list yang akan dimodifikasi, value - nilai yang akan ditambah/dihapus
  void _toggleSelection(List<String> selectedList, String value) {
    setState(() {
      // Jika item sudah ada dalam list, hapus item tersebut
      if (selectedList.contains(value)) {
        selectedList.remove(value);
      } else {
        // Jika item belum ada dalam list, tambahkan item tersebut
        selectedList.add(value);
      }
    });
  }

  // Function untuk menangani pemilihan Status Guru (radio button)
  // Memastikan hanya satu status yang terpilih (Full-time atau Part-time)
  // Parameter: value - nilai status yang dipilih
  void _selectStatus(String value) {
    setState(() {
      // Mengubah nilai _statusGuru menjadi nilai yang dipilih
      _statusGuru = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Guru')),
      body: SafeArea( // SafeArea memastikan konten tidak tertutup oleh notch atau status bar
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding untuk memberikan ruang di sekitar form
          child: Form(
            key: _formKey, // Key untuk mengakses form state
            // Mode validasi otomatis: jika _autoValidate true, validasi akan dijalankan setiap kali user berinteraksi
            autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: ListView( // ListView untuk memungkinkan scrolling jika konten melebihi layar
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Guru'),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                
                // Status Guru
                const Text(
                  'Status Guru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._statusOptions.map((status) => RadioListTile<String>(
                  title: Text(status),
                  value: status,
                  groupValue: _statusGuru,
                  onChanged: (value) => setState(() => _statusGuru = value),
                )),
                if (_autoValidate && _statusGuru == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih status guru', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),

                // Jumlah Anak
                const Text(
                  'Jumlah Anak',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._childOptions.map((child) => RadioListTile<int>(
                  title: Text(child.toString()),
                  value: child,
                  groupValue: _selectedChild,
                  onChanged: (value) => setState(() => _selectedChild = value),
                )),
                if (_autoValidate && _selectedChild == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih jumlah anak', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),

                // Update Mata Pelajaran section
                const Text(
                  'Mata Pelajaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._subjectOptions.map((subject) => CheckboxListTile(
                  title: Text(subject),
                  value: _selectedSubject.contains(subject),
                  onChanged: (bool? value) {
                    _toggleSelection(_selectedSubject, subject);
                  },
                )),
                if (_autoValidate && _selectedSubject.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu mata pelajaran', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),

                // Update Waktu Mengajar section  
                const Text(
                  'Waktu Mengajar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._timeOptions.map((time) => CheckboxListTile(
                  title: Text(time),
                  value: _selectedTime.contains(time),
                  onChanged: (bool? value) {
                    _toggleSelection(_selectedTime, time);
                  },
                )),
                if (_autoValidate && _selectedTime.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu waktu mengajar', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),

                // Update Hari Mengajar section
                const Text(
                  'Hari Mengajar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._daysOptions.map((day) => CheckboxListTile(
                  title: Text(day),
                  value: _selectedDays.contains(day),
                  onChanged: (bool? value) {
                    _toggleSelection(_selectedDays, day);
                  },
                )),
                if (_autoValidate && _selectedDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu hari mengajar', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),

                // Update Kelas section
                const Text(
                  'Kelas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._classOptions.map((cls) => CheckboxListTile(
                  title: Text(cls),
                  value: _selectedClass.contains(cls),
                  onChanged: (bool? value) {
                    _toggleSelection(_selectedClass, cls);
                  },
                )),
                if (_autoValidate && _selectedClass.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu kelas', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateGuru,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Update Data Guru'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
