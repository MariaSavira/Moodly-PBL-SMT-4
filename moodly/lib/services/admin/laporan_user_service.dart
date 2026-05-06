import '../../models/admin/laporan_user_model.dart';

class LaporanUserService {
  Future<List<LaporanUserModel>> getLaporanUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      LaporanUserModel(
        id: 'LP-0005',
        tipeKonten: 'Chat Anonim',
        namaPelapor: 'Admin',
        namaTerlapor: 'User123',
        tanggal: DateTime(2026, 4, 9),
        status: LaporanStatus.pending,
        isiLaporan: 'aku capek sama semuanya...',
      ),
      LaporanUserModel(
        id: 'LP-0004',
        tipeKonten: 'Diary Online',
        namaPelapor: 'Admin',
        namaTerlapor: 'User124',
        tanggal: DateTime(2026, 4, 9),
        status: LaporanStatus.selesai,
        isiLaporan: 'hidup ini ga adil...',
      ),
      LaporanUserModel(
        id: 'LP-0003',
        tipeKonten: 'Chat Anonim',
        namaPelapor: 'Admin',
        namaTerlapor: 'User123',
        tanggal: DateTime(2026, 4, 6),
        status: LaporanStatus.selesai,
        isiLaporan: 'semangat ya, kamu bisa!',
      ),
    ];
  }
}