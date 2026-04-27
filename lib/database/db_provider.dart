// Import package untuk mengelola path file database
import 'package:path/path.dart';
// Import package untuk mengakses database SQLite
import 'package:sqflite/sqflite.dart';

// Kelas untuk mengelola koneksi dan operasi database
class DBProvider {
  // Implementasi singleton pattern untuk memastikan hanya ada satu instance database
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  // Variabel untuk menyimpan instance database
  static Database? _database;

  // Getter untuk mendapatkan instance database, membuat database jika belum ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Method untuk menginisialisasi database
  Future<Database> _initDB() async {
    // Mendapatkan path direktori database
    final dbPath = await getDatabasesPath();
    // Menggabungkan path direktori dengan nama file database
    final path = join(dbPath, 'school.db');
    // Membuka atau membuat database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Method yang dipanggil saat database pertama kali dibuat
  Future _onCreate(Database db, int version) async {
    // Membuat tabel students (murid)
    await db.execute('''
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
        nama_orangtua TEXT,
        no_hp_orangtua TEXT,
        mata_pelajaran TEXT
      )
    ''');
    // Membuat tabel teachers (guru)
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        competency_subjects TEXT NOT NULL,
        times TEXT NOT NULL,
        days TEXT NOT NULL,
        total_students TEXT,
        levels TEXT NOT NULL
      )
    ''');
    // Membuat tabel schedules (jadwal)
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guru TEXT,
        murid TEXT,
        day TEXT,
        time TEXT,
        subject TEXT
      )
    ''');
  }

  // Method yang dipanggil saat versi database diupgrade
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Logika migrasi jika diperlukan
  }
}