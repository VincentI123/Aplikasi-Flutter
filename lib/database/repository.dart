// Import provider database
import 'db_provider.dart';

// Kelas untuk mengelola operasi CRUD pada database
class Repository {
  // Instance dari DBProvider untuk mengakses database
  final DBProvider _dbProvider = DBProvider();

  // CRUD untuk Murid (Students)
  // Method untuk mendapatkan daftar semua murid
  Future<List<Map<String, dynamic>>> getStudentList() async {
    final db = await _dbProvider.database;
    return await db.query('students');
  }

  // Method untuk mendapatkan data murid berdasarkan ID
  Future<Map<String, dynamic>> getStudent(int id) async {
    final db = await _dbProvider.database;
    final res = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return res.first;
    throw Exception('Student not found');
  }

  // Method untuk menambahkan data murid baru
  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await _dbProvider.database;
    return await db.insert('students', student);
  }

  // Method untuk mengupdate data murid
  Future<int> updateStudent(Map<String, dynamic> student) async {
    final db = await _dbProvider.database;
    return await db.update('students', student, where: 'id = ?', whereArgs: [student['id']]);
  }

  // Method untuk menghapus data murid
  Future<int> deleteStudent(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Guru (Teachers)
  // Method untuk mendapatkan daftar semua guru
  Future<List<Map<String, dynamic>>> getTeacherList() async {
    final db = await _dbProvider.database;
    return await db.query('teachers');
  }

  // Method untuk mendapatkan data guru berdasarkan ID
  Future<Map<String, dynamic>> getTeacher(int id) async {
    final db = await _dbProvider.database;
    final res = await db.query('teachers', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return res.first;
    throw Exception('Teacher not found');
  }

  // Method untuk menambahkan data guru baru
  Future<int> insertTeacher(Map<String, dynamic> teacher) async {
    final db = await _dbProvider.database;
    return await db.insert('teachers', teacher);
  }

  // Method untuk mengupdate data guru
  Future<int> updateTeacher(Map<String, dynamic> teacher) async {
    final db = await _dbProvider.database;
    return await db.update('teachers', teacher, where: 'id = ?', whereArgs: [teacher['id']]);
  }

  // Method untuk menghapus data guru
  Future<int> deleteTeacher(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Jadwal (Schedules)
  // Method untuk mendapatkan daftar semua jadwal
  Future<List<Map<String, dynamic>>> getScheduleList() async {
    final db = await _dbProvider.database;
    return await db.query('schedules');
  }

  // Method untuk menambahkan jadwal baru
  Future<int> insertSchedule(Map<String, dynamic> schedule) async {
    final db = await _dbProvider.database;
    return await db.insert('schedules', schedule);
  }

  // Method untuk mengupdate jadwal
  Future<int> updateSchedule(Map<String, dynamic> schedule) async {
    final db = await _dbProvider.database;
    return await db.update('schedules', schedule, where: 'id = ?', whereArgs: [schedule['id']]);
  }

  // Method untuk menghapus jadwal
  Future<int> deleteSchedule(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  // Method untuk mendapatkan daftar mata pelajaran dari guru tertentu (untuk form jadwal)
  Future<List<String>> getSubjectsFromTeacher(String teacherName) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'teachers',
      columns: ['competency_subjects'],
      where: 'name = ?',
      whereArgs: [teacherName],
    );
    
    if (res.isEmpty) return [];
    
    // Memisahkan string mata pelajaran menjadi list
    String subjectsStr = res.first['competency_subjects'].toString();
    return subjectsStr.split(',').map((s) => s.trim()).toList();
  }
}