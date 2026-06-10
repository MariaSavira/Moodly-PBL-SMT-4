import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/admin/ajuan_banding_model.dart';

class AjuanBandingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AjuanBandingModel>> getAjuanBanding() async {
    final snapshot = await _firestore
        .collection('reports')
        .where('alasanBanding', isNotEqualTo: null)
        .get();

    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          final alasanBanding = data['alasanBanding'];

          return alasanBanding != null &&
              alasanBanding.toString().trim().isNotEmpty;
        })
        .map((doc) => AjuanBandingModel.fromFirestore(doc))
        .toList();
  }

  bool _isTemporaryAction(TindakanUser? tindakan) {
    return tindakan?.value == 'banSementara';
  }

  Future<void> updateStatusAjuanBanding({
    required String documentId,
    required AjuanBandingStatus status,
    String? catatanAdmin,
    TindakanUser? tindakanDipilih,
    DateTime? banUntil,
  }) async {
    final payload = <String, dynamic>{
      'statusBanding': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (catatanAdmin != null) {
      payload['catatanAdmin'] = catatanAdmin;
    }

    if (tindakanDipilih != null) {
      payload['tindakanDipilih'] = tindakanDipilih.value;
      payload['tindakanSaatIni'] = tindakanDipilih.value;
      payload['actionUpdatedAt'] = FieldValue.serverTimestamp();
    }

    if (_isTemporaryAction(tindakanDipilih)) {
      if (banUntil != null) {
        payload['banUntil'] = Timestamp.fromDate(banUntil);
      }
    } else if (tindakanDipilih != null) {
      payload['banUntil'] = FieldValue.delete();
    }

    await _firestore.collection('reports').doc(documentId).update(payload);
  }
}