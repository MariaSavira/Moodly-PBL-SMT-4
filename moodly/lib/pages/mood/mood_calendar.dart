import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';
import '../../core/services/premium_service.dart';
import '../setting/moodly_settings_support.dart';

class MoodCalendar extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const MoodCalendar({
    super.key,
    this.initialYear = 2026,
    this.initialMonth = 1,
  });

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  late DateTime _focusedDate;
  DateTime? _lastSelectedDate;
  bool _isLoading = true;
  Map<String, String> _moodDatabase = {};
  Map<String, String> _noteDatabase = {};

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Kalender Mood',
      'subtitle': 'Pilih tanggal dan lihat pola mood dengan lebih rapi.',
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
      'dayMon': 'Sen',
      'dayTue': 'Sel',
      'dayWed': 'Rab',
      'dayThu': 'Kam',
      'dayFri': 'Jum',
      'daySat': 'Sab',
      'daySun': 'Min',
      'recorded': '{count} catatan',
      'analysis': 'Lihat Analisis Mood',
      'analysisDesc': 'Buka ringkasan bulan ini dengan tampilan yang lebih jelas.',
      'legendEmpty': 'Belum diisi',
      'legendToday': 'Hari ini',
      'legendDone': 'Sudah diisi',
      'moodOnDate': 'Mood pada {date}: {mood}',
      'emptyOnDate': 'Belum ada mood pada {date}',
      'moodSenang': 'Senang',
      'moodNetral': 'Netral',
      'moodSedih': 'Sedih',
      'moodMarah': 'Marah',
      'refresh': 'Muat ulang',
      'futureLockedTitle': 'Tanggal belum terbuka',
      'futureLockedDesc':
          'Tanggal di masa depan belum bisa diisi. Mesin waktunya masih belum disetujui.',
      'previewTitle': 'Preview hari ini',
      'previewMood': 'Mood',
      'previewStory': 'Cerita singkat',
      'previewNoStory':
          'Hari ini baru ada mood saja. Kalau mau, lanjut tulis diary biar ceritanya tidak cuma numpang lewat.',
      'editMood': 'Edit mood',
      'writeDiary': 'Tulis diary',
      'back': 'Kembali',
      'addMood': 'Tambah mood',
      'noDataTitle': 'Belum ada catatan',
      'noDataDesc': 'Tanggal ini belum punya mood maupun cerita.',
    },
    'en': {
      'title': 'Mood Calendar',
      'subtitle': 'Pick a date and read your mood pattern more neatly.',
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
      'dayMon': 'Mon',
      'dayTue': 'Tue',
      'dayWed': 'Wed',
      'dayThu': 'Thu',
      'dayFri': 'Fri',
      'daySat': 'Sat',
      'daySun': 'Sun',
      'recorded': '{count} entries',
      'analysis': 'Open Mood Analysis',
      'analysisDesc': 'Open this month’s summary with a clearer layout.',
      'legendEmpty': 'Not filled',
      'legendToday': 'Today',
      'legendDone': 'Recorded',
      'moodOnDate': 'Mood on {date}: {mood}',
      'emptyOnDate': 'No mood recorded on {date}',
      'moodSenang': 'Happy',
      'moodNetral': 'Neutral',
      'moodSedih': 'Sad',
      'moodMarah': 'Angry',
      'refresh': 'Refresh',
      'futureLockedTitle': 'Date not available yet',
      'futureLockedDesc':
          'Future dates cannot be filled yet. Time travel is still not approved.',
      'previewTitle': 'Day preview',
      'previewMood': 'Mood',
      'previewStory': 'Short story',
      'previewNoStory':
          'This day only has a mood saved. Continue to the diary if you want the full story there.',
      'editMood': 'Edit mood',
      'writeDiary': 'Write diary',
      'back': 'Back',
      'addMood': 'Add mood',
      'noDataTitle': 'No record yet',
      'noDataDesc': 'This date has no mood or story yet.',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _hydrateLanguage();
    _focusedDate = DateTime(widget.initialYear, widget.initialMonth, 1);
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
        fontSize: 22,
      );
  
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _popWithSelectedDate,
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
        height: 1.35,
      );

  TextStyle? get _bodyAlt => _theme.textTheme.bodySmall?.copyWith(
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
        _t('dayMon'),
        _t('dayTue'),
        _t('dayWed'),
        _t('dayThu'),
        _t('dayFri'),
        _t('daySat'),
        _t('daySun'),
      ];

  String _displayMood(String? mood) {
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
        return '';
    }
  }

  String _getEmojiImagePath(String? mood) {
    if (mood == null) return '';
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

  String _getDynamicEmojiPath(String? mood) {
    if (mood == null) return '';
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
        return '';
    }
  }

  Color _moodAccent(String? mood) {
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

  Color _moodTint(String? mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFFE9F7E8);
      case 'Netral':
        return const Color(0xFFFFF7DE);
      case 'Sedih':
        return const Color(0xFFEAF5F2);
      case 'Marah':
        return const Color(0xFFFFF0F3);
      default:
        return Colors.white;
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _moodPrefix(String uid) => 'mood_${uid}_';
  String _notePrefix(String uid) => 'note_${uid}_';

  DocumentReference<Map<String, dynamic>> _moodDoc(String uid) {
    return FirebaseFirestore.instance.collection('moods').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> get _diaryRef =>
      FirebaseFirestore.instance.collection('diaries');

  int _monthNumberFromCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'JAN':
        return 1;
      case 'FEB':
        return 2;
      case 'MAR':
        return 3;
      case 'APR':
        return 4;
      case 'MEI':
        return 5;
      case 'JUN':
        return 6;
      case 'JUL':
        return 7;
      case 'AGS':
        return 8;
      case 'SEP':
        return 9;
      case 'OKT':
        return 10;
      case 'NOV':
        return 11;
      case 'DES':
        return 12;
      default:
        return 1;
    }
  }

  String _canonicalMoodValue(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'happy':
      case 'senang':
        return 'Senang';
      case 'neutral':
      case 'netral':
        return 'Netral';
      case 'sad':
      case 'sedih':
        return 'Sedih';
      case 'angry':
      case 'marah':
        return 'Marah';
      default:
        return '';
    }
  }

  DateTime _readStoredDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _loadMoods() async {
    final moods = <String, String>{};
    final notes = <String, String>{};

    try {
      final uid = _uid;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          _moodDatabase = {};
          _noteDatabase = {};
          _isLoading = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final moodPrefix = _moodPrefix(uid);
      final notePrefix = _notePrefix(uid);

      final moodKeys = prefs.getKeys().where((k) => k.startsWith(moodPrefix));
      for (final key in moodKeys) {
        final dateKey = key.replaceFirst(moodPrefix, '');
        final mood = prefs.getString(key);
        if (mood != null && mood.trim().isNotEmpty) {
          moods[dateKey] = mood.trim();
        }
      }

      final noteKeys = prefs.getKeys().where((k) => k.startsWith(notePrefix));
      for (final key in noteKeys) {
        final dateKey = key.replaceFirst(notePrefix, '');
        final note = prefs.getString(key);
        if (note != null && note.trim().isNotEmpty) {
          notes[dateKey] = note.trim();
        }
      }

      final doc = await _moodDoc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        final entries = data?['entries'] as Map<String, dynamic>? ?? {};
        final noteMap = data?['notes'] as Map<String, dynamic>? ?? {};

        entries.forEach((key, value) {
          final mood = value.toString().trim();
          if (mood.isNotEmpty) {
            moods[key] = mood;
          }
        });

        noteMap.forEach((key, value) {
          final text = value.toString().trim();
          if (text.isNotEmpty) {
            notes[key] = text;
          }
        });
      }

      final diarySnapshot = await _diaryRef.where('uid', isEqualTo: uid).get();

      final diaryDocs = diarySnapshot.docs.toList()
        ..sort((a, b) {
          final aData = a.data();
          final bData = b.data();

          final aTime = _readStoredDate(
            aData['updatedAt'] ??
                aData['createdAt'] ??
                aData['updated_at'] ??
                aData['created_at'],
          );

          final bTime = _readStoredDate(
            bData['updatedAt'] ??
                bData['createdAt'] ??
                bData['updated_at'] ??
                bData['created_at'],
          );

          return bTime.compareTo(aTime);
        });

      final backfillEntries = <String, String>{};
      final backfillNotes = <String, String>{};

      for (final diaryDoc in diaryDocs) {
        final data = diaryDoc.data();

        final year = int.tryParse('${data['year'] ?? ''}');
        final date = int.tryParse('${data['date'] ?? ''}');
        final monthCode = (data['month'] ?? '').toString().trim();

        if (year == null || date == null || monthCode.isEmpty) continue;

        final monthNumber = _monthNumberFromCode(monthCode);
        final dateKey =
            '$year-${monthNumber.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}';

        final mood = _canonicalMoodValue(data['mood']?.toString());
        final note = (data['content'] ?? '').toString().trim();

        if (mood.isNotEmpty && !moods.containsKey(dateKey)) {
          moods[dateKey] = mood;
          backfillEntries[dateKey] = mood;
        }

        if (note.isNotEmpty && !notes.containsKey(dateKey)) {
          notes[dateKey] = note;
          backfillNotes[dateKey] = note;
        }
      }

      if (backfillEntries.isNotEmpty || backfillNotes.isNotEmpty) {
        final payload = <String, dynamic>{
          'uid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (backfillEntries.isNotEmpty) {
          payload['entries'] = backfillEntries;
        }

        if (backfillNotes.isNotEmpty) {
          payload['notes'] = backfillNotes;
        }

        await _moodDoc(uid).set(payload, SetOptions(merge: true));

        for (final entry in backfillEntries.entries) {
          await prefs.setString('$moodPrefix${entry.key}', entry.value);
        }

        for (final entry in backfillNotes.entries) {
          await prefs.setString('$notePrefix${entry.key}', entry.value);
        }
      }
    } catch (_) {
      if (mounted) {
        showCuteTopPopup(
          context,
          title: _t('refresh'),
          message: _t('noDataDesc'),
          type: CutePopupType.info,
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _moodDatabase = moods;
      _noteDatabase = notes;
      _isLoading = false;
    });
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _setLastSelectedDate(DateTime date) {
    _lastSelectedDate = DateTime(date.year, date.month, date.day);
  }

  void _popWithSelectedDate() {
    Navigator.pop(context, _lastSelectedDate);
  }

  int _countEntriesInFocusedMonth() {
    var total = 0;
    for (final key in _moodDatabase.keys) {
      if (key.startsWith(
        '${_focusedDate.year}-${_focusedDate.month.toString().padLeft(2, '0')}',
      )) {
        total++;
      }
    }
    return total;
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset, 1);
    });
  }

  Future<void> _openYearCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MoodYearCalendar()),
    );

    if (!mounted) return;
    if (result is DateTime) {
      setState(() {
        _focusedDate = DateTime(result.year, result.month, 1);
      });
    }
    await _loadMoods();
  }

  Future<void> _openAnalysis() async {
    Widget targetPage = const MoodAnalysis();

    try {
      await PremiumService.instance.refreshPremiumStatus();
      final access = await PremiumService.instance.getAccess();

      if (access.hasPremiumAccess) {
        targetPage = const MoodStatisticPremium();
      }
    } catch (_) {
      targetPage = const MoodAnalysis();
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );

    if (mounted) {
      await _loadMoods();
    }
  }

  Future<void> _openMoodInputForDate(DateTime date) async {
    _setLastSelectedDate(date);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodInput(
          selectedDate: date,
          initialMood: _moodDatabase[_getDateKey(date)],
        ),
      ),
    );

    if (!mounted) return;
    await _loadMoods();
  }

  Future<void> _openDiaryForDate(DateTime date, {String? mood}) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDiaryPage(
          initialDate: date,
          initialMood: mood,
        ),
      ),
    );

    if (mounted) {
      await _loadMoods();
    }
  }

  Future<void> _handleDateTap(DateTime date) async {
    _setLastSelectedDate(date);
    final todayOnly = DateTime.now();
    final today = DateTime(todayOnly.year, todayOnly.month, todayOnly.day);
    final target = DateTime(date.year, date.month, date.day);
    final isFuture = target.isAfter(today);

    final dateKey = _getDateKey(date);
    final mood = _moodDatabase[dateKey];

    if (isFuture) {
      showCuteTopPopup(
        context,
        title: _t('futureLockedTitle'),
        message: _t('futureLockedDesc'),
        type: CutePopupType.info,
      );
      return;
    }

    if (mood != null && mood.trim().isNotEmpty) {
      _showDayPreview(date);
      return;
    }

    await _openMoodInputForDate(date);
  }

  void _showDayPreview(DateTime date) {
    final dateKey = _getDateKey(date);
    final mood = _moodDatabase[dateKey];
    final note = _noteDatabase[dateKey]?.trim() ?? '';
    final dateText = '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.10),
                    offset: Offset(0, 10),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateText, style: _body?.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(_t('previewTitle'), style: _headline),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _moodTint(mood),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _moodAccent(mood).withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 74,
                          height: 74,
                          child: Image.asset(
                            _getDynamicEmojiPath(mood),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) {
                              return Image.asset(
                                _getEmojiImagePath(mood),
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_t('previewMood'), style: _body),
                              const SizedBox(height: 4),
                              Text(
                                _displayMood(mood),
                                style: _headline?.copyWith(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(_t('previewStory'), style: _title),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      note.isNotEmpty ? note : _t('previewNoStory'),
                      style: _bodyDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _openMoodInputForDate(date);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF75B85E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(_t('editMood')),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _openDiaryForDate(date, mood: mood);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F1F1F),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF8DBB69),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(_t('writeDiary')),
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
          ),
        );
      },
    );
  }

  Widget _legendPill({
    required Color color,
    required String label,
    Color textColor = const Color(0xFF1F1F1F),
    Border? border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: border,
      ),
      child: Text(
        label,
        style: _bodyAlt?.copyWith(color: textColor),
      ),
    );
  }

  Widget _navCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF84C96C),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOffset =
        DateTime(_focusedDate.year, _focusedDate.month, 1).weekday - 1;

    final totalSlots = (((firstDayOffset + daysInMonth) / 7).ceil()) * 7;
    final rowCount = (totalSlots / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final cellWidth = (constraints.maxWidth - (6 * spacing)) / 7;
        const cellHeight = 78.0;

        return SizedBox(
          height: rowCount * cellHeight + ((rowCount - 1) * spacing),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSlots,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: cellWidth / cellHeight,
            ),
            itemBuilder: (context, index) {
              if (index < firstDayOffset || index >= firstDayOffset + daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = index - firstDayOffset + 1;
              final date = DateTime(_focusedDate.year, _focusedDate.month, day);
              final dateKey = _getDateKey(date);
              final mood = _moodDatabase[dateKey];

              final now = DateTime.now();
              final today =
                  DateTime(now.year, now.month, now.day);
              final thisDate = DateTime(date.year, date.month, date.day);

              final isToday = thisDate == today;
              final isFuture = thisDate.isAfter(today);

              return GestureDetector(
                onTap: () => _handleDateTap(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFFFFEEF2)
                        : mood != null
                            ? _moodTint(mood)
                            : Colors.white.withOpacity(isFuture ? 0.55 : 0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isToday
                          ? const Color(0xFFE08C9B)
                          : mood != null
                              ? _moodAccent(mood).withOpacity(0.35)
                              : const Color(0xFFEAEDE3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$day',
                        style: _bodyAlt?.copyWith(
                          fontSize: 12,
                          color: isToday
                              ? const Color(0xFFC65F59)
                              : const Color(0xFF6E746B),
                        ),
                      ),
                      const Spacer(),
                      if (mood != null)
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: Image.asset(
                            _getEmojiImagePath(mood),
                            fit: BoxFit.contain,
                          ),
                        )
                      else if (!isFuture)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF84C96C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      else
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF98A095),
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = '${_monthNames[_focusedDate.month - 1]} ${_focusedDate.year}';
    final totalEntries = _countEntriesInFocusedMonth();

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8EA),
        body: SafeArea(
          child: Column(
            children: [
              _buildPageHeader(),
              Expanded(
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF75B85E)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _popWithSelectedDate();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8EA),
        body: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEEF2).withOpacity(0.72),
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9F7E8).withOpacity(0.82),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
              child: Column(
                children: [
                  _buildPageHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _t('subtitle'),
                        style: _body,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _navCircle(
                              icon: Icons.chevron_left_rounded,
                              onTap: () => _changeMonth(-1),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _openYearCalendar,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF84C96C),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.08),
                                        offset: Offset(0, 6),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    monthLabel,
                                    style: _theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _navCircle(
                              icon: Icons.chevron_right_rounded,
                              onTap: () => _changeMonth(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAF1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite_border_rounded,
                                      color: Color(0xFF75B85E),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _replace(_t('recorded'), {'count': '$totalEntries'}),
                                        style: _bodyDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _openAnalysis,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF6F8),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.insights_rounded,
                                      color: Color(0xFFC65F59),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_t('analysis'), style: _bodyDark),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _legendPill(
                              color: const Color(0xFFEAF6DE),
                              label: _t('legendEmpty'),
                            ),
                            _legendPill(
                              color: const Color(0xFFFFEEF2),
                              label: _t('legendToday'),
                            ),
                            _legendPill(
                              color: Colors.white,
                              label: _t('legendDone'),
                              border: Border.all(color: const Color(0xFFE8EBE0)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _openAnalysis,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6F8),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.auto_graph_rounded,
                                    color: Color(0xFFC65F59),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_t('analysis'), style: _title),
                                      const SizedBox(height: 4),
                                      Text(_t('analysisDesc'), style: _body),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Color(0xFF75B85E),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: _weekDays
                                .map(
                                  (day) => Expanded(
                                    child: Text(
                                      day,
                                      textAlign: TextAlign.center,
                                      style: _bodyAlt?.copyWith(
                                        color: const Color(0xFF6E746B),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCalendarGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      )
    );
  }
}