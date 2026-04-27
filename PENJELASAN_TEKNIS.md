# Penjelasan Teknis Aplikasi Data Bimble

## Arsitektur Aplikasi

Aplikasi Data Bimble menggunakan arsitektur yang memisahkan komponen-komponen utama menjadi beberapa lapisan:

1. **Lapisan Presentasi (UI)**
   - Berisi widget dan halaman untuk interaksi pengguna
   - Menggunakan StatefulWidget untuk halaman dengan state yang berubah
   - Menggunakan StatelessWidget untuk komponen UI yang statis

2. **Lapisan Model**
   - Mendefinisikan struktur data untuk entitas utama (Guru, Murid, Jadwal)
   - Menyediakan metode konversi antara objek dan format penyimpanan (toMap, fromMap)

3. **Lapisan Data**
   - DBProvider: Mengelola koneksi database SQLite
   - Repository: Menyediakan API untuk operasi CRUD

## Implementasi Database

### Struktur Tabel

1. **Tabel Guru (teachers)**
   ```sql
   CREATE TABLE teachers (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     nama TEXT,
     mapel TEXT,
     status TEXT,
     waktu TEXT,
     jumlahMurid INTEGER,
     hariMengajar INTEGER
   )
   ```

2. **Tabel Murid (students)**
   ```sql
   CREATE TABLE students (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     name TEXT,
     alamat TEXT,
     no_hp TEXT,
     tempat_lahir TEXT,
     tanggal_lahir TEXT,
     tingkatan TEXT,
     kelas TEXT,
     sekolah TEXT,
     nama_ortu TEXT,
     no_hp_ortu TEXT,
     pilihan_bimbingan TEXT
   )
   ```

3. **Tabel Jadwal (schedules)**
   ```sql
   CREATE TABLE schedules (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     teacher_id INTEGER,
     day TEXT,
     time TEXT,
     subject TEXT,
     FOREIGN KEY (teacher_id) REFERENCES teachers (id)
   )
   ```

### Singleton Pattern pada DBProvider

Aplikasi menggunakan Singleton Pattern untuk memastikan hanya ada satu instance database yang aktif:

```dart
class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
}
```

## Alur Data

### Proses Penyimpanan Data

1. **Input Data**
   - Pengguna memasukkan data melalui form di UI
   - Data divalidasi di tingkat UI

2. **Konversi Data**
   - Data dikonversi menjadi objek model (Guru/Murid/Jadwal)
   - Objek model dikonversi menjadi Map menggunakan metode toMap()

3. **Penyimpanan Data**
   - Repository memanggil metode insert/update pada database
   - Data disimpan dalam tabel yang sesuai

### Proses Pengambilan Data

1. **Query Database**
   - Repository memanggil metode query pada database
   - Hasil query berupa List<Map<String, dynamic>>

2. **Konversi Data**
   - Data dari database dikonversi menjadi objek model menggunakan factory constructor fromMap()

3. **Tampilan Data**
   - Objek model ditampilkan di UI menggunakan widget yang sesuai

## Navigasi Aplikasi

Aplikasi menggunakan sistem navigasi berbasis rute yang didefinisikan dalam enum Routes:

```dart
enum Routes {
  daftar_murid,
  guru,
  murid,
  jadwal,
  hasil
}

extension RoutesExtension on Routes {
  String get path {
    switch (this) {
      case Routes.daftar_murid: return '/daftar_murid';
      case Routes.guru: return '/guru';
      case Routes.murid: return '/murid';
      case Routes.jadwal: return '/jadwal';
      case Routes.hasil: return '/hasil';
    }
  }
}
```

Navigasi dilakukan menggunakan `Navigator.pushNamed(context, route)`.

## Pengelolaan State

Aplikasi menggunakan beberapa pendekatan untuk pengelolaan state:

1. **setState**
   - Digunakan untuk update UI pada StatefulWidget
   - Contoh: Update list jadwal setelah filter diubah

2. **Provider (Dependency)**
   - Tersedia sebagai dependensi untuk state management yang lebih kompleks
   - Dapat diimplementasikan untuk sharing state antar widget

## Optimasi Performa

1. **Lazy Loading Database**
   - Database hanya diinisialisasi saat dibutuhkan
   - Menggunakan getter async untuk memastikan database sudah siap

2. **Efisiensi Query**
   - Menggunakan where clause untuk filter data
   - Menggunakan index pada primary key dan foreign key

## Keamanan Data

1. **Validasi Input**
   - Validasi data di tingkat UI sebelum disimpan
   - Pencegahan SQL injection dengan parameter binding

2. **Penyimpanan Lokal**
   - Data disimpan secara lokal di perangkat
   - Tidak ada transmisi data ke server eksternal

## Pengujian

Aplikasi dapat diuji menggunakan:

1. **Unit Testing**
   - Pengujian fungsi-fungsi model dan repository
   - Menggunakan package flutter_test

2. **Widget Testing**
   - Pengujian komponen UI dan interaksi
   - Simulasi input pengguna

3. **Integration Testing**
   - Pengujian alur kerja aplikasi secara keseluruhan
   - Simulasi skenario penggunaan nyata

## Dependensi Utama

1. **sqflite (^2.2.0)**
   - Digunakan untuk akses database SQLite
   - Menyediakan API untuk operasi CRUD

2. **path (^1.8.0)**
   - Digunakan untuk mengelola path file database
   - Memastikan database disimpan di lokasi yang tepat

3. **intl (^0.17.0)**
   - Digunakan untuk format tanggal dan waktu
   - Mendukung lokalisasi

4. **provider (^6.0.0)**
   - Digunakan untuk state management
   - Memudahkan sharing state antar widget

5. **country_code_picker (^2.0.2)**
   - Digunakan untuk pemilihan kode negara pada nomor telepon
   - Menyediakan UI untuk pemilihan kode negara

---

Dokumen ini memberikan penjelasan teknis mendalam tentang implementasi Aplikasi Data Bimble. Untuk pengembang yang ingin memahami atau memodifikasi kode aplikasi, dokumen ini dapat menjadi referensi yang berguna.