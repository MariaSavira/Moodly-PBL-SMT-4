import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../pages/setting/moodly_settings_support.dart';

class UserAppealService {
  UserAppealService._();

  static final UserAppealService instance = UserAppealService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  bool get _isEnglish => MoodlySettingsPrefs.currentLanguageCode == 'en';

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

  dynamic _pick(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) return value;
    }
    return null;
  }

  String _pickString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    final value = _pick(data, keys);
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _mergedDocsByEquality({
    required String camelField,
    required String snakeField,
    required String value,
  }) async {
    final snapCamel = await _reportsRef.where(camelField, isEqualTo: value).get();
    final snapSnake = await _reportsRef.where(snakeField, isEqualTo: value).get();

    final merged = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final doc in snapCamel.docs) {
      merged[doc.id] = doc;
    }
    for (final doc in snapSnake.docs) {
      merged[doc.id] = doc;
    }

    return merged.values.toList();
  }

  Map<String, dynamic> _normalizeReporterInfo(Map<String, dynamic> data) {
    final reporterInfo = _asMap(data['reporterInfo']);
    if (reporterInfo.isNotEmpty) return reporterInfo;

    return {
      'uid': _pickString(data, ['reporterUid', 'reported_by_uid']),
      'displayName': _pickString(data, ['reported_by_username']),
      'email': _pickString(data, ['reporterEmail']),
      'userData': {
        'nickname': _pickString(data, ['reported_by_username']),
        'fullName': _pickString(data, ['reported_by_username']),
      },
    };
  }

  Map<String, dynamic> _normalizeReportedUserInfo(Map<String, dynamic> data) {
    final reportedUserInfo = _asMap(data['reportedUserInfo']);
    if (reportedUserInfo.isNotEmpty) return reportedUserInfo;

    return {
      'uid': _pickString(data, ['reportedUid', 'reported_uid']),
      'displayName': _pickString(data, ['reported_user']),
      'photoUrl': _pickString(data, ['reported_profile']),
      'userData': {
        'nickname': _pickString(data, ['reported_user']),
        'fullName': _pickString(data, ['reported_user']),
        'photoUrl': _pickString(data, ['reported_profile']),
      },
    };
  }

  Map<String, dynamic> _normalizeItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return {
      'documentId': doc.id,
      'reportId': _pickString(data, ['reportId', 'report_id'], fallback: doc.id),
      'status': _pickString(data, ['status'], fallback: 'pending'),
      'statusBanding': _pickString(data, ['statusBanding']),
      'tanggalBanding': _pick(data, ['tanggalBanding']),
      'alasanBanding': _pickString(data, ['alasanBanding']),
      'tindakanSaatIni': _pickString(data, ['tindakanSaatIni', 'actionType']),
      'tindakanDipilih': _pickString(data, ['tindakanDipilih']),
      'catatanAdmin': _pickString(data, ['catatanAdmin']),
      'createdAt': _pick(data, ['createdAt', 'created_at']),
      'reportReason': _pickString(
        data,
        ['reportReason', 'report_reason', 'alasanLaporan'],
      ),
      'reportTag': _pickString(
        data,
        ['reportTag', 'report_category', 'kategoriLaporan'],
      ),
      'kategoriLaporan': _pickString(
        data,
        ['kategoriLaporan', 'report_category', 'reportTag'],
      ),
      'reportedMessages': _asListOfMaps(_pick(data, ['reportedMessages'])),
      'reportedUserInfo': _normalizeReportedUserInfo(data),
      'reporterInfo': _normalizeReporterInfo(data),
      'sourceType': _pickString(data, ['sourceType', 'type']),
      'targetType': _pickString(data, ['targetType']),
      'contentType': _pickString(data, ['contentType', 'type']),
      'reportedUid': _pickString(data, ['reportedUid', 'reported_uid']),
      'reporterUid': _pickString(data, ['reporterUid', 'reported_by_uid']),
      'raw': data,
    };
  }

  Future<List<Map<String, dynamic>>> getReportsAgainstMe() async {
    final uid = _uid;
    if (uid == null) return [];

    final docs = await _mergedDocsByEquality(
      camelField: 'reportedUid',
      snakeField: 'reported_uid',
      value: uid,
    );

    final items = docs.map(_normalizeItem).toList();

    items.sort((a, b) {
      final aDate = _toDateTime(a['createdAt']);
      final bDate = _toDateTime(b['createdAt']);
      return bDate.compareTo(aDate);
    });

    return items;
  }

  Future<List<Map<String, dynamic>>> getReportsSubmittedByMe() async {
    final uid = _uid;
    if (uid == null) return [];

    final docs = await _mergedDocsByEquality(
      camelField: 'reporterUid',
      snakeField: 'reported_by_uid',
      value: uid,
    );

    final items = docs.map(_normalizeItem).toList();

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
      throw Exception(_isEnglish
          ? 'Appeal reason cannot be empty.'
          : 'Alasan banding tidak boleh kosong.');
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
    final statusBanding =
        (item['statusBanding'] ?? '').toString().trim().toLowerCase();

    if (statusBanding.isEmpty) return true;
    if (statusBanding == 'ditolak') return true;

    return false;
  }

  String buildReporterName(Map<String, dynamic> item) {
    final reporterInfo = _asMap(item['reporterInfo']);
    final userData = _asMap(reporterInfo['userData']);

    return _firstNonEmpty(
      [
        reporterInfo['displayName']?.toString(),
        userData['nickname']?.toString(),
        userData['fullName']?.toString(),
        reporterInfo['email']?.toString(),
      ],
      fallback: _isEnglish ? 'Another user' : 'Pengguna lain',
    );
  }

  String buildReportSourceLabel(Map<String, dynamic> item) {
    final sourceType = _firstNonEmpty([
      item['sourceType']?.toString(),
      item['targetType']?.toString(),
      item['contentType']?.toString(),
    ]).toLowerCase();

    if (sourceType.contains('diary')) {
      return _isEnglish ? 'Online Diary' : 'Diary Online';
    }
    if (sourceType.contains('chat')) {
      return _isEnglish ? 'Anonymous Chat' : 'Chat Anonim';
    }
    if (sourceType.contains('comment')) {
      return _isEnglish ? 'Comment' : 'Komentar';
    }

    final messages = _asListOfMaps(item['reportedMessages']);
    if (messages.isNotEmpty) {
      return _isEnglish ? 'Anonymous Chat' : 'Chat Anonim';
    }

    return _isEnglish ? 'User Content' : 'Konten Pengguna';
  }

  String buildReportCategoryLabel(Map<String, dynamic> item) {
    return _firstNonEmpty(
      [
        item['reportTag']?.toString(),
        item['kategoriLaporan']?.toString(),
        item['reportReason']?.toString(),
      ],
      fallback: _isEnglish ? 'Other' : 'Lainnya',
    );
  }

  String buildReportContentLabel(Map<String, dynamic> item) {
    final evidenceText = buildEvidencePreviewText(item).trim();
    if (evidenceText.isNotEmpty &&
        evidenceText != 'Bukti laporan tidak tersedia.' &&
        evidenceText != 'Pesan tidak memiliki teks.' &&
        evidenceText != 'Report evidence is not available.' &&
        evidenceText != 'The message has no text.') {
      return evidenceText;
    }

    if (isImageReport(item)) {
      return _isEnglish
          ? 'The user sent an image.'
          : 'Pengguna mengirim gambar.';
    }

    return _isEnglish
        ? 'Report content is not available.'
        : 'Isi laporan tidak tersedia.';
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
    if (evidence == null) {
      return _isEnglish
          ? 'Report evidence is not available.'
          : 'Bukti laporan tidak tersedia.';
    }

    final text = (evidence['text'] ?? evidence['messageText'] ?? '')
        .toString()
        .trim();

    if (text.isNotEmpty) return text;
    if (isImageReport(item)) {
      return _isEnglish
          ? 'The user sent an image.'
          : 'Pengguna mengirim gambar.';
    }
    return _isEnglish ? 'The message has no text.' : 'Pesan tidak memiliki teks.';
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
        return _isEnglish ? 'Restricted account' : 'Akun dibatasi';
      case 'ban sementara':
      case 'ban_sementara':
      case 'bansementara':
      case 'suspend_user':
        return _isEnglish ? 'Temporary ban' : 'Ban sementara';
      case 'ban permanen':
      case 'ban_permanen':
      case 'banpermanen':
      case 'permanent_ban':
        return _isEnglish ? 'Permanent ban' : 'Ban permanen';
      case 'cabut tindakan':
      case 'cabut_tindakan':
      case 'cabuttindakan':
        return _isEnglish ? 'Action revoked' : 'Tindakan dicabut';
    }

    final status = (item['status'] ?? '').toString().trim().toLowerCase();
    if (status == 'pending' || status == 'diproses') {
      return _isEnglish
          ? 'The report is under review'
          : 'Laporan sedang ditinjau';
    }
    if (status == 'selesai') {
      return _isEnglish
          ? 'An admin decision is available'
          : 'Keputusan admin sudah tersedia';
    }
    if (status == 'ditolak') {
      return _isEnglish ? 'The report was rejected' : 'Laporan ditolak admin';
    }

    return _isEnglish
        ? 'Decision not available yet'
        : 'Keputusan belum tersedia';
  }

  String buildAdminDecisionDescription(Map<String, dynamic> item) {
    final label = buildAdminDecisionLabel(item);

    switch (label) {
      case 'Akun dibatasi':
      case 'Restricted account':
        return _isEnglish
            ? 'The account can still be used, but certain features are restricted by the admin.'
            : 'Akun masih bisa digunakan, tetapi ada pembatasan fitur tertentu dari admin.';
      case 'Ban sementara':
      case 'Temporary ban':
        return _isEnglish
            ? 'The account cannot use the related feature temporarily until the restriction period ends.'
            : 'Akun tidak bisa menggunakan fitur terkait untuk sementara waktu sampai masa pembatasan selesai.';
      case 'Ban permanen':
      case 'Permanent ban':
        return _isEnglish
            ? 'The account loses access to the related feature permanently until there is another admin decision.'
            : 'Akun kehilangan akses ke fitur terkait secara permanen sampai ada keputusan admin berikutnya.';
      case 'Tindakan dicabut':
      case 'Action revoked':
        return _isEnglish
            ? 'The previous decision was canceled and the restriction has been removed.'
            : 'Keputusan sebelumnya dibatalkan dan pembatasan terhadap akun sudah dicabut.';
      default:
        return _isEnglish
            ? 'No decision description is available yet.'
            : 'Belum ada penjelasan keputusan yang bisa ditampilkan.';
    }
  }

  String buildAppealSummary(Map<String, dynamic> item) {
    final alasanBanding = (item['alasanBanding'] ?? '').toString().trim();
    if (alasanBanding.isNotEmpty) return alasanBanding;
    return _isEnglish
        ? 'The appeal does not have content yet.'
        : 'Banding belum memiliki isi.';
  }

  String buildReportStatusLabel(Map<String, dynamic> item) {
    final raw = (item['status'] ?? '').toString().trim().toLowerCase();

    switch (raw) {
      case 'diproses':
        return _isEnglish ? 'In Progress' : 'Diproses';
      case 'selesai':
        return _isEnglish ? 'Completed' : 'Selesai';
      case 'ditolak':
        return _isEnglish ? 'Rejected' : 'Ditolak';
      case 'pending':
      default:
        return _isEnglish ? 'Pending' : 'Pending';
    }
  }

  String buildAppealStatusLabel(Map<String, dynamic> item) {
    final raw = (item['statusBanding'] ?? '').toString().trim().toLowerCase();

    switch (raw) {
      case 'pending':
        return _isEnglish ? 'Pending' : 'Pending';
      case 'disetujui':
        return _isEnglish ? 'Approved' : 'Disetujui';
      case 'ditolak':
        return _isEnglish ? 'Rejected' : 'Ditolak';
      default:
        return _isEnglish ? 'No appeal yet' : 'Belum ada banding';
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
        return _isEnglish
            ? 'The report is under review'
            : 'Laporan sedang ditinjau';
      case 'diproses':
        return _isEnglish
            ? 'The report is being processed'
            : 'Laporan sedang diproses';
      case 'selesai':
        return _isEnglish
            ? 'An admin decision is available'
            : 'Keputusan admin sudah tersedia';
      case 'ditolak':
        return _isEnglish ? 'The report was rejected' : 'Laporan ditolak admin';
      default:
        return _isEnglish
            ? 'There is no admin action yet'
            : 'Belum ada tindakan admin';
    }
  }

  String _beautifyAction(String raw) {
    switch (raw) {
      case 'batasiUser':
      case 'batasi user':
      case 'batasi_user':
        return _isEnglish ? 'Restricted account' : 'Akun dibatasi';
      case 'banSementara':
      case 'ban sementara':
      case 'ban_sementara':
        return _isEnglish ? 'Temporary ban' : 'Ban sementara';
      case 'banPermanen':
      case 'ban permanen':
      case 'ban_permanen':
        return _isEnglish ? 'Permanent ban' : 'Ban permanen';
      case 'cabutTindakan':
      case 'cabut tindakan':
      case 'cabut_tindakan':
        return _isEnglish ? 'Action revoked' : 'Tindakan dicabut';
      default:
        return raw;
    }
  }
}