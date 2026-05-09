import 'package:cloud_firestore/cloud_firestore.dart';

enum LaporanStatus {
  pending,
  diproses,
  selesai,
  ditolak,
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
      case LaporanStatus.ditolak:
        return 'Ditolak';
    }
  }

  String get value {
    switch (this) {
      case LaporanStatus.pending:
        return 'pending';
      case LaporanStatus.diproses:
        return 'diproses';
      case LaporanStatus.selesai:
        return 'selesai';
      case LaporanStatus.ditolak:
        return 'ditolak';
    }
  }
}

LaporanStatus laporanStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'diproses':
      return LaporanStatus.diproses;
    case 'selesai':
      return LaporanStatus.selesai;
    case 'ditolak':
      return LaporanStatus.ditolak;
    case 'pending':
    default:
      return LaporanStatus.pending;
  }
}

class LaporanUserModel {
  final String documentId;
  final String id;
  final String tipeKonten;
  final String namaPelapor;
  final String namaTerlapor;
  final String avatarTerlapor;
  final DateTime tanggal;
  final LaporanStatus status;
  final String isiLaporan;
  final String catatanAdmin;
  final List<String> imageUrls;

  const LaporanUserModel({
    required this.documentId,
    required this.id,
    required this.tipeKonten,
    required this.namaPelapor,
    required this.namaTerlapor,
    required this.avatarTerlapor,
    required this.tanggal,
    required this.status,
    required this.isiLaporan,
    required this.catatanAdmin,
    required this.imageUrls,
  });

  factory LaporanUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return LaporanUserModel(
      documentId: doc.id,
      id: data['id'] ?? doc.id,
      tipeKonten: data['tipeKonten'] ?? '',
      namaPelapor: data['namaPelapor'] ?? '',
      namaTerlapor: data['namaTerlapor'] ?? '',
      avatarTerlapor: data['avatarTerlapor'] ?? '',
      tanggal: data['tanggal'] is Timestamp
          ? (data['tanggal'] as Timestamp).toDate()
          : DateTime.now(),
      status: laporanStatusFromString(data['status'] ?? 'pending'),
      isiLaporan: data['isiLaporan'] ?? '',
      catatanAdmin: data['catatanAdmin'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? const []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tipeKonten': tipeKonten,
      'namaPelapor': namaPelapor,
      'namaTerlapor': namaTerlapor,
      'avatarTerlapor': avatarTerlapor,
      'tanggal': Timestamp.fromDate(tanggal),
      'status': status.value,
      'isiLaporan': isiLaporan,
      'catatanAdmin': catatanAdmin,
      'imageUrls': imageUrls,
    };
  }
}