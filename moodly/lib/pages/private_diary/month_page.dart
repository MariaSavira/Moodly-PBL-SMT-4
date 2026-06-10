import 'package:flutter/material.dart';

import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';
import '../../widgets/moodly_bottom_navbar.dart';
import '../pages.dart';
import '../setting/moodly_settings_support.dart';
import 'add_diary_page.dart';
import 'diary_page.dart';
import 'search_page.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({super.key});

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  static const Color _bg = Color(0xFFF4F8EA);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF5F9E4E);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEFF7E6);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _line = Color(0xFFE4E9D9);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6D7568);

  static const List<String> _monthCodes = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGS',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'pageTitle': 'Diary',
      'heroTitle': 'Ruang ceritamu',
      'heroDesc': 'Lihat ulang ceritamu per bulan tanpa bikin kepala penuh.',
      'year': 'Tahun',
      'entries': 'catatan',
      'emptyYear': 'Belum ada catatan di tahun ini',
      'fabTooltip': 'Tulis diary',
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
    },
    'en': {
      'pageTitle': 'Diary',
      'heroTitle': 'Your story space',
      'heroDesc': 'Look back at your entries by month without making your head crowded.',
      'year': 'Year',
      'entries': 'entries',
      'emptyYear': 'No entries yet this year',
      'fabTooltip': 'Write diary',
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
    },
  };

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  int _selectedYear = DateTime.now().year;
  int _currentNavIndex = 1;

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
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
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

  void _openMonth(String monthCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryPage(
          month: monthCode,
          year: _selectedYear,
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _textDark,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _t('pageTitle'),
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            shape: BoxShape.circle,
            boxShadow: _softShadow,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
            icon: const Icon(
              Icons.search_rounded,
              color: _greenDark,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('heroTitle'),
                  style: _text.headlineLarge?.copyWith(
                    color: _textDark,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _t('heroDesc'),
                  style: _text.bodyMedium?.copyWith(
                    color: _textSoft,
                    fontSize: 14,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 94,
            height: 94,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _greenMint,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 42,
              color: _greenDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _yearSwitcher() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              setState(() {
                _selectedYear--;
              });
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    _t('year'),
                    style: _text.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_selectedYear',
                    style: _text.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          _circleButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () {
              setState(() {
                _selectedYear++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: _greenMint,
        ),
        child: Icon(
          icon,
          color: _greenDark,
        ),
      ),
    );
  }

  Widget _monthCard({
    required String monthCode,
    required int count,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _openMonth(monthCode),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
          border: Border.all(
            color: _greenSoft,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Text(
              _monthNameFromCode(monthCode),
              textAlign: TextAlign.center,
              style: _text.headlineLarge?.copyWith(
                color: _textDark,
                fontSize: 22,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _greenMint,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$count ${_t('entries')}',
                      style: _text.bodySmall?.copyWith(
                        color: _greenDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _greenMint,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: _greenDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _countByMonth(List<DiaryModel> diaries) {
    final map = {
      for (final code in _monthCodes) code: 0,
    };

    for (final diary in diaries) {
      final key = diary.month.trim().toUpperCase();
      if (map.containsKey(key)) {
        map[key] = (map[key] ?? 0) + 1;
      }
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DiaryModel>>(
      stream: FirestoreDiaryService().getUserDiariesByYear(_selectedYear),
      builder: (context, snapshot) {
        final diaries = snapshot.data ?? [];
        final monthCounts = _countByMonth(diaries);

        return Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              Positioned(
                top: -56,
                right: -34,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pinkSoft.withOpacity(0.78),
                  ),
                ),
              ),
              Positioned(
                left: -90,
                bottom: 120,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _greenMint.withOpacity(0.82),
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
                  children: [
                    _header(),
                    const SizedBox(height: 18),
                    _heroCard(),
                    const SizedBox(height: 18),
                    _yearSwitcher(),
                    const SizedBox(height: 18),
                    GridView.builder(
                      itemCount: _monthCodes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.96,
                      ),
                      itemBuilder: (context, index) {
                        final code = _monthCodes[index];
                        return _monthCard(
                          monthCode: code,
                          count: monthCounts[code] ?? 0,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 8,
            tooltip: _t('fabTooltip'),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddDiaryPage(
                    initialDate: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    ),
                  ),
                ),
              );

              if (!mounted) return;
              if (result != null) {
                setState(() {});
              }
            },
            child: const Icon(Icons.add_rounded, size: 32),
          ),
          bottomNavigationBar: MoodlyBottomNavbar(
            currentIndex: _currentNavIndex,
            onTap: _handleNavTap,
            onEmergencyTap: _onEmergencyTap,
          ),
        );
      },
    );
  }
}