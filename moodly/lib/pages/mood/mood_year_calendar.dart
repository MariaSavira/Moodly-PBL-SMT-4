import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../setting/moodly_settings_support.dart';
import 'mood_calendar.dart';

class MoodYearCalendar extends StatefulWidget {
  const MoodYearCalendar({super.key});

  @override
  State<MoodYearCalendar> createState() => _MoodYearCalendarState();
}

class _MoodYearCalendarState extends State<MoodYearCalendar> {
  int _selectedYear = 2026;
  bool _showYearDropdown = false;
  bool _isLoading = true;
  final List<int> _availableYears = [2020, 2021, 2022, 2023, 2024, 2025, 2026];

  Map<String, Map<String, String>> _moodDatabase = {};
  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Kalender Mood',
      'heroTitle': 'Lihat perjalanan mood sepanjang tahun.',
      'heroSubtitle': 'Setiap bulan tetap sederhana. Kamu bisa masuk ke detail bulan mana pun saat diperlukan.',
      'year': 'Tahun {year}',
      'daysFilled': '{count} hari',
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
      'weekday1': 'S',
      'weekday2': 'S',
      'weekday3': 'R',
      'weekday4': 'K',
      'weekday5': 'J',
      'weekday6': 'S',
      'weekday7': 'M',
    },
    'en': {
      'title': 'Mood Calendar',
      'heroTitle': 'See your mood journey across the year.',
      'heroSubtitle': 'Each month stays simple. You can enter any month in detail whenever you need it.',
      'year': 'Year {year}',
      'daysFilled': '{count} days',
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
      'weekday1': 'S',
      'weekday2': 'M',
      'weekday3': 'T',
      'weekday4': 'W',
      'weekday5': 'T',
      'weekday6': 'F',
      'weekday7': 'S',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _hydrateLanguage();
    _loadMoods();
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

  String _replace(String template, Map<String, String> values) {
    var result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  ThemeData get _theme => Theme.of(context);

  TextStyle? get _headline => _theme.textTheme.headlineLarge?.copyWith(
        color: const Color(0xFF1F1F1F),
      );

  TextStyle? get _title => _theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF1F1F1F),
      );

  TextStyle? get _body => _theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF697264),
        height: 1.45,
      );

  TextStyle? get _bodyDark => _theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF1F1F1F),
      );

  List<String> get _monthNames => [
        _t('month1'),
        _t('month2'),
        _t('month3'),
        _t('month4'),
        _t('month5'),
        _t('month6'),
        _t('month7'),
        _t('month8'),
        _t('month9'),
        _t('month10'),
        _t('month11'),
        _t('month12'),
      ];

  List<String> get _weekDays => [
        _t('weekday1'),
        _t('weekday2'),
        _t('weekday3'),
        _t('weekday4'),
        _t('weekday5'),
        _t('weekday6'),
        _t('weekday7'),
      ];

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _moodPrefix(String uid) => 'mood_${uid}_';

  DocumentReference<Map<String, dynamic>> _moodDoc(String uid) {
    return FirebaseFirestore.instance.collection('moods').doc(uid);
  }

  Future<void> _loadMoods() async {
    final allMoods = <String, Map<String, String>>{};

    try {
      final uid = _uid;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          _moodDatabase = {};
          _isLoading = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final moodPrefix = _moodPrefix(uid);
      final keys = prefs.getKeys().where((k) => k.startsWith(moodPrefix));

      for (final key in keys) {
        final datePart = key.replaceFirst(moodPrefix, '');
        final mood = prefs.getString(key);
        if (mood == null || mood.trim().isEmpty) continue;

        final parts = datePart.split('-');
        if (parts.length != 3) continue;

        final year = parts[0];
        final monthInt = int.parse(parts[1]);
        final dayInt = int.parse(parts[2]);

        allMoods.putIfAbsent(year, () => {});
        allMoods[year]!['$monthInt-$dayInt'] = mood.trim();
      }

      final doc = await _moodDoc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        final entries = data?['entries'] as Map<String, dynamic>? ?? {};

        entries.forEach((dateKey, moodValue) {
          final parts = dateKey.split('-');
          if (parts.length != 3) return;

          final year = parts[0];
          final monthInt = int.parse(parts[1]);
          final dayInt = int.parse(parts[2]);
          final mood = moodValue.toString().trim();

          if (mood.isEmpty) return;

          allMoods.putIfAbsent(year, () => {});
          allMoods[year]!['$monthInt-$dayInt'] = mood;
        });
      }

      if (!mounted) return;
      setState(() {
        _moodDatabase = allMoods;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _moodDatabase = {};
        _isLoading = false;
      });
    }
  }

  Color? _getMoodColor(String? mood) {
    if (mood == null) return null;
    switch (mood) {
      case 'Senang':
        return const Color(0xFFBFE8BE);
      case 'Netral':
        return const Color(0xFFF4E7B8);
      case 'Sedih':
        return const Color(0xFFD8ECE3);
      case 'Marah':
        return const Color(0xFFF2C5C8);
      default:
        return null;
    }
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
      _showYearDropdown = false;
    });
  }

  void _navigateToMonthDetail(int month) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodCalendar(
          initialYear: _selectedYear,
          initialMonth: month,
        ),
      ),
    ).then((_) => _loadMoods());
  }

  bool _isCurrentMonth(int month) {
    final now = DateTime.now();
    return now.year == _selectedYear && now.month == month;
  }

  int _countMonthEntries(int month) {
    var count = 0;
    final monthMap = _moodDatabase['$_selectedYear'] ?? {};
    monthMap.forEach((key, value) {
      if (key.startsWith('$month-')) count++;
    });
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_t('title'), style: _headline),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1F1F1F)),
            onPressed: _loadMoods,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -32,
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
            bottom: 80,
            left: -60,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9F7E8).withOpacity(0.82),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF72B45B)),
              ),
            )
          else
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
                              Text(_t('heroTitle'), style: _headline),
                              const SizedBox(height: 8),
                              Text(_t('heroSubtitle'), style: _body),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF6F8),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$_selectedYear',
                            style: _theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildYearSelector(),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      return _buildMonthCard(month);
                    },
                  ),
                ],
              ),
            ),
          if (_showYearDropdown) _buildYearDropdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEFCF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF1F1F1F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _replace(_t('year'), {'year': '$_selectedYear'}),
              style: _title,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showYearDropdown = !_showYearDropdown;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showYearDropdown ? const Color(0xFF72B45B) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showYearDropdown
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: _showYearDropdown ? Colors.white : const Color(0xFF72B45B),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropdownOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showYearDropdown = false),
      child: Container(
        color: Colors.black.withOpacity(0.22),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                    offset: Offset(0, 10),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _availableYears.map((year) {
                  final isSelected = year == _selectedYear;
                  return GestureDetector(
                    onTap: () => _selectYear(year),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFDDEFCF)
                            : const Color(0xFFF7FAF0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8AB85B)
                              : Colors.transparent,
                          width: 1.4,
                        ),
                      ),
                      child: Center(
                        child: Text('$year', style: _title),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCard(int month) {
    final isCurrentMonth = _isCurrentMonth(month);
    final filledDays = _countMonthEntries(month);

    return GestureDetector(
      onTap: () => _navigateToMonthDetail(month),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrentMonth
                ? const Color(0xFF8AB85B)
                : Colors.transparent,
            width: isCurrentMonth ? 1.8 : 0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              offset: Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_monthNames[month - 1], style: _title),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? const Color(0xFFE9F7E8)
                        : const Color(0xFFFFF6F8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _replace(_t('daysFilled'), {'count': '$filledDays'}),
                    style: _bodyDark?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildMiniCalendar(month)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(int month) {
    final daysInMonth = DateTime(_selectedYear, month + 1, 0).day;
    final firstDayOfWeek = DateTime(_selectedYear, month, 1).weekday;
    final dayWidgets = <Widget>[];

    for (final day in _weekDays) {
      dayWidgets.add(
        Center(
          child: Text(
            day,
            style: _bodyDark?.copyWith(
              fontSize: 9,
              color: const Color(0xFF7D8478),
            ),
          ),
        ),
      );
    }

    for (var i = 1; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final moodKey = '$month-$day';
      final mood = _moodDatabase['$_selectedYear']?[moodKey];
      final moodColor = _getMoodColor(mood);

      dayWidgets.add(
        Container(
          decoration: BoxDecoration(
            color: moodColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: _bodyDark?.copyWith(fontSize: 9),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 1,
      children: dayWidgets,
    );
  }
}
