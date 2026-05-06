enum LaporanStatus {
  pending,
  diproses,
  selesai,
}

extension LaporanStatusExtension on LaporanStatus {
  String get label {
    switch (this) {
      case LaporanStatus.pending:
        return 'Pending';
      case LaporanStatus.diproses:
        return 'Diproses';
      case LaporanStatus.selesai:
        return 'Selesai';
    }
  }
}

class LaporanUserModel {
  final String id;
  final String tipeKonten;
  final String namaPelapor;
  final String namaTerlapor;
  final DateTime tanggal;
  final LaporanStatus status;
  final String isiLaporan;

  const LaporanUserModel({
    required this.id,
    required this.tipeKonten,
    required this.namaPelapor,
    required this.namaTerlapor,
    required this.tanggal,
    required this.status,
    required this.isiLaporan,
  });
}