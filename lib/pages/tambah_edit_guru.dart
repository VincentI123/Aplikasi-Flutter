import 'package:flutter/material.dart';
import '../database/repository.dart';

// Widget StatefulWidget untuk halaman tambah guru baru
// Halaman ini digunakan untuk menambahkan data guru baru ke database
// Berisi form dengan berbagai input field untuk mengisi data guru
class TambahGuruPage extends StatefulWidget {
  const TambahGuruPage({super.key});

  @override
  _TambahGuruPageState createState() => _TambahGuruPageState();
}

class _TambahGuruPageState extends State<TambahGuruPage> {
  // Key untuk validasi form - digunakan untuk mengakses dan memvalidasi form
  final _formKey = GlobalKey<FormState>();
  // Controller untuk input nama guru - mengelola nilai input field nama
  final TextEditingController _nameController = TextEditingController();
  // Flag untuk mengontrol validasi otomatis - jika true, validasi akan dijalankan setiap kali user berinteraksi dengan form
  bool _autoValidate = false;

  // Variabel untuk menyimpan pilihan status, mata pelajaran, waktu, hari, dan kelas
  // Menggunakan String? karena nilainya bisa null saat form pertama kali dibuka
  String? _selectedStatus; // Menyimpan status guru yang dipilih (Full-time atau Part-time)
  // Menggunakan List<String> karena user dapat memilih lebih dari satu opsi
  List<String> _selectedSubjects = []; // Menyimpan mata pelajaran yang dipilih
  List<String> _selectedTimes = []; // Menyimpan waktu mengajar yang dipilih
  List<String> _selectedDays = []; // Menyimpan hari mengajar yang dipilih
  List<String> _selectedClasses = []; // Menyimpan kelas yang dipilih
  
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

  // Method untuk menyimpan data guru baru ke database
  // Menggunakan async-await karena operasi database bersifat asynchronous
  Future<void> _addGuru() async {
    setState(() {
      _autoValidate = true; // Mengaktifkan validasi otomatis saat submit
    });
    
    // Validasi manual untuk semua field yang tidak dapat divalidasi dengan validator biasa
    // Seperti radio button dan checkbox yang tidak memiliki validator bawaan
    bool isComplete = true; // Flag untuk menandakan apakah semua field sudah diisi
    List<String> missingFields = []; // List untuk menyimpan nama field yang belum diisi
    
    // Memeriksa field teks - memastikan nama guru tidak kosong
    if (_nameController.text.isEmpty) {
      isComplete = false;
      missingFields.add("Nama Guru");
    }
    
    // Memeriksa pilihan radio dan checkbox - memastikan semua field wajib sudah dipilih
    if (_selectedStatus == null) { // Status guru harus dipilih
      isComplete = false;
      missingFields.add("Status Guru");
    }
    if (_selectedChild == null) { // Jumlah anak harus dipilih
      isComplete = false;
      missingFields.add("Jumlah Anak");
    }
    if (_selectedSubjects.isEmpty) { // Minimal satu mata pelajaran harus dipilih
      isComplete = false;
      missingFields.add("Mata Pelajaran");
    }
    if (_selectedTimes.isEmpty) { // Minimal satu waktu mengajar harus dipilih
      isComplete = false;
      missingFields.add("Waktu Mengajar");
    }
    if (_selectedDays.isEmpty) { // Minimal satu hari mengajar harus dipilih
      isComplete = false;
      missingFields.add("Hari Mengajar");
    }
    if (_selectedClasses.isEmpty) { // Minimal satu kelas harus dipilih
      isComplete = false;
      missingFields.add("Kelas");
    }
    
    // Jika ada field yang kosong, tampilkan error message dengan daftar field yang belum diisi
    if (!isComplete) {
      // Membuat pesan error yang berisi daftar field yang belum diisi
      String errorMessage = "Harap lengkapi data berikut: ${missingFields.join(', ')}";
      // Menampilkan pesan error menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3), // Durasi tampilan pesan error
          backgroundColor: Colors.red, // Warna latar belakang pesan error
        ),
      );
      return; // Menghentikan proses penyimpanan jika validasi gagal
    }
    
    // Jika validasi lolos, simpan data guru ke database
    try {
      // Tampilkan loading indicator untuk memberi tahu user bahwa proses sedang berlangsung
      showDialog(
        context: context,
        barrierDismissible: false, // Dialog tidak dapat ditutup dengan tap di luar dialog
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(), // Indikator loading berputar
          );
        },
      );
      
      // Panggil method insert guru dari repository untuk menyimpan data ke database
      await _repo.insertTeacher({
        'name': _nameController.text, // Nama guru dari text field
        'status': _selectedStatus, // Status guru (Full-time/Part-time)
        'competency_subjects': _selectedSubjects.join(', '), // Gabungkan array mata pelajaran menjadi string dengan separator koma
        'times': _selectedTimes.join(', '), // Gabungkan array waktu menjadi string
        'days': _selectedDays.join(', '), // Gabungkan array hari menjadi string
        'total_students': _selectedChild.toString(), // Konversi jumlah anak ke string
        'levels': _selectedClasses.join(', '), // Gabungkan array kelas menjadi string
      });
      
      // Tutup loading indicator setelah proses selesai
      Navigator.pop(context);
      
      // Tampilkan pesan sukses menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data guru berhasil disimpan'), // Pesan sukses
          backgroundColor: Colors.green, // Warna latar belakang pesan sukses
        ),
      );
      
      // Kembali ke halaman sebelumnya setelah berhasil menyimpan data
      Navigator.pop(context);
    } catch (e) {
      // Tutup loading indicator jika masih ditampilkan (dalam kasus error)
      Navigator.pop(context);
      
      // Tampilkan pesan error menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan guru: $e'), // Pesan error dengan detail exception
          backgroundColor: Colors.red, // Warna latar belakang pesan error
        ),
      );
    }
  }

  // Method untuk menambah atau menghapus item dari list pilihan
  // Digunakan untuk mengelola checkbox (mata pelajaran, waktu, hari, kelas)
  // Parameter: list - list yang akan dimodifikasi, value - nilai yang akan ditambah/dihapus
  void _toggleSelection(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        // Jika item sudah ada dalam list, hapus item tersebut
        list.remove(value);
      } else {
        // Jika item belum ada dalam list, tambahkan item tersebut
        list.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Guru')),
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
                  groupValue: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value),
                )),
                if (_autoValidate && _selectedStatus == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih status guru', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),

                // Tambahan: Jumlah Anak
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

                // Mata Pelajaran
                const Text(
                  'Mata Pelajaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._subjectOptions.map((subject) => CheckboxListTile(
                  title: Text(subject),
                  value: _selectedSubjects.contains(subject),
                  onChanged: (value) => _toggleSelection(_selectedSubjects, subject),
                )),
                if (_autoValidate && _selectedSubjects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu mata pelajaran', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),
                
                // Waktu Mengajar
                const Text(
                  'Waktu Mengajar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._timeOptions.map((time) => CheckboxListTile(
                  title: Text(time),
                  value: _selectedTimes.contains(time),
                  onChanged: (value) => _toggleSelection(_selectedTimes, time),
                )),
                if (_autoValidate && _selectedTimes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu waktu mengajar', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),
                
                // Hari Mengajar
                const Text(
                  'Hari Mengajar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._daysOptions.map((day) => CheckboxListTile(
                  title: Text(day),
                  value: _selectedDays.contains(day),
                  onChanged: (value) => _toggleSelection(_selectedDays, day),
                )),
                if (_autoValidate && _selectedDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu hari mengajar', style: TextStyle(color: Colors.red)),
                  ),
                const Divider(),
                
                // Kelas
                const Text(
                  'Kelas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._classOptions.map((cls) => CheckboxListTile(
                  title: Text(cls),
                  value: _selectedClasses.contains(cls),
                  onChanged: (value) => _toggleSelection(_selectedClasses, cls),
                )),
                if (_autoValidate && _selectedClasses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih minimal satu kelas', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: _addGuru,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan Guru Baru'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
