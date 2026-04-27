// Enum untuk mendefinisikan semua rute navigasi dalam aplikasi
enum Routes {
  daftar_murid("/daftar_murid"), // Rute untuk halaman pendaftaran murid
  guru("/data_guru"), // Rute untuk halaman data guru
  murid("/data_murid"), // Rute untuk halaman data murid
  jadwal("/jadwal"), // Rute untuk halaman jadwal
  hasil("/hasil"), // Rute untuk halaman hasil
  ;

  // Properti untuk menyimpan path URL dari setiap rute
  final String path;
  // Constructor untuk menginisialisasi path
  const Routes(this.path);
}