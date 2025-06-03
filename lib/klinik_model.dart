class Klinik {
  final int id;
  final String nama;
  final String alamat;
  final String deskripsi;

  Klinik({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.deskripsi,
  });

  factory Klinik.fromJson(Map<String, dynamic> json) {
    return Klinik(
      id: json['id'],
      nama: json['nama'],
      alamat: json['alamat'],
      deskripsi: json['deskripsi'],
    );
  }
}
