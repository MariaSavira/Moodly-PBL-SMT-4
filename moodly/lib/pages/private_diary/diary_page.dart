import 'package:flutter/material.dart';

import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';
import '../../widgets/moodly_bottom_navbar.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';
import '../setting/moodly_settings_support.dart';
import 'add_diary_page.dart';

class DiaryPage extends StatefulWidget {
  final String month;
  final int year;
  final String? openDiaryId;

  const DiaryPage({
    super.key,
    required this.month,
    required this.year,
    this.openDiaryId,
  });

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
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
      'entriesThisMonth': 'catatan bulan ini',
      'latest': 'terbaru',
      'week': 'Pekan',
      'edit': 'Edit',
      'delete': 'Hapus',
      'cancel': 'Batal',
      'deleteSelected': 'Hapus pilihan',
      'selectAll': 'Pilih semua',
      'selectWeek': 'Pilih pekan ini',
      'selectedCount': 'dipilih',
      'emptyTitle': 'Belum ada diary di bulan ini',
      'emptyDesc': 'Nanti halaman ini akan ramai saat kamu mulai menulis. Untuk sekarang, ya masih sepi. Tragis tapi bersih.',
      'private': 'Privat',
      'public': 'Publik',
      'moodHappy': 'Senang',
      'moodNeutral': 'Netral',
      'moodSad': 'Sedih',
      'moodAngry': 'Marah',
      'deleteAskTitle': 'Hapus diary ini?',
      'deleteAskDesc': 'Cerita yang dihapus tidak bisa dipanggil balik seenaknya.',
      'deleteManyTitle': 'Hapus pilihan?',
      'deleteManyDesc': 'Semua diary terpilih akan dihapus permanen.',
      'deleteSuccessTitle': 'Diary dihapus',
      'deleteSuccessDesc': 'Cerita yang dipilih berhasil dihapus.',
      'deleteFailTitle': 'Gagal menghapus',
      'deleteFailDesc': 'Coba lagi sebentar ya.',
      'detailTitle': 'Lihat Diary',
      'writtenAt': 'Ditulis',
      'entryDate': 'Tanggal entry',
      'updatedAt': 'Diperbarui',
      'openImage': 'Lihat foto',
      'morePhotos': 'foto lain',
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
      'entriesThisMonth': 'entries this month',
      'latest': 'latest',
      'week': 'Week',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'deleteSelected': 'Delete selected',
      'selectAll': 'Select all',
      'selectWeek': 'Select this week',
      'selectedCount': 'selected',
      'emptyTitle': 'No diary entries this month',
      'emptyDesc': 'This page will fill up once you start writing. For now, it is empty. Very poetic, unfortunately.',
      'private': 'Private',
      'public': 'Public',
      'moodHappy': 'Happy',
      'moodNeutral': 'Neutral',
      'moodSad': 'Sad',
      'moodAngry': 'Angry',
      'deleteAskTitle': 'Delete this diary?',
      'deleteAskDesc': 'Once deleted, this story will not politely come back.',
      'deleteManyTitle': 'Delete selected entries?',
      'deleteManyDesc': 'All selected diary entries will be permanently deleted.',
      'deleteSuccessTitle': 'Diary deleted',
      'deleteSuccessDesc': 'Selected entries have been deleted.',
      'deleteFailTitle': 'Failed to delete',
      'deleteFailDesc': 'Please try again in a moment.',
      'detailTitle': 'Diary Detail',
      'writtenAt': 'Written at',
      'entryDate': 'Entry date',
      'updatedAt': 'Updated',
      'openImage': 'View image',
      'morePhotos': 'more photos',
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

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  bool _selectionMode = false;
  bool _handledInitialOpen = false;
  final Set<String> _selectedIds = <String>{};
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

  int _monthNumber(String code) {
    const map = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MEI': 5,
      'JUN': 6,
      'JUL': 7,
      'AGS': 8,
      'SEP': 9,
      'OKT': 10,
      'NOV': 11,
      'DES': 12,
    };
    return map[code.toUpperCase()] ?? 1;
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

  String _formatEntryLine(DiaryModel diary) {
    final dt = diary.entryDateTime;
    return '${_weekdayShort(dt.weekday)}, ${dt.day} ${_monthNameFromCode(diary.month)} • ${diary.time}';
  }

  int _weekOfMonth(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final startGrid = startOfMonth.subtract(
      Duration(days: startOfMonth.weekday % 7),
    );
    final diff = date.difference(startGrid).inDays;
    return (diff ~/ 7) + 1;
  }

  Map<int, List<DiaryModel>> _groupByWeek(List<DiaryModel> diaries) {
    final grouped = <int, List<DiaryModel>>{};

    for (final diary in diaries) {
      final week = _weekOfMonth(diary.entryDateTime);
      grouped.putIfAbsent(week, () => []);
      grouped[week]!.add(diary);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final sorted = <int, List<DiaryModel>>{};
    for (final entry in entries) {
      entry.value.sort((a, b) => b.entryDateTime.compareTo(a.entryDateTime));
      sorted[entry.key] = entry.value;
    }
    return sorted;
  }

  ({String label, Color bg, Color fg, String asset}) _moodMeta(String mood) {
    final raw = mood.trim().toLowerCase();

    if (raw == 'happy' || raw == 'senang') {
      return (
        label: _t('moodHappy'),
        bg: _greenSoft,
        fg: _greenDark,
        asset: 'assets/emoji/emoji_senang.png',
      );
    }
    if (raw == 'sad' || raw == 'sedih') {
      return (
        label: _t('moodSad'),
        bg: _blueSoft,
        fg: const Color(0xFF6DA596),
        asset: 'assets/emoji/emoji_sedih.png',
      );
    }
    if (raw == 'angry' || raw == 'marah') {
      return (
        label: _t('moodAngry'),
        bg: _redSoft,
        fg: const Color(0xFFC96D79),
        asset: 'assets/emoji/emoji_marah.png',
      );
    }

    return (
      label: _t('moodNeutral'),
      bg: _yellowSoft,
      fg: const Color(0xFFB99737),
      asset: 'assets/emoji/emoji_netral.png',
    );
  }

  Future<void> _openDiaryDetail(DiaryModel diary) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _DiaryDetailPage(
          diary: diary,
          languageCode: _languageCode,
          monthNameBuilder: _monthNameFromCode,
          weekdayBuilder: _weekdayShort,
          moodMetaBuilder: _moodMeta,
          onEdit: () => _editDiary(diary),
          onDelete: () => _deleteOne(diary),
        ),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      setState(() {});
    }
  }

  Future<bool> _editDiary(DiaryModel diary) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDiaryPage(
          diaryId: diary.id,
          initialDate: diary.entryDateTime,
          initialTitle: diary.title,
          initialContent: diary.content,
          initialImageUrls: diary.images,
          initialIsPublic: diary.isPublic,
          initialMood: diary.mood,
          initialTime: diary.time,
        ),
      ),
    );

    if (!mounted) return false;

    final saved = result == true || (result is Map && result['saved'] == true);
    if (saved) {
      setState(() {});
    }
    return saved;
  }

  Future<bool> _deleteOne(DiaryModel diary) async {
    final confirmed = await _showDeleteDialog(
      title: _t('deleteAskTitle'),
      message: _t('deleteAskDesc'),
    );

    if (confirmed != true) return false;

    try {
      await FirestoreDiaryService().deleteDiary(diary.id);

      if (!mounted) return true;

      showCuteTopPopup(
        context,
        title: _t('deleteSuccessTitle'),
        message: _t('deleteSuccessDesc'),
        type: CutePopupType.success,
      );
      return true;
    } catch (_) {
      if (!mounted) return false;

      showCuteTopPopup(
        context,
        title: _t('deleteFailTitle'),
        message: _t('deleteFailDesc'),
        type: CutePopupType.error,
      );
      return false;
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await _showDeleteDialog(
      title: _t('deleteManyTitle'),
      message: _t('deleteManyDesc'),
    );

    if (confirmed != true) return;

    try {
      for (final id in _selectedIds) {
        await FirestoreDiaryService().deleteDiary(id);
      }

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });

      showCuteTopPopup(
        context,
        title: _t('deleteSuccessTitle'),
        message: _t('deleteSuccessDesc'),
        type: CutePopupType.success,
      );
    } catch (_) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('deleteFailTitle'),
        message: _t('deleteFailDesc'),
        type: CutePopupType.error,
      );
    }
  }

  Future<bool?> _showDeleteDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: _text.titleMedium?.copyWith(
              color: _textDark,
              fontSize: 20,
            ),
          ),
          content: Text(
            message,
            style: _text.bodyMedium?.copyWith(
              color: _textSoft,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                _t('cancel'),
                style: _text.bodySmall?.copyWith(color: _textSoft),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _t('delete'),
                style: _text.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleSelection(DiaryModel diary) {
    setState(() {
      _selectionMode = true;
      if (_selectedIds.contains(diary.id)) {
        _selectedIds.remove(diary.id);
      } else {
        _selectedIds.add(diary.id);
      }

      if (_selectedIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _selectAll(List<DiaryModel> diaries) {
    setState(() {
      _selectionMode = true;
      _selectedIds
        ..clear()
        ..addAll(diaries.map((e) => e.id));
    });
  }

  void _selectWeek(List<DiaryModel> diaries) {
    setState(() {
      _selectionMode = true;
      _selectedIds.addAll(diaries.map((e) => e.id));
    });
  }

  PreferredSizeWidget _buildAppBar(List<DiaryModel> diaries) {
    if (_selectionMode) {
      return AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            setState(() {
              _selectionMode = false;
              _selectedIds.clear();
            });
          },
          icon: const Icon(
            Icons.close_rounded,
            color: _textDark,
          ),
        ),
        title: Text(
          '${_selectedIds.length} ${_t('selectedCount')}',
          style: _text.headlineLarge?.copyWith(
            color: _textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _selectAll(diaries),
            icon: const Icon(Icons.select_all_rounded, color: _greenDark),
          ),
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          ),
        ],
      );
    }

    return AppBar(
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
        '${_monthNameFromCode(widget.month)} ${widget.year}',
        style: _text.headlineLarge?.copyWith(
          color: _textDark,
        ),
      ),
    );
  }

  Widget _summaryCard(List<DiaryModel> diaries) {
    final latest = diaries.isEmpty ? null : diaries.first;

    int totalPhotos = 0;
    for (final item in diaries) {
      totalPhotos += item.images.length;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_monthNameFromCode(widget.month)} ${widget.year}',
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _miniInfoChip(
                bg: _greenMint,
                fg: _greenDark,
                icon: Icons.menu_book_rounded,
                text: '${diaries.length} ${_t('entriesThisMonth')}',
              ),
              if (totalPhotos > 0)
                _miniInfoChip(
                  bg: _pinkSoft,
                  fg: const Color(0xFFC77B88),
                  icon: Icons.photo_library_outlined,
                  text: '$totalPhotos foto',
                ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 14),
            Text(
              '${_t('latest')}: ${latest.date} ${_monthNameFromCode(latest.month)} • ${latest.time}',
              style: _text.bodyMedium?.copyWith(
                color: _textSoft,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniInfoChip({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            text,
            style: _text.bodySmall?.copyWith(
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekHeader(int weekNumber, List<DiaryModel> diaries) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_t('week')} $weekNumber',
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 22,
            ),
          ),
        ),
        if (_selectionMode)
          TextButton(
            onPressed: () => _selectWeek(diaries),
            child: Text(
              _t('selectWeek'),
              style: _text.bodySmall?.copyWith(
                color: _greenDark,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _greenMint,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '${diaries.length}',
            style: _text.bodySmall?.copyWith(
              color: _greenDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _entryCard(DiaryModel diary) {
    final mood = _moodMeta(diary.mood);
    final selected = _selectedIds.contains(diary.id);
    final imageUrl = diary.primaryImage;

    return GestureDetector(
      onLongPress: () => _toggleSelection(diary),
      onTap: () {
        if (_selectionMode) {
          _toggleSelection(diary);
        } else {
          _openDiaryDetail(diary);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
          border: Border.all(
            color: selected ? _green : _line,
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 176,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: mood.bg,
                        alignment: Alignment.center,
                        child: Image.asset(
                          mood.asset,
                          width: 58,
                          height: 58,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (diary.images.length > 1)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(99),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
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
                      const Spacer(),
                      if (_selectionMode)
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selected ? _greenDark : _textSoft,
                        )
                      else
                        PopupMenuButton<String>(
                          color: _card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editDiary(diary);
                            } else if (value == 'delete') {
                              _deleteOne(diary);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                _t('edit'),
                                style: _text.bodyMedium?.copyWith(
                                  color: _textDark,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                _t('delete'),
                                style: _text.bodyMedium?.copyWith(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                          child: const Icon(
                            Icons.more_vert_rounded,
                            color: _textDark,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    diary.title.trim().isEmpty ? _t('latest') : diary.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _text.headlineLarge?.copyWith(
                      color: _textDark,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    diary.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: _text.bodyMedium?.copyWith(
                      color: _textSoft,
                      fontSize: 15,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _formatEntryLine(diary),
                    style: _text.bodySmall?.copyWith(
                      color: _textSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(99),
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
        borderRadius: BorderRadius.circular(99),
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
              Icons.menu_book_outlined,
              size: 38,
              color: _greenDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _t('emptyTitle'),
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

  void _handleInitialOpen(List<DiaryModel> diaries) {
    if (_handledInitialOpen) return;
    if (widget.openDiaryId == null) return;
    if (diaries.isEmpty) return;

    final target = diaries.cast<DiaryModel?>().firstWhere(
          (e) => e?.id == widget.openDiaryId,
          orElse: () => null,
        );

    _handledInitialOpen = true;

    if (target != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openDiaryDetail(target);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DiaryModel>>(
      stream: FirestoreDiaryService().getPrivateDiaries(widget.month, widget.year),
      builder: (context, snapshot) {
        final diaries = snapshot.data ?? [];
        diaries.sort((a, b) => b.entryDateTime.compareTo(a.entryDateTime));
        final grouped = _groupByWeek(diaries);

        _handleInitialOpen(diaries);

        return Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(diaries),
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
                bottom: 150,
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
                    if (diaries.isEmpty) ...[
                      _emptyState(),
                    ] else ...[
                      _summaryCard(diaries),
                      const SizedBox(height: 20),
                      for (final entry in grouped.entries) ...[
                        _weekHeader(entry.key, entry.value),
                        const SizedBox(height: 12),
                        for (final diary in entry.value) ...[
                          _entryCard(diary),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 8,
            onPressed: () async {
              final now = DateTime.now();
              final targetMonth = _monthNumber(widget.month);

              final initialDate =
                  (widget.year == now.year && targetMonth == now.month)
                      ? now
                      : DateTime(widget.year, targetMonth, 1);

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddDiaryPage(
                    initialDate: initialDate,
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

class _DiaryDetailPage extends StatefulWidget {
  final DiaryModel diary;
  final String languageCode;
  final String Function(String) monthNameBuilder;
  final String Function(int) weekdayBuilder;
  final ({String label, Color bg, Color fg, String asset}) Function(String)
      moodMetaBuilder;
  final Future<bool> Function() onEdit;
  final Future<bool> Function() onDelete;

  const _DiaryDetailPage({
    required this.diary,
    required this.languageCode,
    required this.monthNameBuilder,
    required this.weekdayBuilder,
    required this.moodMetaBuilder,
    required this.onEdit,
    required this.onDelete,
  });

  @override
    State<_DiaryDetailPage> createState() => _DiaryDetailPageState();
  }

  class _DiaryDetailPageState extends State<_DiaryDetailPage> {
    static const Color _bg = Color(0xFFF4F8EA);
    static const Color _card = Colors.white;
    static const Color _greenDark = Color(0xFF5F9E4E);
    static const Color _greenMint = Color(0xFFEFF7E6);
    static const Color _pinkSoft = Color(0xFFFFEEF2);
    static const Color _textDark = Color(0xFF1F1F1F);
    static const Color _textSoft = Color(0xFF6D7568);

    late final PageController _pageController;
    int _pageIndex = 0;

    static const Map<String, Map<String, String>> _copy = {
      'id': {
        'detailTitle': 'Lihat Diary',
        'writtenAt': 'Ditulis',
        'entryDate': 'Tanggal entry',
        'updatedAt': 'Diperbarui',
        'private': 'Privat',
        'public': 'Publik',
        'morePhotos': 'foto lain',
        'edit': 'Edit',
        'delete': 'Hapus',
        'photo': 'Foto',
        'of': 'dari',
      },
      'en': {
        'detailTitle': 'Diary Detail',
        'writtenAt': 'Written at',
        'entryDate': 'Entry date',
        'updatedAt': 'Updated',
        'private': 'Private',
        'public': 'Public',
        'morePhotos': 'more photos',
        'edit': 'Edit',
        'delete': 'Delete',
        'photo': 'Photo',
        'of': 'of',
      },
    };

    String _t(String key) => _copy[widget.languageCode]?[key] ?? key;
    TextTheme _text(BuildContext context) => Theme.of(context).textTheme;

    List<BoxShadow> get _softShadow => const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ];

    List<String> get _images {
      final raw = <String>[
        ...widget.diary.images,
        if (widget.diary.images.isEmpty && widget.diary.primaryImage.isNotEmpty)
          widget.diary.primaryImage,
      ];

      return raw
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
    }

    @override
    void initState() {
      super.initState();
      _pageController = PageController();
    }

    @override
    void dispose() {
      _pageController.dispose();
      super.dispose();
    }

    String _formattedDateTime() {
      final dt = widget.diary.entryDateTime;
      return '${widget.weekdayBuilder(dt.weekday)}, ${dt.day} ${widget.monthNameBuilder(widget.diary.month)} ${dt.year} • ${widget.diary.time}';
    }

    Widget _chipWithAsset(
      BuildContext context, {
      required Color bg,
      required Color fg,
      required String asset,
      required String label,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
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
              style: _text(context).bodySmall?.copyWith(color: fg),
            ),
          ],
        ),
      );
    }

    Widget _plainChip(
      BuildContext context, {
      required Color bg,
      required Color fg,
      required IconData icon,
      required String label,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: _text(context).bodySmall?.copyWith(color: fg),
            ),
          ],
        ),
      );
    }

    void _openImageViewer(int initialIndex) {
      if (_images.isEmpty) return;

      showDialog(
        context: context,
        builder: (_) {
          final viewerController = PageController(initialPage: initialIndex);
          int currentIndex = initialIndex;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return Dialog(
                insetPadding: const EdgeInsets.all(18),
                backgroundColor: Colors.black,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: viewerController,
                      itemCount: _images.length,
                      onPageChanged: (value) {
                        setModalState(() {
                          currentIndex = value;
                        });
                      },
                      itemBuilder: (_, index) {
                        return InteractiveViewer(
                          minScale: 0.9,
                          maxScale: 4,
                          child: Image.network(
                            _images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              height: 280,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_images.length > 1)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.52),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '${_t('photo')} ${currentIndex + 1} ${_t('of')} ${_images.length}',
                                style: _text(context).bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_images.length, (index) {
                                final active = index == currentIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: active ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    String _monthCodeFromNumber(int month) {
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
      return map[month] ?? 'JAN';
    }

    String _two(int value) => value.toString().padLeft(2, '0');

    @override
    Widget build(BuildContext context) {
      final mood = widget.moodMetaBuilder(widget.diary.mood);

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
            _t('detailTitle'),
            style: _text(context).headlineLarge?.copyWith(
                  color: _textDark,
                ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final edited = await widget.onEdit();
                if (!mounted) return;
                if (edited) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.edit_outlined, color: _greenDark),
            ),
            IconButton(
              onPressed: () async {
                final deleted = await widget.onDelete();
                if (!mounted) return;
                if (deleted) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
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
              left: -78,
              bottom: 120,
              child: Container(
                width: 198,
                height: 198,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _greenMint.withOpacity(0.82),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                children: [
                  if (_images.isNotEmpty)
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: _softShadow,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 240,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _images.length,
                              onPageChanged: (value) {
                                setState(() {
                                  _pageIndex = value;
                                });
                              },
                              itemBuilder: (_, index) {
                                return GestureDetector(
                                  onTap: () => _openImageViewer(index),
                                  child: SizedBox.expand(
                                    child: Image.network(
                                      _images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: mood.bg,
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          mood.asset,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_images.length > 1)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _greenMint,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '${_t('photo')} ${_pageIndex + 1} ${_t('of')} ${_images.length}',
                                      style: _text(context).bodySmall?.copyWith(
                                            color: _greenDark,
                                          ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children:
                                        List.generate(_images.length, (index) {
                                      final active = index == _pageIndex;
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        margin: const EdgeInsets.only(left: 6),
                                        width: active ? 20 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: active
                                              ? _greenDark
                                              : _greenDark.withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (_images.isNotEmpty) const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _plainChip(
                              context,
                              bg: _greenMint,
                              fg: _greenDark,
                              icon: Icons.calendar_today_rounded,
                              label:
                                  '${_t('entryDate')}: ${widget.diary.date} ${widget.monthNameBuilder(widget.diary.month)} ${widget.diary.year}',
                            ),
                            _plainChip(
                              context,
                              bg: _greenMint,
                              fg: _greenDark,
                              icon: Icons.schedule_rounded,
                              label: '${_t('writtenAt')}: ${widget.diary.time}',
                            ),
                            _plainChip(
                              context,
                              bg: widget.diary.isPublic ? _greenMint : _pinkSoft,
                              fg: widget.diary.isPublic
                                  ? _greenDark
                                  : const Color(0xFFC77B88),
                              icon: widget.diary.isPublic
                                  ? Icons.public_rounded
                                  : Icons.lock_rounded,
                              label: widget.diary.isPublic
                                  ? _t('public')
                                  : _t('private'),
                            ),
                            _chipWithAsset(
                              context,
                              bg: mood.bg,
                              fg: mood.fg,
                              asset: mood.asset,
                              label: mood.label,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          widget.diary.title.trim().isEmpty
                              ? _t('detailTitle')
                              : widget.diary.title,
                          style: _text(context).headlineLarge?.copyWith(
                                color: _textDark,
                                fontSize: 30,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formattedDateTime(),
                          style: _text(context).bodySmall?.copyWith(
                                color: _textSoft,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFE8EDE0),
                            ),
                          ),
                          child: Text(
                            widget.diary.content,
                            style: _text(context).bodyMedium?.copyWith(
                                  color: _textDark,
                                  fontSize: 16,
                                  height: 1.9,
                                ),
                          ),
                        ),
                        if (widget.diary.updatedAt != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            '${_t('updatedAt')}: ${widget.diary.updatedAt!.day} ${widget.monthNameBuilder(_monthCodeFromNumber(widget.diary.updatedAt!.month))} ${widget.diary.updatedAt!.year} • ${_two(widget.diary.updatedAt!.hour)}:${_two(widget.diary.updatedAt!.minute)}',
                            style: _text(context).bodySmall?.copyWith(
                                  color: _textSoft,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }