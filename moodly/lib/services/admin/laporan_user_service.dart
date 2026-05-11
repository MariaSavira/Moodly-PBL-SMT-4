import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/admin/laporan_user_model.dart';

class LaporanUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LaporanUserModel>> getLaporanUser() async {
    final snapshot = await _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(_fromChatReport).toList();
  }

  LaporanUserModel _fromChatReport(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final reportedMessages = data['reportedMessages'];
    final reporterInfo = data['reporterInfo'];
    final reportedUserInfo = data['reportedUserInfo'];

    return LaporanUserModel(
      documentId: doc.id,
      id: data['reportId'] ?? doc.id,
      tipeKonten: 'Chat Anonim',
      namaPelapor: _getName(reporterInfo),
      namaTerlapor: _getName(reportedUserInfo),
      avatarTerlapor: _getAvatar(reportedUserInfo),
      tanggal: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: laporanStatusFromString(data['status'] ?? 'pending'),
      isiLaporan: _getIsiLaporan(reportedMessages),
      catatanAdmin: data['catatanAdmin'] ?? '',
      imageUrls: _getImageUrls(reportedMessages),
    );
  }

  String _getName(dynamic info) {
    if (info is Map<String, dynamic>) {
      final userData = info['userData'];

      if (userData is Map<String, dynamic>) {
        return userData['fullName'] ??
            info['displayName'] ??
            userData['email'] ??
            userData['nickname'] ??
            '-';
      }

      return info['displayName'] ?? '-';
    }

    return '-';
  }

  String _getAvatar(dynamic info) {
    if (info is Map<String, dynamic>) {
      final userData = info['userData'];

      if (userData is Map<String, dynamic>) {
        return userData['avatarId'] ?? '';
      }
    }

    return '';
  }

  String _getIsiLaporan(dynamic reportedMessages) {
    if (reportedMessages is! List || reportedMessages.isEmpty) {
      return 'Konten tidak tersedia';
    }

    final List<String> isi = [];

    for (final message in reportedMessages) {
      if (message is Map<String, dynamic>) {
        final type = message['type'];
        final text = message['text'];
        final imageUrl = message['imageUrl'];

        if (type == 'text' &&
            text != null &&
            text.toString().trim().isNotEmpty) {
          isi.add(text.toString());
        } else if (type == 'image' &&
            imageUrl != null &&
            imageUrl.toString().trim().isNotEmpty) {
          isi.add('[Gambar dilaporkan]');
        } else {
          isi.add('[Konten dilaporkan]');
        }
      }
    }

    return isi.join('\n');
  }

  List<String> _getImageUrls(dynamic reportedMessages) {
  if (reportedMessages is! List || reportedMessages.isEmpty) {
    return [];
  }

  final List<String> urls = [];

  for (final message in reportedMessages) {
    if (message is Map<String, dynamic>) {
      final imageUrl = message['imageUrl'];

      if (imageUrl != null && imageUrl.toString().trim().isNotEmpty) {
        urls.add(imageUrl.toString());
      }
    }
  }

  return urls;
}

  Future<void> updateStatusLaporan({
    required String documentId,
    required LaporanStatus status,
    String? catatanAdmin,
  }) async {
    await _firestore.collection('reports').doc(documentId).update({
      'status': status.value,
      if (catatanAdmin != null) 'catatanAdmin': catatanAdmin,
    });
  }
}