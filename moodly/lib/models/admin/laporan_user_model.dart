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
  final String reportedUid;
  final String alasanLaporan;
  final String kategoriLaporan;
  final DateTime tanggal;
  final LaporanStatus status;
  final String isiLaporan;
  final String catatanAdmin;
  final String diaryId;
  final List<String> imageUrls;

  const LaporanUserModel({
    required this.documentId,
    required this.id,
    required this.tipeKonten,
    required this.namaPelapor,
    required this.namaTerlapor,
    required this.avatarTerlapor,
    required this.reportedUid,
    required this.alasanLaporan,
    required this.kategoriLaporan,
    required this.tanggal,
    required this.status,
    required this.isiLaporan,
    required this.catatanAdmin,
    required this.diaryId,
    required this.imageUrls,
  });

  factory LaporanUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return LaporanUserModel(
      documentId: doc.id,
      id: data['id'] ?? doc.id,
      tipeKonten: data['tipeKonten'] ??
          (data['type'] == 'diary' ? 'Diary Online' : ''),
      namaPelapor: data['namaPelapor'] ??
          data['reported_by_username'] ??
          data['reporterInfo']?['displayName'] ??
          '-',
      namaTerlapor: data['namaTerlapor'] ??
          data['reported_user'] ??
          data['reportedUserInfo']?['userData']?['nickname'] ??
          data['reportedUserInfo']?['userData']?['fullName'] ??
          'User',
      avatarTerlapor: data['avatarTerlapor'] ??
          data['reported_profile'] ??
          data['reportedUserInfo']?['userData']?['photoUrl'] ??
          '',
      reportedUid: data['reportedUid'] ??
          data['reported_uid'] ??
          data['reportedUserInfo']?['uid'] ??
          '',
      alasanLaporan:
          data['alasanLaporan'] ??
          data['report_reason'] ??
          '',
      kategoriLaporan: data['kategoriLaporan'] ??
          data['report_category'] ??
          data['reportTag'] ??
          'Tidak ada kategori',
      tanggal: data['tanggal'] is Timestamp
          ? (data['tanggal'] as Timestamp).toDate()
          : data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate()
              : data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
      status: laporanStatusFromString(data['status'] ?? 'pending'),
      isiLaporan: data['isiLaporan'] ??
          data['content_text'] ??
          (data['reportedMessages'] is List &&
                  (data['reportedMessages'] as List).isNotEmpty
              ? data['reportedMessages'][0]['text'] ?? ''
              : '') ??
          'Diary tidak tersedia',
      catatanAdmin: data['catatanAdmin'] ?? '',
      diaryId: data['diaryId'] ?? data['diary_id'] ?? '',
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
      'reportedUid': reportedUid,
      'alasanLaporan': alasanLaporan,
      'kategoriLaporan': kategoriLaporan,
      'tanggal': Timestamp.fromDate(tanggal),
      'status': status.value,
      'isiLaporan': isiLaporan,
      'catatanAdmin': catatanAdmin,
      'diaryId': diaryId,
      'imageUrls': imageUrls,
    };
  }
}