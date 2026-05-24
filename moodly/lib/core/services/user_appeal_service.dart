import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAppealService {
  UserAppealService._();

  static final UserAppealService instance = UserAppealService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => _asMap(e)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  DateTime _toDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime(2000);
    return DateTime(2000);
  }

  String _firstNonEmpty(List<String?> values, {String fallback = ''}) {
    for (final value in values) {
      final text = (value ?? '').trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  Future<List<Map<String, dynamic>>> getReportsAgainstMe() async {
    final uid = _uid;
    if (uid == null) return [];

    final snap = await _reportsRef.where('reportedUid', isEqualTo: uid).get();

    final items = snap.docs.map((doc) {
      final data = doc.data();

      return {
        'documentId': doc.id,
        'reportId': data['reportId'] ?? doc.id,
        'status': (data['status'] ?? 'pending').toString(),
        'statusBanding': (data['statusBanding'] ?? '').toString(),
        'tanggalBanding': data['tanggalBanding'],
        'alasanBanding': (data['alasanBanding'] ?? '').toString(),
        'tindakanSaatIni': (data['tindakanSaatIni'] ?? '').toString(),
        'tindakanDipilih': (data['tindakanDipilih'] ?? '').toString(),
        'catatanAdmin': (data['catatanAdmin'] ?? '').toString(),
        'createdAt': data['createdAt'],
        'reportReason': (data['reportReason'] ?? '').toString(),
        'reportTag': (data['reportTag'] ?? '').toString(),
        'kategoriLaporan': (data['kategoriLaporan'] ?? '').toString(),
        'reportedMessages': _asListOfMaps(data['reportedMessages']),
        'reportedUserInfo': _asMap(data['reportedUserInfo']),
        'reporterInfo': _asMap(data['reporterInfo']),
      };
    }).toList();

    items.sort((a, b) {
      final aDate = _toDateTime(a['createdAt']);
      final bDate = _toDateTime(b['createdAt']);
      return bDate.compareTo(aDate);
    });

    return items;
  }

  Future<List<Map<String, dynamic>>> getReportsSubmittedByMe() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snap = await FirebaseFirestore.instance
        .collection('reports')
        .where('reporterUid', isEqualTo: uid)
        .get();

    final items = snap.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'documentId': doc.id,
      };
    }).toList();

    items.sort((a, b) {
      final aDate = _toDateTime(a['createdAt']);
      final bDate = _toDateTime(b['createdAt']);
      return bDate.compareTo(aDate);
    });

    return items;
  }

  Future<List<Map<String, dynamic>>> getAppealsAgainstMe() async {
    final reports = await getReportsAgainstMe();

    final appeals = reports.where((item) {
      final alasanBanding = (item['alasanBanding'] ?? '').toString().trim();
      final statusBanding = (item['statusBanding'] ?? '').toString().trim();
      final tanggalBanding = item['tanggalBanding'];

      return alasanBanding.isNotEmpty ||
          statusBanding.isNotEmpty ||
          tanggalBanding != null;
    }).toList();

    appeals.sort((a, b) {
      final aDate = _toDateTime(a['tanggalBanding'] ?? a['createdAt']);
      final bDate = _toDateTime(b['tanggalBanding'] ?? b['createdAt']);
      return bDate.compareTo(aDate);
    });

    return appeals;
  }

  Future<Map<String, dynamic>?> getLatestActiveAction() async {
    final reports = await getReportsAgainstMe();
    if (reports.isEmpty) return null;
    return reports.first;
  }

  Future<void> submitAppeal({
    required String documentId,
    required String alasanBanding,
    required String tindakanSaatIni,
    Map<String, dynamic>? reportSnapshot,
  }) async {
    final clean = alasanBanding.trim();

    if (clean.isEmpty) {
      throw Exception('Alasan banding tidak boleh kosong.');
    }

    await _reportsRef.doc(documentId).update({
      'alasanBanding': clean,
      'tanggalBanding': FieldValue.serverTimestamp(),
      'statusBanding': 'pending',
      'tindakanSaatIni': tindakanSaatIni,
      'reportSnapshot': reportSnapshot,
    });
  }

  bool canSubmitAppeal(Map<String, dynamic> item) {
    final statusBanding = (item['statusBanding'] ?? '').toString().toLowerCase();

    if (statusBanding.isEmpty) return true;
    if (statusBanding == 'ditolak') return true;

    return false;
  }

  String buildReporterName(Map<String, dynamic> item) {
    final reporterInfo = _asMap(item['reporterInfo']);
    final userData = _asMap(reporterInfo['userData']);

    return _firstNonEmpty([
      reporterInfo['displayName']?.toString(),
      userData['nickname']?.toString(),
      userData['fullName']?.toString(),
      reporterInfo['email']?.toString(),
    ], fallback: 'Pengguna lain');
  }

  String buildReportSourceLabel(Map<String, dynamic> item) {
    final sourceType = _firstNonEmpty([
      item['sourceType']?.toString(),
      item['targetType']?.toString(),
      item['contentType']?.toString(),
    ]).toLowerCase();

    if (sourceType.contains('diary')) return 'Diary Online';
    if (sourceType.contains('chat')) return 'Chat Anonim';

    final messages = _asListOfMaps(item['reportedMessages']);
    if (messages.isNotEmpty) return 'Chat Anonim';

    return 'Konten Pengguna';
  }

  String buildReportCategoryLabel(Map<String, dynamic> item) {
    return _firstNonEmpty([
      item['reportTag']?.toString(),
      item['kategoriLaporan']?.toString(),
      item['reportReason']?.toString(),
    ], fallback: 'Lainnya');
  }

  String buildReportContentLabel(Map<String, dynamic> item) {
    final evidenceText = buildEvidencePreviewText(item).trim();
    if (evidenceText.isNotEmpty &&
        evidenceText != 'Bukti laporan tidak tersedia.' &&
        evidenceText != 'Pesan tidak memiliki teks.') {
      return evidenceText;
    }

    if (isImageReport(item)) {
      return 'Pengguna mengirim gambar.';
    }

    return 'Isi laporan tidak tersedia.';
  }

  String buildReportTitle(Map<String, dynamic> item) {
    return buildReportSourceLabel(item);
  }

  String buildReportSummary(Map<String, dynamic> item) {
    return buildReportContentLabel(item);
  }

  List<Map<String, dynamic>> extractReportedMessages(Map<String, dynamic> item) {
    final raw = item['reportedMessages'];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }

  Map<String, dynamic>? getPrimaryEvidence(Map<String, dynamic> item) {
    final messages = extractReportedMessages(item);
    if (messages.isEmpty) return null;

    final imageFirst = messages.where((m) {
      final imageUrl = (m['imageUrl'] ?? m['mediaUrl'] ?? '').toString().trim();
      return imageUrl.isNotEmpty;
    });

    if (imageFirst.isNotEmpty) return imageFirst.first;
    return messages.first;
  }

  bool isImageReport(Map<String, dynamic> item) {
    final evidence = getPrimaryEvidence(item);
    if (evidence == null) return false;

    final imageUrl = (evidence['imageUrl'] ?? evidence['mediaUrl'] ?? '')
        .toString()
        .trim();

    return imageUrl.isNotEmpty;
  }

  String buildEvidencePreviewText(Map<String, dynamic> item) {
    final evidence = getPrimaryEvidence(item);
    if (evidence == null) return 'Bukti laporan tidak tersedia.';

    final text = (evidence['text'] ?? evidence['messageText'] ?? '')
        .toString()
        .trim();

    if (text.isNotEmpty) return text;
    if (isImageReport(item)) return 'Pengguna mengirim gambar.';
    return 'Pesan tidak memiliki teks.';
  }

  String buildEvidenceImageUrl(Map<String, dynamic> item) {
    final evidence = getPrimaryEvidence(item);
    if (evidence == null) return '';

    return (evidence['imageUrl'] ?? evidence['mediaUrl'] ?? '')
        .toString()
        .trim();
  }

  String buildAdminDecisionLabel(Map<String, dynamic> item) {
    final raw = (item['tindakanDipilih'] ??
            item['tindakanSaatIni'] ??
            item['actionType'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    switch (raw) {
      case 'batasi user':
      case 'batasi_user':
      case 'batasiuser':
      case 'warn_user':
        return 'Akun dibatasi';
      case 'ban sementara':
      case 'ban_sementara':
      case 'bansementara':
      case 'suspend_user':
        return 'Ban sementara';
      case 'ban permanen':
      case 'ban_permanen':
      case 'banpermanen':
      case 'permanent_ban':
        return 'Ban permanen';
      case 'cabut tindakan':
      case 'cabut_tindakan':
      case 'cabuttindakan':
        return 'Tindakan dicabut';
    }

    final status = (item['status'] ?? '').toString().trim().toLowerCase();
    if (status == 'pending' || status == 'diproses') {
      return 'Laporan sedang ditinjau';
    }
    if (status == 'selesai') {
      return 'Keputusan admin sudah tersedia';
    }
    if (status == 'ditolak') {
      return 'Laporan ditolak admin';
    }

    return 'Keputusan belum tersedia';
  }

  String buildAdminDecisionDescription(Map<String, dynamic> item) {
    final label = buildAdminDecisionLabel(item);

    switch (label) {
      case 'Akun dibatasi':
        return 'Akun masih bisa digunakan, tetapi ada pembatasan fitur tertentu dari admin.';
      case 'Ban sementara':
        return 'Akun tidak bisa menggunakan fitur terkait untuk sementara waktu sampai masa pembatasan selesai.';
      case 'Ban permanen':
        return 'Akun kehilangan akses ke fitur terkait secara permanen sampai ada keputusan admin berikutnya.';
      case 'Tindakan dicabut':
        return 'Keputusan sebelumnya dibatalkan dan pembatasan terhadap akun sudah dicabut.';
      default:
        return 'Belum ada penjelasan keputusan yang bisa ditampilkan.';
    }
  }

  String buildAppealSummary(Map<String, dynamic> item) {
    final alasanBanding = (item['alasanBanding'] ?? '').toString().trim();
    if (alasanBanding.isNotEmpty) return alasanBanding;
    return 'Banding belum memiliki isi.';
  }

  String buildReportStatusLabel(Map<String, dynamic> item) {
    final raw = (item['status'] ?? '').toString().trim().toLowerCase();

    switch (raw) {
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  String buildAppealStatusLabel(Map<String, dynamic> item) {
    final raw = (item['statusBanding'] ?? '').toString().trim().toLowerCase();

    switch (raw) {
      case 'pending':
        return 'Pending';
      case 'disetujui':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Belum ada banding';
    }
  }

  String buildCurrentActionLabel(Map<String, dynamic> item) {
    final tindakanDipilih = (item['tindakanDipilih'] ?? '').toString().trim();
    final tindakanSaatIni = (item['tindakanSaatIni'] ?? '').toString().trim();

    if (tindakanDipilih.isNotEmpty) {
      return _beautifyAction(tindakanDipilih);
    }

    if (tindakanSaatIni.isNotEmpty) {
      return _beautifyAction(tindakanSaatIni);
    }

    final status = (item['status'] ?? '').toString().trim().toLowerCase();

    switch (status) {
      case 'pending':
        return 'Laporan sedang ditinjau';
      case 'diproses':
        return 'Laporan sedang diproses';
      case 'selesai':
        return 'Keputusan admin sudah tersedia';
      case 'ditolak':
        return 'Laporan ditolak admin';
      default:
        return 'Belum ada tindakan admin';
    }
  }

  String _beautifyAction(String raw) {
    switch (raw) {
      case 'batasiUser':
        return 'Akun dibatasi';
      case 'banSementara':
        return 'Ban sementara';
      case 'banPermanen':
        return 'Ban permanen';
      case 'cabutTindakan':
        return 'Tindakan dicabut';
      default:
        return raw;
    }
  }
}