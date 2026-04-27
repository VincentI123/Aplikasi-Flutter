// Kelas untuk mendefinisikan model data Guru
class Guru {
  // Properti untuk menyimpan data guru
  final int? id; // ID guru (opsional, null untuk guru baru)
  final String nama; // Nama guru
  final String mapel; // Mata pelajaran yang diajar
  final String status; // Status guru (tetap/tidak tetap)
  final String waktu; // Waktu mengajar
  final int jumlahMurid; // Jumlah murid yang diajar
  final int hariMengajar; // Jumlah hari mengajar dalam seminggu

  // Constructor untuk membuat objek Guru baru
  Guru({
    this.id,
    required this.nama,
    required this.mapel,
    required this.status,
    required this.waktu,
    required this.jumlahMurid,
    required this.hariMengajar,
  });

  // Method untuk mengkonversi objek Guru menjadi Map (untuk penyimpanan di database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'mapel': mapel,
      'status': status,
      'waktu': waktu,
      'jumlahMurid': jumlahMurid,
      'hariMengajar': hariMengajar,
    };
  }

  // Factory constructor untuk membuat objek Guru dari Map (saat membaca dari database)
  factory Guru.fromMap(Map<String, dynamic> map) {
    return Guru(
      id: map['id'],
      nama: map['nama'],
      mapel: map['mapel'],
      status: map['status'],
      waktu: map['waktu'],
      jumlahMurid: map['jumlahMurid'],
      hariMengajar: map['hariMengajar'],
    );
  }
}