import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/admin/ajuan_banding_model.dart';

class AjuanBandingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AjuanBandingModel>> getAjuanBanding() async {
    final snapshot = await _firestore.collection('reports').get();

    return snapshot.docs
        .map((doc) => AjuanBandingModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateStatusAjuanBanding({
  required String documentId,
  required AjuanBandingStatus status,
  String? catatanAdmin,
  TindakanUser? tindakanDipilih,
}) async {
  await _firestore.collection('reports').doc(documentId).update({
    'statusBanding': status.value,
    if (catatanAdmin != null) 'catatanAdmin': catatanAdmin,
    if (tindakanDipilih != null) 'tindakanDipilih': tindakanDipilih.value,
  });
}
}