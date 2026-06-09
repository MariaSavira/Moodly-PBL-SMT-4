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

const int kMoodlyPremiumMonthlyPrice = 25000;

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
        'Insight premium untuk mahasiswa, dengan verifikasi email kampus.',
    studentEn:
        'Premium insights for students with campus email verification.',
  ),
  PremiumFeatureRow(
    emoji: '📔',
    titleId: 'Diary Online',
    titleEn: 'Online Diary',
    freeId: 'Tulis diary private, akses diary public dasar.',
    freeEn: 'Write private diaries and access the basic public diary.',
    premiumId:
        'Template refleksi eksklusif, highlight tulisan favorit, organisasi lebih nyaman.',
    premiumEn:
        'Exclusive reflection templates, favorite highlights, and better organization.',
    studentId:
        'Benefit diary premium versi mahasiswa, lebih nyaman untuk refleksi rutin.',
    studentEn:
        'Student premium diary benefits for more comfortable routine reflection.',
  ),
  PremiumFeatureRow(
    emoji: '⭐',
    titleId: 'Afirmasi Harian',
    titleEn: 'Daily Affirmations',
    freeId: 'Afirmasi harian standar.',
    freeEn: 'Standard daily affirmations.',
    premiumId:
        'Koleksi afirmasi premium, pack tematik, variasi lebih banyak.',
    premiumEn:
        'Premium affirmation collections, themed packs, and more variety.',
    studentId:
        'Afirmasi premium mahasiswa, fokus semangat belajar dan self-care.',
    studentEn:
        'Student-focused premium affirmations for study motivation and self-care.',
  ),
  PremiumFeatureRow(
    emoji: '💬',
    titleId: 'Chat Anonim',
    titleEn: 'Anonymous Chat',
    freeId: 'Akses ruang curhat anonim.',
    freeEn: 'Access the anonymous chat space.',
    premiumId:
        'Filter gender, bonus poin ringan, dan benefit prioritas kecil.',
    premiumEn:
        'Gender filter, light point bonuses, and small priority benefits.',
    studentId:
        'Benefit chat premium mahasiswa, cocok untuk ruang cerita yang lebih relevan.',
    studentEn:
        'Student premium chat benefits for more relevant matching spaces.',
  ),
  PremiumFeatureRow(
    emoji: '📊',
    titleId: 'Statistik Mood',
    titleEn: 'Mood Statistics',
    freeId: 'Statistik perkembangan mood dasar.',
    freeEn: 'Basic mood progress statistics.',
    premiumId:
        'Rekap mingguan dan bulanan lebih cantik, insight lebih mendalam.',
    premiumEn:
        'Nicer weekly and monthly recap with deeper insights.',
    studentId:
        'Akses statistik premium mahasiswa dengan insight yang lebih lengkap.',
    studentEn:
        'Student premium statistics with richer insights.',
  ),
  PremiumFeatureRow(
    emoji: '🔥',
    titleId: 'Streak & Poin',
    titleEn: 'Streak & Points',
    freeId: 'Ikut streak, dapat poin harian, 1 freeze awal.',
    freeEn: 'Join streaks, earn daily points, and get 1 starter freeze.',
    premiumId:
        'Bonus poin saat berlangganan, tambahan freeze streak, progression reward lebih kaya.',
    premiumEn:
        'Subscription point bonus, extra streak freeze, and richer reward progression.',
    studentId:
        'Benefit streak premium mahasiswa dengan bonus kecil untuk tetap konsisten.',
    studentEn:
        'Student premium streak benefits with small extras to stay consistent.',
  ),
  PremiumFeatureRow(
    emoji: '🚨',
    titleId: 'Bantuan & Dukungan',
    titleEn: 'Help & Support',
    freeId: 'Tetap tersedia penuh untuk semua user.',
    freeEn: 'Still fully available for all users.',
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