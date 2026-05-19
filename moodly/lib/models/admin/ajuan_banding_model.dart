import 'package:cloud_firestore/cloud_firestore.dart';

enum AjuanBandingStatus {
  pending,
  disetujui,
  ditolak,
}
enum TindakanUser {
  batasiUser,
  banSementara,
  banPermanen,
  cabutTindakan,
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
extension TindakanUserExtension on TindakanUser {
  String get label {
    switch (this) {
      case TindakanUser.batasiUser:
        return 'Batasi User';
      case TindakanUser.banSementara:
        return 'Ban Sementara';
      case TindakanUser.banPermanen:
        return 'Ban Permanen';
      case TindakanUser.cabutTindakan:
        return 'Cabut Tindakan';
    }
  }

  String get value {
    switch (this) {
      case TindakanUser.batasiUser:
        return 'batasi_user';
      case TindakanUser.banSementara:
        return 'ban_sementara';
      case TindakanUser.banPermanen:
        return 'ban_permanen';
      case TindakanUser.cabutTindakan:
        return 'cabut_tindakan';
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
TindakanUser tindakanUserFromString(String value) {
  switch (value.toLowerCase()) {
    case 'ban_sementara':
      return TindakanUser.banSementara;

    case 'ban_permanen':
      return TindakanUser.banPermanen;

    case 'cabut_tindakan':
      return TindakanUser.cabutTindakan;

    case 'batasi_user':
    default:
      return TindakanUser.batasiUser;
  }
}
class AjuanBandingModel {
  final String documentId;
  final String id;
  final String username;
  final String userId;
  final String jenisBan;
  final String alasanTindakan;
  final TindakanUser tindakanSaatIni;
  final String alasanBanding;
  final DateTime tanggal;
  final AjuanBandingStatus status;
  final String catatanAdmin;

  const AjuanBandingModel({
    required this.documentId,
    required this.id,
    required this.username,
    required this.userId,
    required this.jenisBan,
    required this.alasanBanding,
    required this.tanggal,
    required this.status,
    required this.catatanAdmin,
    required this.alasanTindakan,
    required this.tindakanSaatIni,
  });

  factory AjuanBandingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return AjuanBandingModel(
      documentId: doc.id,
      id: data['id'] ?? doc.id,
      username: data['username'] ?? data['reportedUserName'] ?? 'User tidak diketahui',
      userId: data['reportedUid'] ?? 
    data['reportedUserInfo']?['uid'] ?? '',
      jenisBan: data['jenisBan'] ?? data['tindakanSaatIni'] ?? 'Belum ada tindakan',
      alasanBanding: data['alasanBanding'] ?? 'Belum ada alasan banding',
      tanggal: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: ajuanBandingStatusFromString(
  data['statusBanding'] ?? data['status'] ?? 'pending',
),
      catatanAdmin: data['catatanAdmin'] ?? '',
alasanTindakan: data['alasanTindakan'] ?? '',
tindakanSaatIni: tindakanUserFromString(
  data['tindakanSaatIni'] ?? 'batasi_user',
),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'username': username,
      'userId': userId,
      'jenisBan': jenisBan,
      'alasanBanding': alasanBanding,
      'tanggal': Timestamp.fromDate(tanggal),
      'status': status.value,
      'catatanAdmin': catatanAdmin,
      'alasanTindakan': alasanTindakan,
      'tindakanSaatIni': tindakanSaatIni.value,
    };
  }
}