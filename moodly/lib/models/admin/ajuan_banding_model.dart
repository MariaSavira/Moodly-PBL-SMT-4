import 'package:cloud_firestore/cloud_firestore.dart';

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

  String get value {
    switch (this) {
      case AjuanBandingStatus.pending:
        return 'pending';
      case AjuanBandingStatus.disetujui:
        return 'disetujui';
      case AjuanBandingStatus.ditolak:
        return 'ditolak';
    }
  }
}

AjuanBandingStatus ajuanBandingStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'disetujui':
      return AjuanBandingStatus.disetujui;
    case 'ditolak':
      return AjuanBandingStatus.ditolak;
    case 'pending':
    default:
      return AjuanBandingStatus.pending;
  }
}

class AjuanBandingModel {
  final String documentId;
  final String id;
  final String username;
  final String jenisBan;
  final String alasanBanding;
  final DateTime tanggal;
  final AjuanBandingStatus status;
  final String catatanAdmin;

  const AjuanBandingModel({
    required this.documentId,
    required this.id,
    required this.username,
    required this.jenisBan,
    required this.alasanBanding,
    required this.tanggal,
    required this.status,
    required this.catatanAdmin,
  });

  factory AjuanBandingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return AjuanBandingModel(
      documentId: doc.id,
      id: data['id'] ?? doc.id,
      username: data['username'] ?? '',
      jenisBan: data['jenisBan'] ?? '',
      alasanBanding: data['alasanBanding'] ?? '',
      tanggal: data['tanggal'] is Timestamp
          ? (data['tanggal'] as Timestamp).toDate()
          : DateTime.now(),
      status: ajuanBandingStatusFromString(data['status'] ?? 'pending'),
      catatanAdmin: data['catatanAdmin'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'username': username,
      'jenisBan': jenisBan,
      'alasanBanding': alasanBanding,
      'tanggal': Timestamp.fromDate(tanggal),
      'status': status.value,
      'catatanAdmin': catatanAdmin,
    };
  }
}