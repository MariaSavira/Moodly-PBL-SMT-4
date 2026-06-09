import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';
import '../../widgets/moodly_bottom_navbar.dart';
import '../pages.dart';
import '../setting/moodly_settings_support.dart';
import 'diary_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color _bg = Color(0xFFF4F8EA);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF5F9E4E);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEFF7E6);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _yellowSoft = Color(0xFFF8F0D0);
  static const Color _blueSoft = Color(0xFFE2F1EE);
  static const Color _redSoft = Color(0xFFFBE3E7);
  static const Color _line = Color(0xFFE4E9D9);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6D7568);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Cari Diary',
      'hintTop': 'Cari bagian cerita yang ingin kamu buka lagi',
      'hintField': 'Cari judul, isi, mood, atau tanggal',
      'warmPrompt': 'Mulai ketik pelan-pelan. Nanti catatan yang nyambung muncul di sini.',
      'empty': 'Belum ketemu yang cocok',
      'emptyDesc': 'Coba pakai kata lain. Ceritamu tidak hilang, cuma belum kepanggil.',
      'result': 'hasil ditemukan',
      'private': 'Privat',
      'public': 'Publik',
      'moodHappy': 'Senang',
      'moodNeutral': 'Netral',
      'moodSad': 'Sedih',
      'moodAngry': 'Marah',
      'month1': 'Januari',
      'month2': 'Februari',
      'month3': 'Maret',
      'month4': 'April',
      'month5': 'Mei',
      'month6': 'Juni',
      'month7': 'Juli',
      'month8': 'Agustus',
      'month9': 'September',
      'month10': 'Oktober',
      'month11': 'November',
      'month12': 'Desember',
      'sun': 'Min',
      'mon': 'Sen',
      'tue': 'Sel',
      'wed': 'Rab',
      'thu': 'Kam',
      'fri': 'Jum',
      'sat': 'Sab',
    },
    'en': {
      'title': 'Search Diary',
      'hintTop': 'Find the part of your story you want to revisit',
      'hintField': 'Search title, content, mood, or date',
      'warmPrompt': 'Start typing gently. Matching entries will show up here.',
      'empty': 'No matching entries yet',
      'emptyDesc': 'Try another keyword. Your story is still there, just being difficult.',
      'result': 'results found',
      'private': 'Private',
      'public': 'Public',
      'moodHappy': 'Happy',
      'moodNeutral': 'Neutral',
      'moodSad': 'Sad',
      'moodAngry': 'Angry',
      'month1': 'January',
      'month2': 'February',
      'month3': 'March',
      'month4': 'April',
      'month5': 'May',
      'month6': 'June',
      'month7': 'July',
      'month8': 'August',
      'month9': 'September',
      'month10': 'October',
      'month11': 'November',
      'month12': 'December',
      'sun': 'Sun',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
    },
  };

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  String _query = '';
  int _currentNavIndex = 1;
  Timer? _debounce;

  String _t(String key) => _copy[_languageCode]?[key] ?? key;
  TextTheme get _text => Theme.of(context).textTheme;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  Future<void> _handleNavTap(int index) async {
    if (index == 1) return;

    Widget? target;
    switch (index) {
      case 0:
        target = const Homepage();
        break;
      case 3:
        target = const HomeChatAnonim();
        break;
      case 4:
        target = const AfirmasiPage();
        break;
    }

    if (target == null || !mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target!),
    );
  }

  void _onEmergencyTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencySupportPage()),
    );
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim();
      });
    });
  }

  String _monthNameFromCode(String code) {
    switch (code.toUpperCase()) {
      case 'JAN':
        return _t('month1');
      case 'FEB':
        return _t('month2');
      case 'MAR':
        return _t('month3');
      case 'APR':
        return _t('month4');
      case 'MEI':
        return _t('month5');
      case 'JUN':
        return _t('month6');
      case 'JUL':
        return _t('month7');
      case 'AGS':
        return _t('month8');
      case 'SEP':
        return _t('month9');
      case 'OKT':
        return _t('month10');
      case 'NOV':
        return _t('month11');
      case 'DES':
        return _t('month12');
      default:
        return code;
    }
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return _t('sun');
      case DateTime.monday:
        return _t('mon');
      case DateTime.tuesday:
        return _t('tue');
      case DateTime.wednesday:
        return _t('wed');
      case DateTime.thursday:
        return _t('thu');
      case DateTime.friday:
        return _t('fri');
      case DateTime.saturday:
        return _t('sat');
      default:
        return '';
    }
  }

  String _formatEntryDate(DiaryModel diary) {
    final dt = diary.entryDateTime;
    return '${dt.day} ${_monthNameFromCode(diary.month)} ${dt.year} • ${diary.time}';
  }

  String _normalizeMood(String mood) {
    final raw = mood.trim().toLowerCase();
    if (raw == 'happy' || raw == 'senang') return 'happy';
    if (raw == 'sad' || raw == 'sedih') return 'sad';
    if (raw == 'angry' || raw == 'marah') return 'angry';
    return 'neutral';
  }

  ({String label, Color bg, Color fg, String asset}) _moodMeta(String mood) {
    switch (_normalizeMood(mood)) {
      case 'happy':
        return (
          label: _t('moodHappy'),
          bg: _greenSoft,
          fg: _greenDark,
          asset: 'assets/emoji/emoji_senang.png',
        );
      case 'sad':
        return (
          label: _t('moodSad'),
          bg: _blueSoft,
          fg: const Color(0xFF6DA596),
          asset: 'assets/emoji/emoji_sedih.png',
        );
      case 'angry':
        return (
          label: _t('moodAngry'),
          bg: _redSoft,
          fg: const Color(0xFFC96D79),
          asset: 'assets/emoji/emoji_marah.png',
        );
      default:
        return (
          label: _t('moodNeutral'),
          bg: _yellowSoft,
          fg: const Color(0xFFB99737),
          asset: 'assets/emoji/emoji_netral.png',
        );
    }
  }

  String _primaryImageOf(DiaryModel diary) {
      if (diary.images.isNotEmpty && diary.images.first.trim().isNotEmpty) {
        return diary.images.first.trim();
      }
      return diary.imageUrl.trim();
    }

    List<DiaryModel> _applyLocalSearch(List<DiaryModel> all) {
    final clean = _query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final results = all.where((diary) {
      final title = diary.title.toLowerCase();
      final content = diary.content.toLowerCase();
      final moodRaw = diary.mood.toLowerCase();
      final moodLabel = _moodMeta(diary.mood).label.toLowerCase();
      final monthName = _monthNameFromCode(diary.month).toLowerCase();
      final dateText =
          '${_weekdayShort(diary.entryDateTime.weekday).toLowerCase()}, '
          '${diary.date} $monthName ${diary.year} ${diary.time}'.toLowerCase();

      return title.contains(clean) ||
          content.contains(clean) ||
          moodRaw.contains(clean) ||
          moodLabel.contains(clean) ||
          monthName.contains(clean) ||
          dateText.contains(clean);
    }).toList();

    results.sort((a, b) => b.entryDateTime.compareTo(a.entryDateTime));
    return results;
  }

  void _openDiary(DiaryModel diary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryPage(
          month: diary.month,
          year: diary.year,
          openDiaryId: diary.id,
        ),
      ),
    );
  }

  Widget _searchHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('hintTop'),
            style: _text.bodyMedium?.copyWith(
              color: _textSoft,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: _pinkSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onQueryChanged,
              style: _text.titleMedium?.copyWith(
                color: _textDark,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: _t('hintField'),
                hintStyle: _text.bodyMedium?.copyWith(
                  color: _textSoft,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _greenDark,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(DiaryModel diary) {
    final mood = _moodMeta(diary.mood);
    final imageUrl = _primaryImageOf(diary);
    final hasImage = imageUrl.isNotEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _chipWithAsset(
              bg: mood.bg,
              fg: mood.fg,
              asset: mood.asset,
              label: mood.label,
            ),
            const SizedBox(width: 8),
            _plainChip(
              bg: diary.isPublic ? _greenMint : _pinkSoft,
              fg: diary.isPublic ? _greenDark : const Color(0xFFC77B88),
              icon: diary.isPublic ? Icons.public_rounded : Icons.lock_rounded,
              label: diary.isPublic ? _t('public') : _t('private'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          diary.title.trim().isEmpty ? '-' : diary.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _text.titleMedium?.copyWith(
            color: _textDark,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          diary.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _text.bodyMedium?.copyWith(
            color: _textSoft,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _formatEntryDate(diary),
          style: _text.bodySmall?.copyWith(
            color: _textSoft,
          ),
        ),
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _openDiary(diary),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
          border: Border.all(color: _line, width: 1.2),
        ),
        child: hasImage
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(28),
                    ),
                    child: SizedBox(
                      width: 128,
                      height: 156,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: mood.bg,
                              alignment: Alignment.center,
                              child: Image.asset(
                                mood.asset,
                                width: 44,
                                height: 44,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          if (diary.images.length > 1)
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '+${diary.images.length - 1}',
                                  style: _text.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: content,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _greenDark,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _greenDark,
                      size: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _chipWithAsset({
    required Color bg,
    required Color fg,
    required String asset,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            asset,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.circle,
              size: 12,
              color: fg,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: _text.bodySmall?.copyWith(
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainChip({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: _text.bodySmall?.copyWith(
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _idleState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _greenMint,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 38,
              color: _greenDark,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _t('warmPrompt'),
            textAlign: TextAlign.center,
            style: _text.titleMedium?.copyWith(
              color: _textDark,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _greenMint,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 38,
              color: _greenDark,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _t('empty'),
            textAlign: TextAlign.center,
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _t('emptyDesc'),
            textAlign: TextAlign.center,
            style: _text.bodyMedium?.copyWith(
              color: _textSoft,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = _query.trim();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textDark,
          ),
        ),
        title: Text(
          _t('title'),
          style: _text.headlineLarge?.copyWith(
            color: _textDark,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -46,
            right: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinkSoft.withOpacity(0.72),
              ),
            ),
          ),
          Positioned(
            left: -80,
            bottom: 120,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.84),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              children: [
                _searchHeader(),
                const SizedBox(height: 18),
                if (trimmed.isEmpty)
                  _idleState()
                else
                  StreamBuilder<List<DiaryModel>>(
                    stream: FirestoreDiaryService().getUserDiaries(),
                    builder: (context, snapshot) {
                      final all = snapshot.data ?? [];
                      final results = _applyLocalSearch(all);

                      if (snapshot.connectionState == ConnectionState.waiting && all.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(36),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (results.isEmpty) {
                        return _emptyState();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              bottom: 12,
                            ),
                            child: Text(
                              '${results.length} ${_t("result")}',
                              style: _text.bodySmall?.copyWith(
                                color: _textSoft,
                              ),
                            ),
                          ),
                          for (final diary in results) ...[
                            _resultCard(diary),
                            const SizedBox(height: 14),
                          ],
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MoodlyBottomNavbar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        onEmergencyTap: _onEmergencyTap,
      ),
    );
  }
}