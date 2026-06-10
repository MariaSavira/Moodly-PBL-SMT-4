import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../core/services/streak_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../private_diary/add_diary_page.dart';
import '../setting/moodly_settings_support.dart';

class MoodInput extends StatefulWidget {
  final DateTime? selectedDate;
  final String? initialMood;

  const MoodInput({super.key, this.selectedDate, this.initialMood});

  @override
  State<MoodInput> createState() => _MoodInputState();
}

class _MoodInputState extends State<MoodInput> {
  static const Color _bg = Color(0xFFF4F8EA);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF5F9E4E);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _yellowSoft = Color(0xFFF8F0D0);
  static const Color _blueSoft = Color(0xFFE2F1EE);
  static const Color _redSoft = Color(0xFFFBE3E7);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6D7568);

  late final DateTime _selectedDate;
  late final PageController _pageController;

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  String? _selectedMoodKey;
  int _previewIndex = 1;
  double _pageValue = 1;
  bool _isSaving = false;

  final List<_MoodOption> _moods = const [
    _MoodOption(
      key: 'happy',
      storageValue: 'Senang',
      idLabel: 'Senang',
      enLabel: 'Happy',
      idHint: 'terasa ringan dan hangat',
      enHint: 'feels light and warm',
      bg: Color(0xFFE5F6DA),
      fg: Color(0xFF63A94E),
      pngAsset: 'assets/emoji/emoji_senang.png',
      videoAsset: 'assets/emoji/emoji_senang_gerak.mp4',
    ),
    _MoodOption(
      key: 'neutral',
      storageValue: 'Netral',
      idLabel: 'Netral',
      enLabel: 'Neutral',
      idHint: 'terasa tenang dan stabil',
      enHint: 'feels calm and steady',
      bg: Color(0xFFF8F0D0),
      fg: Color(0xFFB99737),
      pngAsset: 'assets/emoji/emoji_netral.png',
      videoAsset: 'assets/emoji/emoji_netral_gerak.mp4',
    ),
    _MoodOption(
      key: 'sad',
      storageValue: 'Sedih',
      idLabel: 'Sedih',
      enLabel: 'Sad',
      idHint: 'terasa pelan dan sendu',
      enHint: 'feels slow and low',
      bg: Color(0xFFE2F1EE),
      fg: Color(0xFF6DA596),
      pngAsset: 'assets/emoji/emoji_sedih.png',
      videoAsset: 'assets/emoji/emoji_sedih_gerak.mp4',
    ),
    _MoodOption(
      key: 'angry',
      storageValue: 'Marah',
      idLabel: 'Marah',
      enLabel: 'Angry',
      idHint: 'terasa penuh dan sensitif',
      enHint: 'feels intense and sensitive',
      bg: Color(0xFFFBE3E7),
      fg: Color(0xFFC96D79),
      pngAsset: 'assets/emoji/emoji_marah.png',
      videoAsset: 'assets/emoji/emoji_marah_gerak.mp4',
    ),
  ];

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Mood Entry',
      'loading': 'Menyimpan...',
      'chooseFirstTitle': 'Pilih mood dulu',
      'chooseFirstDesc': 'Biar sistem tidak menebak-nebak perasaanmu hari ini.',
      'savedTitle': 'Mood tersimpan',
      'savedDesc': 'Mood "{mood}" berhasil disimpan.',
      'savedWithDiaryTitle': 'Mood dan diary tersimpan',
      'savedWithDiaryDesc': 'Mood "{mood}" dan diary berhasil disimpan.',
      'saveFailedTitle': 'Gagal menyimpan',
      'saveFailedDesc': 'Coba lagi sebentar ya.',
      'heroTitle': 'Pilih perasaanmu hari ini',
      'heroSub': 'Geser pelan lalu tekan mood yang paling mewakili kamu.',
      'previewLabel': 'Mood terpilih',
      'storyTitle': 'Ingin menambahkan cerita singkat?',
      'storySub':
          'Kalau mau, lanjutkan ke diary biar ceritanya sekalian tersimpan.',
      'storyYes': 'Ya, aku ingin cerita',
      'storyNo': 'Tidak, simpan saja',
      'selected': 'Mood ini sudah dipilih',
      'chipPicked': 'Sudah dipilih',
      'tapHint': 'Tekan kartu untuk memilih',
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
      'moodSenang': 'Senang',
      'moodNetral': 'Netral',
      'moodSedih': 'Sedih',
      'moodMarah': 'Marah',
      'hintSenang': 'terasa ringan dan hangat',
      'hintNetral': 'terasa tenang dan stabil',
      'hintSedih': 'terasa pelan dan sendu',
      'hintMarah': 'terasa penuh dan sensitif',
    },
    'en': {
      'title': 'Mood Entry',
      'loading': 'Saving...',
      'chooseFirstTitle': 'Choose a mood first',
      'chooseFirstDesc':
          'So the system does not awkwardly guess your feelings today.',
      'savedTitle': 'Mood saved',
      'savedDesc': 'Mood "{mood}" has been saved.',
      'savedWithDiaryTitle': 'Mood and diary saved',
      'savedWithDiaryDesc': 'Mood "{mood}" and diary have been saved.',
      'saveFailedTitle': 'Failed to save',
      'saveFailedDesc': 'Please try again in a moment.',
      'heroTitle': 'Choose how you feel today',
      'heroSub': 'Slide gently and tap the mood that fits you best.',
      'previewLabel': 'Selected mood',
      'storyTitle': 'Want to add a short story?',
      'storySub':
          'You can continue to the diary page so your mood and story are saved together.',
      'storyYes': 'Yes, I want to share',
      'storyNo': 'No, just save it',
      'selected': 'This mood is selected',
      'chipPicked': 'Selected',
      'tapHint': 'Tap the card to select it',
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
      'moodSenang': 'Happy',
      'moodNetral': 'Neutral',
      'moodSedih': 'Sad',
      'moodMarah': 'Angry',
      'hintSenang': 'feels light and warm',
      'hintNetral': 'feels calm and steady',
      'hintSedih': 'feels slow and low',
      'hintMarah': 'feels intense and sensitive',
    },
  };

  String _t(String key) => _copy[_languageCode]?[key] ?? key;
  TextTheme get _text => Theme.of(context).textTheme;

  List<BoxShadow> get _softShadow => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
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
              _t('title'),
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: _textDark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();

    final normalizedInitial = _normalizeIncomingMood(widget.initialMood);
    final initialIndex = _resolveInitialIndex(normalizedInitial);

    _selectedMoodKey = normalizedInitial;
    _previewIndex = initialIndex;
    _pageValue = initialIndex.toDouble();

    _pageController =
        PageController(initialPage: initialIndex, viewportFraction: 0.70)
          ..addListener(() {
            if (!_pageController.hasClients) return;
            final value = _pageController.page ?? initialIndex.toDouble();
            if (!mounted) return;
            setState(() {
              _pageValue = value;
              _previewIndex = value.round().clamp(0, _moods.length - 1);
            });
          });

    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _hydrateLanguage();
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    _pageController.dispose();
    super.dispose();
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

  String? _normalizeIncomingMood(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final mood = raw.trim().toLowerCase();

    if (mood == 'happy' || mood == 'senang') return 'happy';
    if (mood == 'neutral' || mood == 'netral') return 'neutral';
    if (mood == 'sad' || mood == 'sedih') return 'sad';
    if (mood == 'angry' || mood == 'marah') return 'angry';
    return null;
  }

  int _resolveInitialIndex(String? moodKey) {
    if (moodKey == null) return 1;
    final index = _moods.indexWhere((m) => m.key == moodKey);
    return index >= 0 ? index : 1;
  }

  _MoodOption get _previewMood => _moods[_previewIndex];

  _MoodOption get _displayMood {
    if (_selectedMoodKey == null) return _previewMood;
    return _moods.firstWhere(
      (m) => m.key == _selectedMoodKey,
      orElse: () => _previewMood,
    );
  }

  String _monthName(int month) => _t('month$month');

  String _formattedDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _moodPrefKey(String uid, String dateKey) => 'mood_${uid}_$dateKey';

  DocumentReference<Map<String, dynamic>> _moodDoc(String uid) {
    return FirebaseFirestore.instance.collection('moods').doc(uid);
  }

  void _selectMood(_MoodOption mood, int index) {
    setState(() {
      _selectedMoodKey = mood.key;
      _previewIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<bool> _saveMood({bool showSuccess = true}) async {
    if (_selectedMoodKey == null) {
      showCuteTopPopup(
        context,
        title: _t('chooseFirstTitle'),
        message: _t('chooseFirstDesc'),
        type: CutePopupType.info,
      );
      return false;
    }

    final uid = _uid;
    if (uid == null) {
      showCuteTopPopup(
        context,
        title: _t('saveFailedTitle'),
        message: _t('saveFailedDesc'),
        type: CutePopupType.error,
      );
      return false;
    }

    final mood = _moods.firstWhere((m) => m.key == _selectedMoodKey);
    final dateKey = _dateKey(_selectedDate);

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_moodPrefKey(uid, dateKey), mood.storageValue);

      await _moodDoc(uid).set({
        'uid': uid,
        'entries': {dateKey: mood.storageValue},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final now = DateTime.now();
      final isToday =
          _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;

      if (isToday) {
        await StreakService.instance.claimMoodCheckIn();
      }

      if (!mounted) return true;

      if (showSuccess) {
        showCuteTopPopup(
          context,
          title: _t('savedTitle'),
          message: _t(
            'savedDesc',
          ).replaceAll('{mood}', mood.label(_languageCode)),
          type: CutePopupType.success,
        );
      }

      return true;
    } catch (_) {
      if (mounted) {
        showCuteTopPopup(
          context,
          title: _t('saveFailedTitle'),
          message: _t('saveFailedDesc'),
          type: CutePopupType.error,
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveOnly() async {
    final ok = await _saveMood(showSuccess: true);
    if (!mounted || !ok) return;
    Navigator.pop(context, true);
  }

  Future<void> _continueToDiary() async {
    final ok = await _saveMood(showSuccess: false);
    if (!mounted || !ok || _selectedMoodKey == null) return;

    final mood = _moods.firstWhere((m) => m.key == _selectedMoodKey);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDiaryPage(
          initialDate: _selectedDate,
          initialMood: mood.key,
          initialTime:
              '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
        ),
      ),
    );

    if (!mounted) return;
    if (result != null) {
      showCuteTopPopup(
        context,
        title: _t('savedWithDiaryTitle'),
        message: _t(
          'savedWithDiaryDesc',
        ).replaceAll('{mood}', mood.label(_languageCode)),
        type: CutePopupType.success,
      );

      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Widget _heroCard() {
    final mood = _displayMood;
    final animate = _selectedMoodKey == mood.key;

    return Container(
      padding: const EdgeInsets.all(22),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _pinkSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _formattedDate(_selectedDate),
                    style: _text.bodySmall?.copyWith(
                      color: const Color(0xFF8C6C76),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _t('heroTitle'),
                  style: _text.headlineLarge?.copyWith(
                    color: _textDark,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _t('heroSub'),
                  style: _text.bodyMedium?.copyWith(
                    color: _textSoft,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(shape: BoxShape.circle, color: mood.bg),
            alignment: Alignment.center,
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: _MoodAsset(
                pngAsset: mood.pngAsset,
                videoAsset: mood.videoAsset,
                animate: animate,
                size: 58,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedMoodCard() {
    final mood = _displayMood;
    final animate = _selectedMoodKey == mood.key;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(shape: BoxShape.circle, color: mood.bg),
            alignment: Alignment.center,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: _MoodAsset(
                pngAsset: mood.pngAsset,
                videoAsset: mood.videoAsset,
                animate: animate,
                size: 48,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('previewLabel'),
                  style: _text.bodyMedium?.copyWith(
                    color: _textSoft,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mood.label(_languageCode),
                  style: _text.headlineLarge?.copyWith(
                    color: _textDark,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mood.hint(_languageCode),
                  style: _text.bodyMedium?.copyWith(
                    color: _textSoft,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carouselCard(_MoodOption mood, int index) {
    final distance = (_pageValue - index).abs().clamp(0.0, 1.0);
    final scale = 1 - (distance * 0.10);
    final opacity = 1 - (distance * 0.28);

    final isSelected = _selectedMoodKey == mood.key;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: () => _selectMood(mood, index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: mood.bg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isSelected ? mood.fg : mood.fg.withOpacity(0.45),
                width: isSelected ? 4 : 2.5,
              ),
              boxShadow: _softShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.45),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: _MoodAsset(
                        pngAsset: mood.pngAsset,
                        videoAsset: mood.videoAsset,
                        animate: isSelected,
                        size: 78,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    mood.label(_languageCode),
                    textAlign: TextAlign.center,
                    style: _text.headlineLarge?.copyWith(
                      color: _textDark,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isSelected ? _t('chipPicked') : mood.hint(_languageCode),
                    textAlign: TextAlign.center,
                    style: _text.bodyMedium?.copyWith(
                      color: mood.fg,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _t('tapHint'),
                    style: _text.bodyMedium?.copyWith(
                      color: _textSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _carouselSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _greenSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 420,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                return _carouselCard(_moods[index], index);
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_moods.length, (index) {
              final active = index == _previewIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: active ? 34 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: active ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _storySection() {
    if (_selectedMoodKey == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('storyTitle'),
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _t('storySub'),
            style: _text.bodyMedium?.copyWith(
              color: _textSoft,
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _continueToDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(_t('storyYes'), style: _text.labelLarge),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: OutlinedButton(
              onPressed: _isSaving ? null : _saveOnly,
              style: OutlinedButton.styleFrom(
                foregroundColor: _textDark,
                side: BorderSide(color: _greenDark.withOpacity(0.65), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                _isSaving ? _t('loading') : _t('storyNo'),
                style: _text.titleMedium?.copyWith(color: _textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _isSaving
          ? SafeArea(
              child: Column(
                children: [
                  _buildPageHeader(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(_greenDark),
                          ),
                          const SizedBox(height: 16),
                          Text(_t('loading'), style: _text.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Stack(
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
                      color: _greenSoft.withOpacity(0.55),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                    children: [
                      _buildPageHeader(),
                      const SizedBox(height: 6),
                      _heroCard(),
                      const SizedBox(height: 16),
                      _selectedMoodCard(),
                      const SizedBox(height: 16),
                      _carouselSection(),
                      const SizedBox(height: 18),
                      _storySection(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _MoodOption {
  final String key;
  final String storageValue;
  final String idLabel;
  final String enLabel;
  final String idHint;
  final String enHint;
  final Color bg;
  final Color fg;
  final String pngAsset;
  final String videoAsset;

  const _MoodOption({
    required this.key,
    required this.storageValue,
    required this.idLabel,
    required this.enLabel,
    required this.idHint,
    required this.enHint,
    required this.bg,
    required this.fg,
    required this.pngAsset,
    required this.videoAsset,
  });

  String label(String languageCode) => languageCode == 'en' ? enLabel : idLabel;
  String hint(String languageCode) => languageCode == 'en' ? enHint : idHint;
}

class _MoodAsset extends StatefulWidget {
  final String pngAsset;
  final String videoAsset;
  final bool animate;
  final double size;

  const _MoodAsset({
    required this.pngAsset,
    required this.videoAsset,
    required this.animate,
    required this.size,
  });

  @override
  State<_MoodAsset> createState() => _MoodAssetState();
}

class _MoodAssetState extends State<_MoodAsset> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant _MoodAsset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.videoAsset != widget.videoAsset) {
      _disposeController();
      _prepare();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _prepare() async {
    if (!widget.animate) return;

    try {
      final controller = VideoPlayerController.asset(widget.videoAsset);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
      });
    }
  }

  Future<void> _disposeController() async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      await old.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate ||
        _failed ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Image.asset(
        widget.pngAsset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
