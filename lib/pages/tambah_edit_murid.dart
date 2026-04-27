import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/repository.dart';

// Widget StatefulWidget untuk halaman tambah murid baru
// Halaman ini digunakan untuk menambahkan data murid baru ke database
// Berisi form dengan berbagai input field untuk mengisi data murid
class TambahMuridPage extends StatefulWidget {
  const TambahMuridPage({super.key});

  @override
  _TambahMuridPageState createState() => _TambahMuridPageState();
}

class _TambahMuridPageState extends State<TambahMuridPage> {
  // Key untuk validasi form - digunakan untuk mengakses dan memvalidasi form
  final _formKey = GlobalKey<FormState>();
  // Flag untuk mengontrol validasi otomatis - jika true, validasi akan dijalankan setiap kali user berinteraksi dengan form
  bool _autoValidate = false; 

  // Controllers untuk input field - mengelola nilai input field
  final TextEditingController _nameController = TextEditingController(); // Nama murid
  final TextEditingController _alamatController = TextEditingController(); // Alamat murid
  final TextEditingController _noHpController = TextEditingController(); // Nomor HP murid
  final TextEditingController _tempatLahirController = TextEditingController(); // Tempat lahir murid
  final TextEditingController _tanggalLahirController = TextEditingController(); // Tanggal lahir murid
  final TextEditingController _sekolahController = TextEditingController(); // Sekolah murid
  final TextEditingController _namaOrtuController = TextEditingController(); // Nama orang tua/wali murid
  final TextEditingController _noHpOrtuController = TextEditingController(); // Nomor HP orang tua/wali murid

  // Menggunakan radio button untuk pemilihan tunggal
  // Menggunakan String? karena nilainya bisa null saat form pertama kali dibuka
  String? _selectedTingkatan; // Tingkatan pendidikan (Pre-Nursery, TK, SD, SMP, SMA)
  String? _selectedKelas; // Kelas berdasarkan tingkatan yang dipilih
  // Menggunakan List<String> karena user dapat memilih lebih dari satu mata pelajaran
  final List<String> _selectedSubjects = []; // Mata pelajaran yang dipilih

  // Daftar pilihan tingkatan pendidikan yang tersedia
  final List<String> _tingkatanOptions = ['Pre-Nursery', 'TK', 'SD', 'SMP', 'SMA'];
  // Map untuk menyimpan opsi kelas berdasarkan tingkatan yang dipilih
  // Key: tingkatan, Value: list kelas yang tersedia untuk tingkatan tersebut
  final Map<String, List<String>> _kelasOptions = {
    'Pre-Nursery': ['Pre-Nursery'],
    'TK': ['TK-A', 'TK-B'],
    'SD': ['1', '2', '3', '4', '5', '6'],
    'SMP': ['7', '8', '9'],
    'SMA': ['10', '11', '12'],
  };
  // Daftar pilihan mata pelajaran yang tersedia
  // List ini berisi semua mata pelajaran yang dapat dipilih oleh murid
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

  // Instance repository untuk akses database
  // Repository digunakan sebagai perantara antara UI dan database
  // Berisi method-method untuk operasi CRUD (Create, Read, Update, Delete)
  final Repository _repo = Repository();

  // Fungsi untuk memilih tanggal lahir menggunakan date picker
  // Menampilkan dialog pemilihan tanggal dan mengisi field tanggal lahir
  Future<void> _selectDate(BuildContext context) async {
    // Menentukan tanggal awal yang ditampilkan di date picker
    DateTime initialDate = DateTime.now();
    // Jika field tanggal lahir sudah diisi, gunakan nilai tersebut sebagai tanggal awal
    if (_tanggalLahirController.text.isNotEmpty) {
      try {
        // Parse string tanggal menjadi objek DateTime
        initialDate = DateFormat('yyyy-MM-dd').parse(_tanggalLahirController.text);
      } catch (_) {} // Abaikan error jika format tanggal tidak valid
    }
    // Menampilkan dialog date picker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // Tanggal awal yang ditampilkan
      firstDate: DateTime(1970), // Tanggal paling awal yang dapat dipilih
      lastDate: DateTime.now(), // Tanggal paling akhir yang dapat dipilih (hari ini)
    );
    // Jika user memilih tanggal (tidak membatalkan dialog)
    if (picked != null) {
      setState(() {
        // Format tanggal yang dipilih menjadi string dengan format yyyy-MM-dd
        _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Method untuk menyimpan data murid baru ke database
  // Menggunakan async-await karena operasi database bersifat asynchronous
  Future<void> _saveMurid() async {
    setState(() {
      _autoValidate = true; // Aktifkan validasi otomatis saat submit
    });
    
    // Validasi manual untuk semua field yang tidak dapat divalidasi dengan validator biasa
    // Seperti radio button dan checkbox yang tidak memiliki validator bawaan
    bool isComplete = true; // Flag untuk menandakan apakah semua field sudah diisi
    List<String> missingFields = []; // List untuk menyimpan nama field yang belum diisi
    
    // Memeriksa field teks - memastikan semua field teks tidak kosong
    if (_nameController.text.isEmpty) { // Nama murid harus diisi
      isComplete = false;
      missingFields.add("Nama Murid");
    }
    if (_alamatController.text.isEmpty) { // Alamat murid harus diisi
      isComplete = false;
      missingFields.add("Alamat");
    }
    if (_noHpController.text.isEmpty) { // Nomor HP murid harus diisi
      isComplete = false;
      missingFields.add("No HP");
    }
    if (_tempatLahirController.text.isEmpty) { // Tempat lahir murid harus diisi
      isComplete = false;
      missingFields.add("Tempat Lahir");
    }
    if (_tanggalLahirController.text.isEmpty) { // Tanggal lahir murid harus diisi
      isComplete = false;
      missingFields.add("Tanggal Lahir");
    }
    if (_sekolahController.text.isEmpty) { // Sekolah murid harus diisi
      isComplete = false;
      missingFields.add("Sekolah");
    }
    if (_namaOrtuController.text.isEmpty) { // Nama orang tua/wali harus diisi
      isComplete = false;
      missingFields.add("Nama Orang Tua/Wali");
    }
    if (_noHpOrtuController.text.isEmpty) { // Nomor HP orang tua/wali harus diisi
      isComplete = false;
      missingFields.add("No HP Orang Tua/Wali");
    }
    
    // Memeriksa pilihan radio dan checkbox - memastikan semua field wajib sudah dipilih
    if (_selectedTingkatan == null) { // Tingkatan pendidikan harus dipilih
      isComplete = false;
      missingFields.add("Tingkatan");
    }
    if (_selectedKelas == null) { // Kelas harus dipilih
      isComplete = false;
      missingFields.add("Kelas");
    }
    if (_selectedSubjects.isEmpty) { // Minimal satu mata pelajaran harus dipilih
      isComplete = false;
      missingFields.add("Mata Pelajaran");
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
    
    // Jika validasi lolos, buat map data murid yang akan disimpan ke database
    // Map ini berisi semua field yang diperlukan untuk tabel murid
    Map<String, dynamic> murid = {
      'name': _nameController.text, // Nama murid
      'alamat': _alamatController.text, // Alamat murid
      'no_hp': _noHpController.text, // Nomor HP murid
      'tempat_lahir': _tempatLahirController.text, // Tempat lahir murid
      'tanggal_lahir': _tanggalLahirController.text, // Tanggal lahir murid
      'tingkatan': _selectedTingkatan, // Tingkatan pendidikan
      'kelas': _selectedKelas, // Kelas
      'sekolah': _sekolahController.text, // Sekolah murid
      'nama_orangtua': _namaOrtuController.text, // Nama orang tua/wali
      'no_hp_orangtua': _noHpOrtuController.text, // Nomor HP orang tua/wali
      'mata_pelajaran': _selectedSubjects.join(', '), // Gabungkan array mata pelajaran menjadi string dengan separator koma
    };

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
      
      // Panggil method insert student dari repository untuk menyimpan data ke database
      await _repo.insertStudent(murid);
      
      // Tutup loading indicator setelah proses selesai
      Navigator.pop(context);
      
      // Tampilkan pesan sukses menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data murid berhasil disimpan'), // Pesan sukses
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
          content: Text('Gagal menyimpan data murid: $e'), // Pesan error dengan detail exception
          backgroundColor: Colors.red, // Warna latar belakang pesan error
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Murid')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Field input lainnya
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Murid'),
                validator: (value) => value!.isEmpty ? 'Nama harus diisi' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Alamat harus diisi' : null,
              ),
              TextFormField(
                controller: _noHpController,
                decoration: const InputDecoration(labelText: 'No HP'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'No HP harus diisi' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempatLahirController,
                      decoration: const InputDecoration(labelText: 'Tempat Lahir'),
                      validator: (value) => value!.isEmpty ? 'Tempat lahir harus diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _tanggalLahirController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        hintText: 'yyyy-MM-dd',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) => value!.isEmpty ? 'Tanggal lahir harus diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Radio button untuk Tingkatan
              const Text('Pilih Tingkatan', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: _tingkatanOptions.map((tingkatan) {
                  return RadioListTile<String>(
                    title: Text(tingkatan),
                    value: tingkatan,
                    groupValue: _selectedTingkatan,
                    onChanged: (value) {
                      setState(() {
                        _selectedTingkatan = value;
                        _selectedKelas = null; // reset kelas jika tingkatan berubah
                      });
                    },
                  );
                }).toList(),
              ),
              if (_autoValidate && _selectedTingkatan == null)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text('Harap pilih tingkatan', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              // Radio button untuk Kelas (tampil jika tingkatan telah dipilih)
              if (_selectedTingkatan != null) ...[
                const Text('Pilih Kelas', style: TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  children: _kelasOptions[_selectedTingkatan!]!.map((kelas) {
                    return RadioListTile<String>(
                      title: Text(kelas),
                      value: kelas,
                      groupValue: _selectedKelas,
                      onChanged: (value) {
                        setState(() {
                          _selectedKelas = value;
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_autoValidate && _selectedKelas == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Harap pilih kelas', style: TextStyle(color: Colors.red)),
                  ),
              ],
              TextFormField(
                controller: _sekolahController,
                decoration: const InputDecoration(labelText: 'Sekolah'),
                validator: (value) => value!.isEmpty ? 'Sekolah harus diisi' : null,
              ),
              const SizedBox(height: 16),
              const Text('Informasi Orang Tua/Wali', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _namaOrtuController,
                decoration: const InputDecoration(labelText: 'Nama Orang Tua/Wali'),
                validator: (value) => value!.isEmpty ? 'Nama orang tua harus diisi' : null,
              ),
              TextFormField(
                controller: _noHpOrtuController,
                decoration: const InputDecoration(labelText: 'No HP Orang Tua/Wali'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'No HP orang tua harus diisi' : null,
              ),
              const SizedBox(height: 16),
              const Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                children: _subjectOptions.map((subject) {
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
              ),
              if (_autoValidate && _selectedSubjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text('Harap pilih minimal satu mata pelajaran', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMurid,
                child: const Text('Simpan Data Murid'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
