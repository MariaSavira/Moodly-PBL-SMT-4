import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../core/services/streak_service.dart';
import '../../core/services/cloudinary_service.dart';
import '../../services/firestore_diary_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../setting/moodly_settings_support.dart';

class AddDiaryPage extends StatefulWidget {
  final String? diaryId;
  final DateTime? initialDate;
  final String? initialTitle;
  final String? initialContent;
  final List<String>? initialImageUrls;
  final bool? initialIsPublic;
  final String? initialMood;
  final String? initialTime;

  const AddDiaryPage({
    super.key,
    this.diaryId,
    this.initialDate,
    this.initialTitle,
    this.initialContent,
    this.initialImageUrls,
    this.initialIsPublic,
    this.initialMood,
    this.initialTime,
  });

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  static const Color _bg = Color(0xFFF4F8EA);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF5F9E4E);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEFF7E6);
  static const Color _pink = Color(0xFFF3C9D1);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _yellowSoft = Color(0xFFF8F0D0);
  static const Color _blueSoft = Color(0xFFE2F1EE);
  static const Color _redSoft = Color(0xFFFBE3E7);
  static const Color _line = Color(0xFFE4E9D9);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6D7568);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'writeDiary': 'Tulis Diary',
      'editDiary': 'Edit Diary',
      'entryDate': 'Tanggal entry',
      'pickDate': 'Pilih tanggal',
      'mood': 'Mood',
      'changeMood': 'Ganti mood',
      'addPhoto': 'Tambahkan foto',
      'photoDesc': 'Opsional. Maksimal 4 foto.',
      'title': 'Judul',
      'titleHint': 'Judul singkat yang mewakili ceritamu',
      'content': 'Isi diary',
      'contentHint': 'Ceritakan apa yang kamu rasakan atau alami hari ini...',
      'save': 'Simpan',
      'saving': 'Menyimpan...',
      'saveAs': 'Simpan sebagai',
      'pickSpace': 'Pilih dulu ruang untuk cerita ini.',
      'private': 'Privat',
      'privateDesc': 'Hanya kamu yang bisa lihat',
      'public': 'Publik',
      'publicDesc': 'Muncul di diary publik',
      'continueSave': 'Lanjut simpan',
      'cancel': 'Batal',
      'pickPhoto': 'Tambah foto',
      'maxPhotoReached': 'Maksimal 4 foto',
      'moodHappy': 'Senang',
      'moodNeutral': 'Netral',
      'moodSad': 'Sedih',
      'moodAngry': 'Marah',
      'validationContentTitle': 'Diary masih kosong',
      'validationContentDesc': 'Isi dulu ceritamu sebelum disimpan.',
      'saveSuccessTitle': 'Diary tersimpan',
      'saveSuccessDesc': 'Cerita kamu berhasil disimpan.',
      'saveFailTitle': 'Belum berhasil disimpan',
      'saveFailDesc': 'Coba lagi sebentar ya.',
      'pickDateTitle': 'Pilih tanggal entry',
      'dayHint': 'Huruf kecil di atas adalah nama hari.',
      'pickThisDate': 'Pakai tanggal ini',
      'removePhoto': 'Hapus foto',
      'jan': 'Januari',
      'feb': 'Februari',
      'mar': 'Maret',
      'apr': 'April',
      'may': 'Mei',
      'jun': 'Juni',
      'jul': 'Juli',
      'aug': 'Agustus',
      'sep': 'September',
      'oct': 'Oktober',
      'nov': 'November',
      'dec': 'Desember',
      'sun': 'Min',
      'mon': 'Sen',
      'tue': 'Sel',
      'wed': 'Rab',
      'thu': 'Kam',
      'fri': 'Jum',
      'sat': 'Sab',
    },
    'en': {
      'writeDiary': 'Write Diary',
      'editDiary': 'Edit Diary',
      'entryDate': 'Entry date',
      'pickDate': 'Pick date',
      'mood': 'Mood',
      'changeMood': 'Change mood',
      'addPhoto': 'Add photo',
      'photoDesc': 'Optional. Maximum 4 photos.',
      'title': 'Title',
      'titleHint': 'A short title for your story',
      'content': 'Diary content',
      'contentHint': 'Tell what you felt or what happened today...',
      'save': 'Save',
      'saving': 'Saving...',
      'saveAs': 'Save as',
      'pickSpace': 'Choose where this story should live.',
      'private': 'Private',
      'privateDesc': 'Only you can see it',
      'public': 'Public',
      'publicDesc': 'Appears in public diary',
      'continueSave': 'Continue saving',
      'cancel': 'Cancel',
      'pickPhoto': 'Add photo',
      'maxPhotoReached': 'Maximum 4 photos',
      'moodHappy': 'Happy',
      'moodNeutral': 'Neutral',
      'moodSad': 'Sad',
      'moodAngry': 'Angry',
      'validationContentTitle': 'Diary is still empty',
      'validationContentDesc': 'Write your story first before saving.',
      'saveSuccessTitle': 'Diary saved',
      'saveSuccessDesc': 'Your story has been saved.',
      'saveFailTitle': 'Could not save yet',
      'saveFailDesc': 'Please try again in a moment.',
      'pickDateTitle': 'Pick entry date',
      'dayHint': 'The short labels above are weekdays.',
      'pickThisDate': 'Use this date',
      'removePhoto': 'Remove photo',
      'jan': 'January',
      'feb': 'February',
      'mar': 'March',
      'apr': 'April',
      'may': 'May',
      'jun': 'June',
      'jul': 'July',
      'aug': 'August',
      'sep': 'September',
      'oct': 'October',
      'nov': 'November',
      'dec': 'December',
      'sun': 'Sun',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
    },
  };

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  late DateTime _selectedDate;
  late String _selectedMood;
  late String _selectedTime;
  bool _isPublic = false;
  bool _isSaving = false;

  final List<String> _existingImageUrls = [];
  final List<XFile> _pickedImages = [];

  String _t(String key) => _copy[_languageCode]?[key] ?? key;
  TextTheme get _text => Theme.of(context).textTheme;
  bool get _isEditMode => widget.diaryId != null;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];

  Widget _buildPageHeader(String title) {
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
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: _textDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedMood = _normalizeMood(widget.initialMood ?? 'netral');
    _isPublic = widget.initialIsPublic ?? false;
    _selectedTime = widget.initialTime ?? _nowTimeString();

    _existingImageUrls.addAll(widget.initialImageUrls ?? []);

    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  String _normalizeMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'senang':
        return 'senang';
      case 'sad':
      case 'sedih':
        return 'sedih';
      case 'angry':
      case 'marah':
        return 'marah';
      case 'neutral':
      case 'netral':
      default:
        return 'netral';
    }
  }

  String _nowTimeString() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _monthCode(DateTime date) {
    const map = {
      1: 'JAN',
      2: 'FEB',
      3: 'MAR',
      4: 'APR',
      5: 'MEI',
      6: 'JUN',
      7: 'JUL',
      8: 'AGS',
      9: 'SEP',
      10: 'OKT',
      11: 'NOV',
      12: 'DES',
    };
    return map[date.month] ?? 'JAN';
  }

  String _monthName(int month) {
    switch (month) {
      case 1:
        return _t('jan');
      case 2:
        return _t('feb');
      case 3:
        return _t('mar');
      case 4:
        return _t('apr');
      case 5:
        return _t('may');
      case 6:
        return _t('jun');
      case 7:
        return _t('jul');
      case 8:
        return _t('aug');
      case 9:
        return _t('sep');
      case 10:
        return _t('oct');
      case 11:
        return _t('nov');
      case 12:
        return _t('dec');
      default:
        return '';
    }
  }

  String _formattedDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  ({String label, Color bg, Color fg, String png, String video})
      _moodMeta(String mood) {
    switch (mood) {
      case 'senang':
        return (
          label: _t('moodHappy'),
          bg: const Color(0xFFE5F6DA),
          fg: const Color(0xFF63A94E),
          png: 'assets/emoji/emoji_senang.png',
          video: 'assets/emoji/emoji_senang_gerak.mp4',
        );
      case 'sedih':
        return (
          label: _t('moodSad'),
          bg: _blueSoft,
          fg: const Color(0xFF6DA596),
          png: 'assets/emoji/emoji_sedih.png',
          video: 'assets/emoji/emoji_sedih_gerak.mp4',
        );
      case 'marah':
        return (
          label: _t('moodAngry'),
          bg: _redSoft,
          fg: const Color(0xFFC96D79),
          png: 'assets/emoji/emoji_marah.png',
          video: 'assets/emoji/emoji_marah_gerak.mp4',
        );
      case 'netral':
      default:
        return (
          label: _t('moodNeutral'),
          bg: _yellowSoft,
          fg: const Color(0xFFB99737),
          png: 'assets/emoji/emoji_netral.png',
          video: 'assets/emoji/emoji_netral_gerak.mp4',
        );
    }
  }

  Future<void> _pickImages() async {
    final remaining = 4 - (_existingImageUrls.length + _pickedImages.length);
    if (remaining <= 0) {
      showCuteTopPopup(
        context,
        title: _t('maxPhotoReached'),
        message: _t('photoDesc'),
        type: CutePopupType.info,
      );
      return;
    }

    final files = await _picker.pickMultiImage(imageQuality: 82);
    if (files.isEmpty) return;

    setState(() {
      _pickedImages.addAll(files.take(remaining));
    });
  }

  Future<void> _pickDate() async {
    DateTime tempDate = _selectedDate;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.only(top: 32),
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _line,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _t('pickDateTitle'),
                        style: _text.headlineLarge?.copyWith(
                          color: _textDark,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t('dayHint'),
                        textAlign: TextAlign.center,
                        style: _text.bodyMedium?.copyWith(
                          color: _textSoft,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _softShadow,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _formattedDate(tempDate),
                              style: _text.titleMedium?.copyWith(
                                color: _textDark,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context)
                                    .colorScheme
                                    .copyWith(primary: _green),
                              ),
                              child: CalendarDatePicker(
                                initialDate: tempDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                onDateChanged: (value) {
                                  setModalState(() {
                                    tempDate = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(tempDate),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            _t('pickThisDate'),
                            style: _text.labelLarge,
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
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _openMoodPicker() async {
    String tempMood = _selectedMood;

    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Mood Picker',
      barrierColor: Colors.black.withOpacity(0.42),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t('changeMood'),
                        style: _text.headlineLarge?.copyWith(
                          color: _textDark,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.02,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _moodPickerTile(
                            moodKey: 'senang',
                            active: tempMood == 'senang',
                            onTap: () {
                              setModalState(() {
                                tempMood = 'senang';
                              });
                            },
                          ),
                          _moodPickerTile(
                            moodKey: 'netral',
                            active: tempMood == 'netral',
                            onTap: () {
                              setModalState(() {
                                tempMood = 'netral';
                              });
                            },
                          ),
                          _moodPickerTile(
                            moodKey: 'sedih',
                            active: tempMood == 'sedih',
                            onTap: () {
                              setModalState(() {
                                tempMood = 'sedih';
                              });
                            },
                          ),
                          _moodPickerTile(
                            moodKey: 'marah',
                            active: tempMood == 'marah',
                            onTap: () {
                              setModalState(() {
                                tempMood = 'marah';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(tempMood),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            _t('changeMood'),
                            style: _text.labelLarge,
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
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedMood = result;
      });
    }
  }

  Widget _moodPickerTile({
    required String moodKey,
    required bool active,
    required VoidCallback onTap,
  }) {
    final mood = _moodMeta(moodKey);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: mood.bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? mood.fg : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MoodMedia(
              pngAsset: mood.png,
              videoAsset: mood.video,
              active: active,
              size: 62,
            ),
            const SizedBox(height: 12),
            Text(
              mood.label,
              style: _text.titleMedium?.copyWith(
                color: _textDark,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _pickVisibility() {
    bool tempIsPublic = _isPublic;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.only(top: 32),
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _line,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _t('saveAs'),
                        style: _text.headlineLarge?.copyWith(
                          color: _textDark,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t('pickSpace'),
                        textAlign: TextAlign.center,
                        style: _text.bodyMedium?.copyWith(
                          color: _textSoft,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _visibilityTile(
                              active: !tempIsPublic,
                              title: _t('private'),
                              desc: _t('privateDesc'),
                              icon: Icons.lock_rounded,
                              color: _pink,
                              onTap: () {
                                setModalState(() {
                                  tempIsPublic = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _visibilityTile(
                              active: tempIsPublic,
                              title: _t('public'),
                              desc: _t('publicDesc'),
                              icon: Icons.public_rounded,
                              color: _greenSoft,
                              onTap: () {
                                setModalState(() {
                                  tempIsPublic = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(sheetContext).pop(null),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _line),
                                foregroundColor: _textSoft,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                _t('cancel'),
                                style: _text.bodySmall?.copyWith(
                                  color: _textSoft,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(sheetContext).pop(tempIsPublic),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                _t('continueSave'),
                                style: _text.labelLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _visibilityTile({
    required bool active,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.42) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? color : _line,
            width: 1.6,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: active ? _textDark : _greenDark,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: _text.titleMedium?.copyWith(
                color: _textDark,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: _text.bodyMedium?.copyWith(
                color: _textSoft,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDiary() async {
    if (_isSaving) return;

    if (_contentController.text.trim().isEmpty) {
      showCuteTopPopup(
        context,
        title: _t('validationContentTitle'),
        message: _t('validationContentDesc'),
        type: CutePopupType.info,
      );
      return;
    }

    final visibility = await _pickVisibility();
    if (visibility == null) return;

    setState(() {
      _isPublic = visibility;
      _isSaving = true;
    });

    try {
      final uploadedImages = <String>[];

      if (_pickedImages.isNotEmpty) {
        final files = _pickedImages.map((e) => File(e.path)).toList();
        final result = await CloudinaryService.uploadDiaryImages(files);
        uploadedImages.addAll(
          result.map((e) => (e['imageUrl'] ?? '').trim()).where((e) => e.isNotEmpty),
        );
      }

      final allImages = [
        ..._existingImageUrls,
        ...uploadedImages,
      ];

      final service = FirestoreDiaryService();
      final now = DateTime.now();
      final shouldClaimDiaryMission =
          _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;

      if (_isEditMode) {
        final existing = await service.getDiaryById(widget.diaryId!);
        if (existing == null) {
          throw Exception('Diary tidak ditemukan.');
        }

        await service.updateDiary(
          diaryId: existing.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          time: existing.time,
          date: _selectedDate.day,
          month: _monthCode(_selectedDate),
          year: _selectedDate.year,
          isPublic: _isPublic,
          mood: _selectedMood,
          username: existing.username,
          profileImage: existing.profileImage,
          uid: existing.uid,
          images: allImages,
          imageUrl: allImages.isNotEmpty ? allImages.first : '',
          createdAt: existing.createdAt,
          likes: existing.likes,
          comments: existing.comments,
          likedBy: existing.likedBy,
        );
      } else {
        await service.createDiary(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          time: _selectedTime,
          date: _selectedDate.day,
          month: _monthCode(_selectedDate),
          year: _selectedDate.year,
          isPublic: _isPublic,
          mood: _selectedMood,
          images: allImages,
          imageUrl: allImages.isNotEmpty ? allImages.first : '',
        );
      }

      if (!mounted) return;

      if (shouldClaimDiaryMission) {
        await StreakService.instance.claimDiaryBonus();
      }
      
      showCuteTopPopup(
        context,
        title: _t('saveSuccessTitle'),
        message: _t('saveSuccessDesc'),
        type: CutePopupType.success,
      );

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pop(
        context,
        {
          'saved': true,
          'mood': _selectedMood,
          'date': _selectedDate,
          'isPublic': _isPublic,
        },
      );
    } catch (e) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('saveFailTitle'),
        message: '${_t('saveFailDesc')}\n$e',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTopSelectors() {
    final mood = _moodMeta(_selectedMood);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _greenMint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: _greenDark,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('entryDate'),
                            style: _text.bodySmall?.copyWith(
                              color: _textSoft,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formattedDate(_selectedDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _text.titleMedium?.copyWith(
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: _openMoodPicker,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: mood.bg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    _MoodMedia(
                      pngAsset: mood.png,
                      videoAsset: mood.video,
                      active: true,
                      size: 36,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('mood'),
                            style: _text.bodySmall?.copyWith(
                              color: _textSoft,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mood.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _text.titleMedium?.copyWith(
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    final totalCount = _existingImageUrls.length + _pickedImages.length;

    return Container(
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
            _t('addPhoto'),
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _t('photoDesc'),
            style: _text.bodyMedium?.copyWith(color: _textSoft),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 108,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImageUrls.asMap().entries.map((entry) {
                  final index = entry.key;
                  final url = entry.value;
                  return _networkPhotoTile(
                    imageUrl: url,
                    onRemove: () {
                      setState(() {
                        _existingImageUrls.removeAt(index);
                      });
                    },
                  );
                }),
                ..._pickedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return _localPhotoTile(
                    file: File(file.path),
                    onRemove: () {
                      setState(() {
                        _pickedImages.removeAt(index);
                      });
                    },
                  );
                }),
                if (totalCount < 4) _addPhotoTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPhotoTile() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: _pickImages,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 126,
          decoration: BoxDecoration(
            color: _greenMint,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _line),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: _greenDark,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t('pickPhoto'),
                style: _text.titleMedium?.copyWith(
                  color: _textDark,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _networkPhotoTile({
    required String imageUrl,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              imageUrl,
              width: 126,
              height: 108,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: _removePhotoButton(onRemove),
          ),
        ],
      ),
    );
  }

  Widget _localPhotoTile({
    required File file,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.file(
              file,
              width: 126,
              height: 108,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: _removePhotoButton(onRemove),
          ),
        ],
      ),
    );
  }

  Widget _removePhotoButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.54),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
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
            _t('title'),
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            style: _text.titleMedium?.copyWith(
              color: _textDark,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: _t('titleHint'),
              hintStyle: _text.bodyMedium?.copyWith(
                color: _textSoft.withOpacity(0.78),
                fontSize: 14,
              ),
              filled: true,
              fillColor: _pinkSoft,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: _pink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
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
            _t('content'),
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            minLines: 10,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1000),
            ],
            style: _text.bodyMedium?.copyWith(
              color: _textDark,
              fontSize: 16,
              height: 1.7,
            ),
            decoration: InputDecoration(
              hintText: _t('contentHint'),
              hintStyle: _text.bodyMedium?.copyWith(
                color: _textSoft.withOpacity(0.78),
                fontSize: 14,
                height: 1.6,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: _green, width: 1.5),
              ),
              counterStyle: _text.bodySmall?.copyWith(
                color: _textSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _isEditMode ? _t('editDiary') : _t('writeDiary');

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -46,
            right: -32,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinkSoft.withOpacity(0.72),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            left: -74,
            child: Container(
              width: 188,
              height: 188,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.82),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildPageHeader(pageTitle),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    child: Column(
                      children: [
                        _buildTopSelectors(),
                        const SizedBox(height: 14),
                        _buildPhotosSection(),
                        const SizedBox(height: 14),
                        _buildTitleSection(),
                        const SizedBox(height: 14),
                        _buildContentSection(),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveDiary,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: _green.withOpacity(0.6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _isSaving ? _t('saving') : _t('save'),
              style: _text.labelLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodMedia extends StatefulWidget {
  final String pngAsset;
  final String videoAsset;
  final bool active;
  final double size;

  const _MoodMedia({
    required this.pngAsset,
    required this.videoAsset,
    required this.active,
    required this.size,
  });

  @override
  State<_MoodMedia> createState() => _MoodMediaState();
}

class _MoodMediaState extends State<_MoodMedia> {
  VideoPlayerController? _controller;
  bool _failedVideo = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant _MoodMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.videoAsset != widget.videoAsset) {
      _disposeController();
      _failedVideo = false;
      _setup();
    }
  }

  Future<void> _setup() async {
    if (!widget.active) return;

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
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failedVideo = true;
      });
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.active &&
        !_failedVideo &&
        _controller != null &&
        _controller!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      );
    }

    return Image.asset(
      widget.pngAsset,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}