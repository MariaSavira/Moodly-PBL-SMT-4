import '../../models/admin/ajuan_banding_model.dart';

class AjuanBandingService {
  Future<List<AjuanBandingModel>> getAjuanBanding() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      AjuanBandingModel(
        id: 'BD-0021',
        username: 'UserXyz',
        jenisBan: 'Ban Sementara',
        alasanBanding:
            'Tidak sengaja, aku hanya berbagi cerita pribadi....',
        tanggal: DateTime(2026, 4, 10),
        status: AjuanBandingStatus.pending,
      ),
      AjuanBandingModel(
        id: 'BD-0020',
        username: 'UserAbc',
        jenisBan: 'Ban Permanen',
        alasanBanding:
            'Saya menyesal dan janji tidak akan mengulangi ....',
        tanggal: DateTime(2026, 4, 9),
        status: AjuanBandingStatus.disetujui,
      ),
      AjuanBandingModel(
        id: 'BD-0019',
        username: 'UserNaa',
        jenisBan: 'Ban Permanen',
        alasanBanding:
            'Saya menyesal dan janji tidak akan mengulangi ....',
        tanggal: DateTime(2026, 4, 8),
        status: AjuanBandingStatus.ditolak,
      ),
    ];
  }
}