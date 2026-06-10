import 'package:flutter/material.dart';

import '../pages.dart';
import '../setting/moodly_settings_support.dart';

class MoodInsightDetail extends StatefulWidget {
  final String periodLabel;
  final Map<String, int> moodStats;
  final int recordedCount;
  final double consistencyRate;
  final String dominantMoodRaw;
  final bool isPremiumContext;

  const MoodInsightDetail({
    super.key,
    required this.periodLabel,
    required this.moodStats,
    required this.recordedCount,
    required this.consistencyRate,
    required this.dominantMoodRaw,
    this.isPremiumContext = false,
  });

  @override
  State<MoodInsightDetail> createState() => _MoodInsightDetailState();
}

class _MoodInsightDetailState extends State<MoodInsightDetail> {
  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Insight Mood',
      'moodSenang': 'Senang',
      'moodNetral': 'Netral',
      'moodSedih': 'Sedih',
      'moodMarah': 'Marah',
      'heroTitle': 'Pola emosimu sedang bercerita',
      'heroSub':
          'Dari mood yang kamu catat, halaman ini merangkum ritme yang paling terasa dan hal kecil yang layak kamu jaga.',
      'periodLabel': 'Periode',
      'dominantLabel': 'Mood dominan',
      'recordedLabel': 'Hari tercatat',
      'consistencyLabel': 'Konsistensi',
      'mainReadTitle': 'Yang terbaca dari periode ini',
      'emptySummary':
          'Belum ada cukup data untuk membaca pola. Tidak apa-apa, mulai dari satu check-in dulu saja.',
      'warmSummary':
          'Periode ini cenderung hangat. Ada tanda bahwa ritmemu sedang lebih ringan dan aman.',
      'neutralSummary':
          'Periode ini cenderung netral. Tidak terlalu tinggi, tidak terlalu jatuh. Kadang tenang itu juga kemajuan.',
      'heavySummary':
          'Periode ini terasa lebih berat. Fokus ke langkah kecil lebih realistis daripada memaksa semuanya langsung pulih.',
      'mixedSummary':
          'Periode ini campur. Ada hari yang ringan dan ada yang berat, jadi pola jeda dan pemicu mulai penting dibaca.',
      'visualTitle': 'Mood utama',
      'visualWarm': 'Ritme terlihat cukup hangat',
      'visualNeutral': 'Ritme terlihat tenang',
      'visualHeavy': 'Ritme terlihat lebih berat',
      'visualMixed': 'Ritme terlihat campur',
      'activityTitle': 'Saran aktivitas yang lebih relevan',
      'activitySub':
          'Saran ini sengaja dibuat ringan dan realistis.',
      'promptTitle': 'Coba refleksikan ini',
      'prompt1Warm':
          'Hal kecil apa yang paling membantu kamu merasa lebih ringan belakangan ini?',
      'prompt2Warm':
          'Kebiasaan baik mana yang ingin kamu pertahankan minggu depan?',
      'prompt1Neutral':
          'Adakah kebutuhan tubuh atau pikiran yang diam-diam kamu abaikan?',
      'prompt2Neutral':
          'Apa satu hal kecil yang bisa bikin harimu terasa sedikit lebih hidup?',
      'prompt1Heavy':
          'Apa yang paling sering membuat energimu turun akhir-akhir ini?',
      'prompt2Heavy':
          'Siapa atau aktivitas apa yang paling aman saat harimu terasa berat?',
      'prompt1Mixed':
          'Momen seperti apa yang biasanya muncul sebelum mood-mu berubah?',
      'prompt2Mixed':
          'Kalau harus menjaga satu pola yang baik, itu yang mana?',
      'openDiary': 'Lanjut tulis di diary',
      'back': 'Kembali',
      'premiumBadge': 'Refleksi mendalam',
      'regularBadge': 'Ringkasan refleksi',
      'sleepTitle': 'Tidur lebih teratur',
      'sleepDesc':
          'Rapikan jam tidur dan usahakan malam tidak terlalu dipenuhi layar.',
      'journalTitle': 'Journaling ringan',
      'journalDesc':
          'Tulis singkat apa yang terjadi, apa yang kamu rasa, dan apa yang kamu butuhkan.',
      'walkTitle': 'Jalan singkat',
      'walkDesc':
          'Jalan pelan 5 sampai 10 menit bisa bantu tubuh dan kepala sedikit turun tensinya.',
      'breatheTitle': 'Latihan napas',
      'breatheDesc':
          'Tarik 4 detik, tahan 4 detik, buang 6 detik selama beberapa putaran.',
      'reachOutTitle': 'Hubungi orang aman',
      'reachOutDesc':
          'Kalau harinya berat, tidak semua hal harus dipikul sendirian.',
      'steadyTitle': 'Jaga ritme yang baik',
      'steadyDesc':
          'Kalau periodenya cukup stabil, pertahankan kebiasaan yang memang membantu.',
      'gratitudeTitle': 'Catat momen hangat',
      'gratitudeDesc':
          'Simpan momen kecil yang terasa baik supaya tidak lewat begitu saja.',
      'bodyCareTitle': 'Periksa kebutuhan tubuh',
      'bodyCareDesc':
          'Makan, minum, dan istirahat cukup sering lebih penting dari yang kita akui.',
    },
    'en': {
      'title': 'Mood Insight',
      'moodSenang': 'Happy',
      'moodNetral': 'Neutral',
      'moodSedih': 'Sad',
      'moodMarah': 'Angry',
      'heroTitle': 'Your emotional pattern is telling a story',
      'heroSub':
          'From the moods you recorded, this page highlights the rhythm that stands out most and the small things worth protecting.',
      'periodLabel': 'Period',
      'dominantLabel': 'Dominant mood',
      'recordedLabel': 'Recorded days',
      'consistencyLabel': 'Consistency',
      'mainReadTitle': 'What this period seems to show',
      'emptySummary':
          'There is not enough data to read the pattern yet. That is fine, start with one check-in first.',
      'warmSummary':
          'This period feels warmer overall. There are signs that your rhythm has been lighter and safer.',
      'neutralSummary':
          'This period leans more neutral. Not too high, not too low. Sometimes calm is already progress.',
      'heavySummary':
          'This period feels heavier. Focusing on small steps makes more sense than demanding instant recovery.',
      'mixedSummary':
          'This period feels mixed. Some days were light, some were heavy, so patterns and pauses matter more now.',
      'visualTitle': 'Main mood',
      'visualWarm': 'The rhythm looks fairly warm',
      'visualNeutral': 'The rhythm looks calm',
      'visualHeavy': 'The rhythm looks heavier',
      'visualMixed': 'The rhythm looks mixed',
      'activityTitle': 'More relevant activity suggestions',
      'activitySub':
          'These suggestions stay light and realistic.',
      'promptTitle': 'Try reflecting on this',
      'prompt1Warm':
          'What small thing has helped you feel lighter lately?',
      'prompt2Warm':
          'Which good habit do you want to protect next week?',
      'prompt1Neutral':
          'Is there any body or mind need you have been quietly ignoring?',
      'prompt2Neutral':
          'What is one small thing that could make your day feel a little more alive?',
      'prompt1Heavy':
          'What has been draining your energy most often lately?',
      'prompt2Heavy':
          'Who or what usually feels safest when your days get heavy?',
      'prompt1Mixed':
          'What kind of moments tend to appear before your mood shifts?',
      'prompt2Mixed':
          'If you had to protect one good pattern, which one would it be?',
      'openDiary': 'Continue in diary',
      'back': 'Back',
      'premiumBadge': 'Deeper reflection',
      'regularBadge': 'Reflection summary',
      'sleepTitle': 'Fix your sleep rhythm',
      'sleepDesc':
          'Clean up your sleep schedule and keep your nights from being ruled by screens.',
      'journalTitle': 'Light journaling',
      'journalDesc':
          'Write briefly what happened, what you felt, and what you needed.',
      'walkTitle': 'Short walk',
      'walkDesc':
          'A slow 5 to 10 minute walk can help lower tension in body and mind.',
      'breatheTitle': 'Breathing practice',
      'breatheDesc':
          'Inhale 4 seconds, hold 4 seconds, exhale 6 seconds for several rounds.',
      'reachOutTitle': 'Reach a safe person',
      'reachOutDesc':
          'When the day feels heavy, not everything has to be carried alone.',
      'steadyTitle': 'Protect a good rhythm',
      'steadyDesc':
          'If this period feels fairly steady, keep the habits that are already helping.',
      'gratitudeTitle': 'Keep warm moments',
      'gratitudeDesc':
          'Save small warm moments so they do not vanish too quickly.',
      'bodyCareTitle': 'Check body needs',
      'bodyCareDesc':
          'Food, water, and proper rest matter more than people like to admit.',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _hydrateLanguage();
  }

  Future<void> _hydrateLanguage() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();
    if (!mounted) return;
    setState(() {
      _languageCode = language == 'en' ? 'en' : 'id';
    });
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  ThemeData get _theme => Theme.of(context);

  TextStyle? get _headline => _theme.textTheme.headlineLarge?.copyWith(
        color: const Color(0xFF1F1F1F),
        fontSize: 22,
      );

  TextStyle? get _title => _theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF1F1F1F),
        fontSize: 17,
      );

  TextStyle? get _body => _theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF6E746B),
        height: 1.45,
      );

  TextStyle? get _bodyDark => _theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF1F1F1F),
        height: 1.45,
      );
  
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.10),
                    offset: Offset(0, 6),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1F1F1F),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _t('title'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayMood(String mood) {
    switch (mood) {
      case 'Senang':
        return _t('moodSenang');
      case 'Netral':
        return _t('moodNetral');
      case 'Sedih':
        return _t('moodSedih');
      case 'Marah':
        return _t('moodMarah');
      default:
        return mood;
    }
  }

  Color _moodAccent(String mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFF75B85E);
      case 'Netral':
        return const Color(0xFFC6A74E);
      case 'Sedih':
        return const Color(0xFF86AE9E);
      case 'Marah':
        return const Color(0xFFD98087);
      default:
        return const Color(0xFF98A095);
    }
  }

  Color _moodSoft(String mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFFE9F7E8);
      case 'Netral':
        return const Color(0xFFFFF4DF);
      case 'Sedih':
        return const Color(0xFFE8F4F0);
      case 'Marah':
        return const Color(0xFFFFEEF2);
      default:
        return const Color(0xFFF7FAF1);
    }
  }

  String _staticMoodAsset(String mood) {
    switch (mood) {
      case 'Senang':
        return 'assets/emoji/emoji_senang.png';
      case 'Netral':
        return 'assets/emoji/emoji_netral.png';
      case 'Sedih':
        return 'assets/emoji/emoji_sedih.png';
      case 'Marah':
        return 'assets/emoji/emoji_marah.png';
      default:
        return 'assets/emoji/emoji_netral.png';
    }
  }

  String _dynamicMoodAsset(String mood) {
    switch (mood) {
      case 'Senang':
        // TODO(MOODLY-ASSET-DYNAMIC): ganti ke asset emoji bergerak untuk mood senang
        return 'assets/emoji_dynamic/emoji_senang.gif';
      case 'Netral':
        // TODO(MOODLY-ASSET-DYNAMIC): ganti ke asset emoji bergerak untuk mood netral
        return 'assets/emoji_dynamic/emoji_netral.gif';
      case 'Sedih':
        // TODO(MOODLY-ASSET-DYNAMIC): ganti ke asset emoji bergerak untuk mood sedih
        return 'assets/emoji_dynamic/emoji_sedih.gif';
      case 'Marah':
        // TODO(MOODLY-ASSET-DYNAMIC): ganti ke asset emoji bergerak untuk mood marah
        return 'assets/emoji_dynamic/emoji_marah.gif';
      default:
        return 'assets/emoji_dynamic/emoji_netral.gif';
    }
  }

  String _summaryText() {
    if (widget.recordedCount == 0) return _t('emptySummary');

    final stats = widget.moodStats;
    final heavy = (stats['Sedih'] ?? 0) + (stats['Marah'] ?? 0);
    final warm = (stats['Senang'] ?? 0) + (stats['Netral'] ?? 0);
    final dominant = widget.dominantMoodRaw;

    if (heavy > warm) return _t('heavySummary');
    if (dominant == 'Senang') return _t('warmSummary');
    if (dominant == 'Netral') return _t('neutralSummary');
    return _t('mixedSummary');
  }

  String _visualLabel() {
    if (widget.recordedCount == 0) return _t('emptySummary');

    final stats = widget.moodStats;
    final heavy = (stats['Sedih'] ?? 0) + (stats['Marah'] ?? 0);
    final warm = (stats['Senang'] ?? 0) + (stats['Netral'] ?? 0);
    final dominant = widget.dominantMoodRaw;

    if (heavy > warm) return _t('visualHeavy');
    if (dominant == 'Senang') return _t('visualWarm');
    if (dominant == 'Netral') return _t('visualNeutral');
    return _t('visualMixed');
  }

  List<_InsightActivity> _activities() {
    final stats = widget.moodStats;
    final dominant = widget.dominantMoodRaw;
    final heavy = (stats['Sedih'] ?? 0) + (stats['Marah'] ?? 0);
    final warm = (stats['Senang'] ?? 0) + (stats['Netral'] ?? 0);

    if (widget.recordedCount == 0) {
      return [
        _InsightActivity(
          icon: Icons.menu_book_rounded,
          title: _t('journalTitle'),
          description: _t('journalDesc'),
          bg: const Color(0xFFFFF2DD),
          fg: const Color(0xFF9A6C18),
        ),
        _InsightActivity(
          icon: Icons.self_improvement_rounded,
          title: _t('breatheTitle'),
          description: _t('breatheDesc'),
          bg: const Color(0xFFE6F7F0),
          fg: const Color(0xFF37856A),
        ),
      ];
    }

    if (heavy > warm || dominant == 'Sedih' || dominant == 'Marah') {
      return [
        _InsightActivity(
          icon: Icons.nightlight_round,
          title: _t('sleepTitle'),
          description: _t('sleepDesc'),
          bg: const Color(0xFFEFE6FF),
          fg: const Color(0xFF7A52B3),
        ),
        _InsightActivity(
          icon: Icons.menu_book_rounded,
          title: _t('journalTitle'),
          description: _t('journalDesc'),
          bg: const Color(0xFFFFF2DD),
          fg: const Color(0xFF9A6C18),
        ),
        _InsightActivity(
          icon: Icons.favorite_rounded,
          title: _t('reachOutTitle'),
          description: _t('reachOutDesc'),
          bg: const Color(0xFFFFEEF2),
          fg: const Color(0xFFA05061),
        ),
        _InsightActivity(
          icon: Icons.self_improvement_rounded,
          title: _t('breatheTitle'),
          description: _t('breatheDesc'),
          bg: const Color(0xFFE6F7F0),
          fg: const Color(0xFF37856A),
        ),
      ];
    }

    if (dominant == 'Netral') {
      return [
        _InsightActivity(
          icon: Icons.local_drink_rounded,
          title: _t('bodyCareTitle'),
          description: _t('bodyCareDesc'),
          bg: const Color(0xFFE7F6FB),
          fg: const Color(0xFF3A7F90),
        ),
        _InsightActivity(
          icon: Icons.directions_walk_rounded,
          title: _t('walkTitle'),
          description: _t('walkDesc'),
          bg: const Color(0xFFEAF6DE),
          fg: const Color(0xFF558E3E),
        ),
        _InsightActivity(
          icon: Icons.menu_book_rounded,
          title: _t('journalTitle'),
          description: _t('journalDesc'),
          bg: const Color(0xFFFFF2DD),
          fg: const Color(0xFF9A6C18),
        ),
      ];
    }

    return [
      _InsightActivity(
        icon: Icons.check_circle_rounded,
        title: _t('steadyTitle'),
        description: _t('steadyDesc'),
        bg: const Color(0xFFE9F7E8),
        fg: const Color(0xFF3E8A2D),
      ),
      _InsightActivity(
        icon: Icons.auto_awesome_rounded,
        title: _t('gratitudeTitle'),
        description: _t('gratitudeDesc'),
        bg: const Color(0xFFFFF3F6),
        fg: const Color(0xFFB55A76),
      ),
      _InsightActivity(
        icon: Icons.directions_walk_rounded,
        title: _t('walkTitle'),
        description: _t('walkDesc'),
        bg: const Color(0xFFEAF6DE),
        fg: const Color(0xFF558E3E),
      ),
    ];
  }

  List<String> _reflectionPrompts() {
    final stats = widget.moodStats;
    final dominant = widget.dominantMoodRaw;
    final heavy = (stats['Sedih'] ?? 0) + (stats['Marah'] ?? 0);
    final warm = (stats['Senang'] ?? 0) + (stats['Netral'] ?? 0);

    if (widget.recordedCount == 0) {
      return [
        _t('prompt1Neutral'),
        _t('prompt2Neutral'),
      ];
    }

    if (heavy > warm || dominant == 'Sedih' || dominant == 'Marah') {
      return [
        _t('prompt1Heavy'),
        _t('prompt2Heavy'),
      ];
    }

    if (dominant == 'Senang') {
      return [
        _t('prompt1Warm'),
        _t('prompt2Warm'),
      ];
    }

    if (dominant == 'Netral') {
      return [
        _t('prompt1Neutral'),
        _t('prompt2Neutral'),
      ];
    }

    return [
      _t('prompt1Mixed'),
      _t('prompt2Mixed'),
    ];
  }

  Widget _statChip({
    required String label,
    required String value,
    required Color bg,
    required Color fg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _body?.copyWith(color: fg)),
            const SizedBox(height: 6),
            Text(
              value,
              style: _title?.copyWith(color: fg, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(_InsightActivity item) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: item.fg.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: item.fg),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: _title?.copyWith(color: item.fg),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: _bodyDark?.copyWith(color: const Color(0xFF3F463C)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dominant = widget.dominantMoodRaw;
    final displayDominant = dominant == '-' ? '-' : _displayMood(dominant);
    final dominantAccent =
        dominant == '-' ? const Color(0xFF98A095) : _moodAccent(dominant);
    final dominantSoft =
        dominant == '-' ? const Color(0xFFF7FAF1) : _moodSoft(dominant);
    final prompts = _reflectionPrompts();
    final activities = _activities();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8EA),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEEF2).withOpacity(0.72),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9F7E8).withOpacity(0.80),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
              child: Column(
                children: [
                  _buildPageHeader(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          offset: Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isPremiumContext
                                      ? const Color(0xFFFFF4DF)
                                      : const Color(0xFFFFEEF2),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  widget.isPremiumContext
                                      ? _t('premiumBadge')
                                      : _t('regularBadge'),
                                  style: _bodyDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(_t('heroTitle'), style: _headline),
                              const SizedBox(height: 8),
                              Text(_t('heroSub'), style: _body),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: dominantSoft,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(14),
                          child: dominant == '-'
                              ? const Icon(
                                  Icons.auto_graph_rounded,
                                  color: Color(0xFF84C96C),
                                  size: 34,
                                )
                              : Image.asset(
                                  _dynamicMoodAsset(dominant),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return Image.asset(
                                      _staticMoodAsset(dominant),
                                      fit: BoxFit.contain,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          offset: Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('periodLabel'), style: _body),
                        const SizedBox(height: 4),
                        Text(widget.periodLabel, style: _title?.copyWith(fontSize: 20)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statChip(
                              label: _t('dominantLabel'),
                              value: displayDominant,
                              bg: dominantSoft,
                              fg: dominantAccent,
                            ),
                            const SizedBox(width: 10),
                            _statChip(
                              label: _t('recordedLabel'),
                              value: '${widget.recordedCount}',
                              bg: const Color(0xFFE9F7E8),
                              fg: const Color(0xFF2D6B20),
                            ),
                            const SizedBox(width: 10),
                            _statChip(
                              label: _t('consistencyLabel'),
                              value: '${(widget.consistencyRate * 100).round()}%',
                              bg: const Color(0xFFFFF4DF),
                              fg: const Color(0xFF8A5A09),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          offset: Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('mainReadTitle'), style: _title?.copyWith(fontSize: 19)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: dominantSoft,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _summaryText(),
                            style: _bodyDark?.copyWith(color: const Color(0xFF364134)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(_t('visualTitle'), style: _title),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: dominantSoft,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: dominantAccent.withOpacity(0.16)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.62),
                                ),
                                padding: const EdgeInsets.all(18),
                                child: dominant == '-'
                                    ? const Icon(
                                        Icons.favorite_rounded,
                                        size: 46,
                                        color: Color(0xFF84C96C),
                                      )
                                    : Image.asset(
                                        _dynamicMoodAsset(dominant),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) {
                                          return Image.asset(
                                            _staticMoodAsset(dominant),
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _visualLabel(),
                                textAlign: TextAlign.center,
                                style: _title?.copyWith(color: dominantAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          offset: Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('activityTitle'), style: _title?.copyWith(fontSize: 19)),
                        const SizedBox(height: 6),
                        Text(_t('activitySub'), style: _body),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 196,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: activities.length,
                            itemBuilder: (_, index) => _activityCard(activities[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          offset: Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('promptTitle'), style: _title?.copyWith(fontSize: 19)),
                        const SizedBox(height: 14),
                        ...prompts.map(
                          (text) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAF1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              text,
                              style: _bodyDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddDiaryPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dominantAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(_t('openDiary')),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              _t('back'),
                              style: _bodyDark?.copyWith(
                                color: const Color(0xFF6E746B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }  
}

class _InsightActivity {
  final IconData icon;
  final String title;
  final String description;
  final Color bg;
  final Color fg;

  const _InsightActivity({
    required this.icon,
    required this.title,
    required this.description,
    required this.bg,
    required this.fg,
  });
}