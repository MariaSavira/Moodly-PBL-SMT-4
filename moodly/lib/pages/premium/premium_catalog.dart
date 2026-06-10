enum PremiumEntrySource {
  home,
  chatGender,
  moodAnalysisLocked,
}

class PremiumBillingOption {
  final String id;
  final int months;
  final int monthlyPrice;
  final int discountPercent;

  const PremiumBillingOption({
    required this.id,
    required this.months,
    required this.monthlyPrice,
    required this.discountPercent,
  });

  int get normalPrice => monthlyPrice * months;

  int get totalPrice =>
      ((monthlyPrice * months) * (100 - discountPercent) / 100).round();

  int get savedAmount => normalPrice - totalPrice;
}

class PremiumFeatureRow {
  final String emoji;
  final String titleId;
  final String titleEn;
  final String freeId;
  final String freeEn;
  final String premiumId;
  final String premiumEn;
  final String studentId;
  final String studentEn;

  const PremiumFeatureRow({
    required this.emoji,
    required this.titleId,
    required this.titleEn,
    required this.freeId,
    required this.freeEn,
    required this.premiumId,
    required this.premiumEn,
    required this.studentId,
    required this.studentEn,
  });

  String title(String languageCode) =>
      languageCode == 'en' ? titleEn : titleId;

  String freeText(String languageCode) =>
      languageCode == 'en' ? freeEn : freeId;

  String premiumText(String languageCode) =>
      languageCode == 'en' ? premiumEn : premiumId;

  String studentText(String languageCode) =>
      languageCode == 'en' ? studentEn : studentId;
}

const int kMoodlyPremiumMonthlyPrice = 35000;
const int kMoodlyStudentMonthlyPrice = 15000;

const List<PremiumBillingOption> kPremiumBillingOptions = [
  PremiumBillingOption(
    id: 'monthly',
    months: 1,
    monthlyPrice: kMoodlyPremiumMonthlyPrice,
    discountPercent: 0,
  ),
  PremiumBillingOption(
    id: 'semester',
    months: 6,
    monthlyPrice: kMoodlyPremiumMonthlyPrice,
    discountPercent: 5,
  ),
  PremiumBillingOption(
    id: 'yearly',
    months: 12,
    monthlyPrice: kMoodlyPremiumMonthlyPrice,
    discountPercent: 15,
  ),
];

const List<PremiumFeatureRow> kPremiumFeatureRows = [
  PremiumFeatureRow(
    emoji: '💗',
    titleId: 'Mood Harian',
    titleEn: 'Daily Mood',
    freeId: 'Catat mood harian, lihat ringkasan dasar.',
    freeEn: 'Log your daily mood and view a basic summary.',
    premiumId:
        'Insight lebih detail, riwayat lebih panjang, rekomendasi lebih personal.',
    premiumEn:
        'More detailed insights, longer history, and more personal recommendations.',
    studentId:
        'Insight lebih detail, riwayat lebih panjang, rekomendasi lebih personal.',
    studentEn:
        'More detailed insights, longer history, and more personal recommendations.',
  ),
  PremiumFeatureRow(
    emoji: '📔',
    titleId: 'Diary Online',
    titleEn: 'Online Diary',
    freeId: 'Tulis diary private, akses diary public dasar.',
    freeEn: 'Write private diaries and access the basic public diary.',
    premiumId: 'Tersedia penuh untuk semua user.',
    premiumEn: 'Fully available for all users.',
    studentId: 'Tersedia penuh untuk semua user.',
    studentEn: 'Fully available for all users.',
  ),
  PremiumFeatureRow(
    emoji: '⭐',
    titleId: 'Afirmasi Harian',
    titleEn: 'Daily Affirmations',
    freeId: 'Afirmasi harian standar.',
    freeEn: 'Standard daily affirmations.',
    premiumId:
        'Lihat lebih banyak afirmasi, hilangkan limitasi, variasi lebih banyak.',
    premiumEn:
        'See more affirmations, remove limitations, and get more variety.',
    studentId:
        'Lihat lebih banyak afirmasi, hilangkan limitasi, variasi lebih banyak.',
    studentEn:
        'See more affirmations, remove limitations, and get more variety.',
  ),
  PremiumFeatureRow(
    emoji: '💬',
    titleId: 'Chat Anonim',
    titleEn: 'Anonymous Chat',
    freeId: 'Akses ruang curhat anonim.',
    freeEn: 'Access the anonymous chat space.',
    premiumId: 'Buka filter gender agar pengalaman curhat lebih nyaman.',
    premiumEn:
        'Unlock gender filter for a more comfortable anonymous chat experience.',
    studentId: 'Buka filter gender agar pengalaman curhat lebih nyaman.',
    studentEn:
        'Unlock gender filter for a more comfortable anonymous chat experience.',
  ),
  PremiumFeatureRow(
    emoji: '📊',
    titleId: 'Statistik Mood',
    titleEn: 'Mood Statistics',
    freeId: 'Statistik perkembangan mood dasar.',
    freeEn: 'Basic mood progress statistics.',
    premiumId:
        'Rekap mingguan/bulanan lebih cantik, insight lebih mendalam.',
    premiumEn: 'More polished weekly/monthly recaps with deeper insights.',
    studentId:
        'Rekap mingguan/bulanan lebih cantik, insight lebih mendalam.',
    studentEn: 'More polished weekly/monthly recaps with deeper insights.',
  ),
  PremiumFeatureRow(
    emoji: '🔥',
    titleId: 'Streak & Poin',
    titleEn: 'Streak & Points',
    freeId: 'Ikut streak, dapat poin harian, 1 freeze streak awal.',
    freeEn: 'Join streaks, earn daily points, and get 1 starter streak freeze.',
    premiumId:
        'Bonus poin saat berlangganan, tambahan freeze streak, reward progression lebih kaya.',
    premiumEn:
        'Subscription point bonus, extra streak freeze, and richer reward progression.',
    studentId:
        'Bonus poin saat berlangganan, tambahan freeze streak, reward progression lebih kaya.',
    studentEn:
        'Subscription point bonus, extra streak freeze, and richer reward progression.',
  ),
  PremiumFeatureRow(
    emoji: '🚨',
    titleId: 'Bantuan & Dukungan',
    titleEn: 'Help & Support',
    freeId: 'Tombol bantuan darurat dan arahan bantuan profesional.',
    freeEn: 'Emergency support button and professional help guidance.',
    premiumId: 'Tetap tersedia penuh untuk semua user.',
    premiumEn: 'Still fully available for all users.',
    studentId: 'Tetap tersedia penuh untuk semua user.',
    studentEn: 'Still fully available for all users.',
  ),
];

String formatRupiah(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  int counter = 0;

  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
    counter++;
    if (counter % 3 == 0 && i != 0) {
      buffer.write('.');
    }
  }

  return 'Rp${buffer.toString().split('').reversed.join()}';
}