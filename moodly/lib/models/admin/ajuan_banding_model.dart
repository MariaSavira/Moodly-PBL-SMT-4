enum AjuanBandingStatus {
  pending,
  disetujui,
  ditolak,
}

extension AjuanBandingStatusExtension on AjuanBandingStatus {
  String get label {
    switch (this) {
      case AjuanBandingStatus.pending:
        return 'Pending';
      case AjuanBandingStatus.disetujui:
        return 'Disetujui';
      case AjuanBandingStatus.ditolak:
        return 'Ditolak';
    }
  }
}

class AjuanBandingModel {
  final String id;
  final String username;
  final String jenisBan;
  final String alasanBanding;
  final DateTime tanggal;
  final AjuanBandingStatus status;

  const AjuanBandingModel({
    required this.id,
    required this.username,
    required this.jenisBan,
    required this.alasanBanding,
    required this.tanggal,
    required this.status,
  });
}