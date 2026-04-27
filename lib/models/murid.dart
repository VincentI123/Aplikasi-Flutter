// Kelas untuk mendefinisikan model data Murid
class Murid {
  // Properti untuk menyimpan data murid
  final int? id; // ID murid (opsional, null untuk murid baru)
  final String nama; // Nama murid
  final String alamat; // Alamat tempat tinggal murid
  final String noHp; // Nomor HP murid
  final String tempatLahir; // Tempat lahir murid
  final String tanggalLahir; // Tanggal lahir murid
  final String kelas; // Kelas murid
  final String sekolah; // Asal sekolah murid
  final String namaOrangTua; // Nama orang tua murid
  final String noHpOrangTua; // Nomor HP orang tua murid
  final List<String> pilihanBimbingan; // Daftar pilihan bimbingan/mata pelajaran

  // Constructor untuk membuat objek Murid baru
  Murid({
    this.id,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.kelas,
    required this.sekolah,
    required this.namaOrangTua,
    required this.noHpOrangTua,
    required this.pilihanBimbingan,
  });

  // Method untuk mengkonversi objek Murid menjadi Map (untuk penyimpanan di database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'noHp': noHp,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir,
      'kelas': kelas,
      'sekolah': sekolah,
      'namaOrangTua': namaOrangTua,
      'noHpOrangTua': noHpOrangTua,
      'pilihanBimbingan': pilihanBimbingan.join(','), // Mengubah list menjadi string dengan pemisah koma
    };
  }

  // Factory constructor untuk membuat objek Murid dari Map (saat membaca dari database)
  factory Murid.fromMap(Map<String, dynamic> map) {
    return Murid(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      noHp: map['noHp'],
      tempatLahir: map['tempatLahir'],
      tanggalLahir: map['tanggalLahir'],
      kelas: map['kelas'],
      sekolah: map['sekolah'],
      namaOrangTua: map['namaOrangTua'],
      noHpOrangTua: map['noHpOrangTua'],
      pilihanBimbingan: map['pilihanBimbingan'].split(','), // Mengubah string menjadi list dengan pemisah koma
    );
  }
}