import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/services/streak_service.dart';
import '../../services/report_diary_service.dart';
import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';
import '../../widgets/moodly_bottom_navbar.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';
import '../private_diary/add_diary_page.dart';
import '../setting/moodly_settings_support.dart';
import 'comment_page.dart';
import '../../widgets/shared/moodly_reward_frame_avatar.dart';

class PublicDiaryPage extends StatefulWidget {
  const PublicDiaryPage({super.key});

  @override
  State<PublicDiaryPage> createState() => _PublicDiaryPageState();
}

enum _PublicDiarySort {
  newest,
  oldest,
  mostLiked,
  mostCommented,
}

class _PublicDiaryPageState extends State<PublicDiaryPage> {
  static const Color _bg = Color(0xFFF4F8EA);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF5F9E4E);
  static const Color _greenMint = Color(0xFFEFF7E6);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _yellowSoft = Color(0xFFF8F0D0);
  static const Color _blueSoft = Color(0xFFE2F1EE);
  static const Color _redSoft = Color(0xFFFBE3E7);
  static const Color _line = Color(0xFFE4E9D9);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6D7568);

  final TextEditingController _searchController = TextEditingController();

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  String _query = '';
  int _currentNavIndex = 1;
  _PublicDiarySort _sortMode = _PublicDiarySort.newest;
  Timer? _debounce;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'pageTitle': 'Diary Publik',
      'heroTitle': 'Cerita yang dibagikan',
      'heroDesc':
          'Baca cerita orang lain, beri dukungan seperlunya, dan jaga ruang ini tetap hangat.',
      'searchHint': 'Cari judul, isi, penulis, mood, atau tanggal...',
      'emptyTitle': 'Belum ada diary publik',
      'emptyDesc':
          'Ruang ini masih sepi. Kadang cerita butuh waktu sebelum berani muncul.',
      'emptySearchTitle': 'Belum ketemu hasil yang cocok',
      'emptySearchDesc':
          'Coba kata lain yang lebih dekat dengan cerita yang kamu cari.',
      'public': 'Publik',
      'photos': 'foto',
      'openDiary': 'Buka diary',
      'sortNewest': 'Terbaru',
      'sortOldest': 'Terlama',
      'sortLiked': 'Disukai',
      'sortCommented': 'Ramai',
      'edit': 'Edit',
      'delete': 'Hapus',
      'deleteTitle': 'Hapus diary publik?',
      'deleteDesc':
          'Diary ini akan hilang dari ruang publik juga. Sekali hapus ya sudah hilang.',
      'deleteSuccessTitle': 'Diary dihapus',
      'deleteSuccessDesc': 'Diary berhasil dihapus.',
      'deleteFailedTitle': 'Gagal menghapus',
      'deleteFailedDesc': 'Coba lagi sebentar ya.',
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
      'moodHappy': 'Senang',
      'moodNeutral': 'Netral',
      'moodSad': 'Sedih',
      'moodAngry': 'Marah',
      'moodUnknown': 'Tanpa mood',
      'results': 'hasil',
      'cancel': 'Batal',
      'confirmDelete': 'Ya, hapus',
      'like': 'Suka',
      'comments': 'Komentar',
      'report': 'Laporkan',
      'reportDiaryTitle': 'Laporkan diary',
      'reportReasonHint': 'Tulis alasan laporan...',
      'pickCategory': 'Pilih kategori',
      'reportSentTitle': 'Laporan terkirim',
      'reportSentDesc': 'Laporanmu berhasil dikirim ke admin.',
      'reportEmptyTitle': 'Masih kurang lengkap',
      'reportEmptyDesc': 'Pilih kategori dan isi alasan laporan dulu ya.',
    },
    'en': {
      'pageTitle': 'Public Diary',
      'heroTitle': 'Shared stories',
      'heroDesc':
          'Read other people’s stories, offer gentle support, and help keep this space warm.',
      'searchHint': 'Search title, content, writer, mood, or date...',
      'emptyTitle': 'No public diary yet',
      'emptyDesc':
          'This space is still quiet. Some stories need time before they show up.',
      'emptySearchTitle': 'No matching result yet',
      'emptySearchDesc':
          'Try another word that feels closer to the story you are looking for.',
      'public': 'Public',
      'photos': 'photos',
      'openDiary': 'Open diary',
      'sortNewest': 'Newest',
      'sortOldest': 'Oldest',
      'sortLiked': 'Liked',
      'sortCommented': 'Active',
      'edit': 'Edit',
      'delete': 'Delete',
      'deleteTitle': 'Delete public diary?',
      'deleteDesc':
          'This diary will disappear from the public space too. Delete it and it is gone.',
      'deleteSuccessTitle': 'Diary deleted',
      'deleteSuccessDesc': 'Diary deleted successfully.',
      'deleteFailedTitle': 'Failed to delete',
      'deleteFailedDesc': 'Please try again in a moment.',
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
      'moodHappy': 'Happy',
      'moodNeutral': 'Neutral',
      'moodSad': 'Sad',
      'moodAngry': 'Angry',
      'moodUnknown': 'No mood',
      'results': 'results',
      'cancel': 'Cancel',
      'confirmDelete': 'Yes, delete',
      'like': 'Likes',
      'comments': 'Comments',
      'report': 'Report',
      'reportDiaryTitle': 'Report diary',
      'reportReasonHint': 'Write your reason...',
      'pickCategory': 'Pick a category',
      'reportSentTitle': 'Report sent',
      'reportSentDesc': 'Your report has been sent to admin.',
      'reportEmptyTitle': 'Still incomplete',
      'reportEmptyDesc': 'Choose a category and fill in the report reason first.',
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
  
  static const List<String> _reportCategoriesId = [
    'Spam',
    'Kata Kasar',
    'Konten Tidak Pantas',
    'Bullying',
  ];

  static const List<String> _reportCategoriesEn = [
    'Spam',
    'Harsh Language',
    'Inappropriate Content',
    'Bullying',
  ];

  List<String> get _reportCategories =>
      _languageCode == 'en' ? _reportCategoriesEn : _reportCategoriesId;

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
    super.dispose();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
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

  String _monthName(String code) {
    switch (code.toUpperCase()) {
      case 'JAN':
        return _t('jan');
      case 'FEB':
        return _t('feb');
      case 'MAR':
        return _t('mar');
      case 'APR':
        return _t('apr');
      case 'MEI':
        return _t('may');
      case 'JUN':
        return _t('jun');
      case 'JUL':
        return _t('jul');
      case 'AGS':
        return _t('aug');
      case 'SEP':
        return _t('sep');
      case 'OKT':
        return _t('oct');
      case 'NOV':
        return _t('nov');
      case 'DES':
        return _t('dec');
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

  DateTime _entryDateTime(DiaryModel diary) {
    final parts = diary.time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(
      diary.year,
      _monthNumber(diary.month),
      diary.date,
      hour,
      minute,
    );
  }

  String _normalizedMood(String mood) {
    final raw = mood.trim().toLowerCase();
    if (raw == 'happy' || raw == 'senang') return 'happy';
    if (raw == 'sad' || raw == 'sedih') return 'sad';
    if (raw == 'angry' || raw == 'marah') return 'angry';
    if (raw == 'neutral' || raw == 'netral') return 'neutral';
    return 'unknown';
  }

  ({String label, Color bg, Color fg, String asset}) _moodVisual(String mood) {
    switch (_normalizedMood(mood)) {
      case 'happy':
        return (
          label: _t('moodHappy'),
          bg: const Color(0xFFE5F6DA),
          fg: const Color(0xFF63A94E),
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
      case 'neutral':
        return (
          label: _t('moodNeutral'),
          bg: _yellowSoft,
          fg: const Color(0xFFB99737),
          asset: 'assets/emoji/emoji_netral.png',
        );
      default:
        return (
          label: _t('moodUnknown'),
          bg: const Color(0xFFF2F3EE),
          fg: _textSoft,
          asset: 'assets/emoji/emoji_netral.png',
        );
    }
  }

  String _primaryImage(DiaryModel diary) {
    if (diary.images.isNotEmpty && diary.images.first.trim().isNotEmpty) {
      return diary.images.first.trim();
    }
    return diary.imageUrl.trim();
  }

  List<DiaryModel> _applySearchAndSort(
    List<DiaryModel> all,
    String rawQuery,
  ) {
    final query = rawQuery.trim().toLowerCase();

    var visible = all.where((diary) {
      if (query.isEmpty) return true;

      final title = diary.title.toLowerCase();
      final content = diary.content.toLowerCase();
      final username = diary.username.toLowerCase();
      final moodRaw = diary.mood.toLowerCase();
      final moodLabel = _moodVisual(diary.mood).label.toLowerCase();
      final dateText =
          '${diary.date} ${_monthName(diary.month).toLowerCase()} ${diary.year}';

      return title.contains(query) ||
          content.contains(query) ||
          username.contains(query) ||
          moodRaw.contains(query) ||
          moodLabel.contains(query) ||
          dateText.contains(query);
    }).toList();

    switch (_sortMode) {
      case _PublicDiarySort.newest:
        visible.sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));
        break;
      case _PublicDiarySort.oldest:
        visible.sort((a, b) => _entryDateTime(a).compareTo(_entryDateTime(b)));
        break;
      case _PublicDiarySort.mostLiked:
        visible.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case _PublicDiarySort.mostCommented:
        visible.sort((a, b) => b.comments.compareTo(a.comments));
        break;
    }

    return visible;
  }

  Widget _sortChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _greenMint : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? _greenDark : _line,
          ),
        ),
        child: Text(
          label,
          style: _text.bodySmall?.copyWith(
            color: active ? _greenDark : _textSoft,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLike(DiaryModel diary) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final isOwnDiary = diary.uid.isNotEmpty && diary.uid == currentUser.uid;
    final wasLiked = diary.likedBy.contains(currentUser.uid);

    await FirestoreDiaryService().toggleDiaryLike(
      diaryId: diary.id,
      isPublicDiary: true,
    );

    if (!isOwnDiary && !wasLiked) {
      await StreakService.instance.registerPublicDiaryReaction();
    }
  }

  Future<void> _editDiary(DiaryModel diary) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDiaryPage(
          diaryId: diary.id,
          initialDate: _entryDateTime(diary),
          initialTitle: diary.title,
          initialContent: diary.content,
          initialImageUrls: diary.images,
          initialIsPublic: diary.isPublic,
          initialMood: diary.mood,
          initialTime: diary.time,
        ),
      ),
    );
  }

  Future<void> _showReportSheet({
    required String title,
    required Future<void> Function(String category, String reason) onSubmit,
  }) async {
    String selectedCategory = '';
    final reasonController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: const BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _line,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: _text.headlineLarge?.copyWith(
                          color: _textDark,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _t('pickCategory'),
                        style: _text.titleMedium?.copyWith(color: _textDark),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _reportCategories.map((category) {
                        final selected = selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) {
                            setModalState(() {
                              selectedCategory = category;
                            });
                          },
                          selectedColor: _greenSoft,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected ? _greenDark : _line,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _t('reportReasonHint'),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final reason = reasonController.text.trim();
                          if (selectedCategory.isEmpty || reason.isEmpty) {
                            showCuteTopPopup(
                              context,
                              title: _t('reportEmptyTitle'),
                              message: _t('reportEmptyDesc'),
                              type: CutePopupType.info,
                            );
                            return;
                          }

                          await onSubmit(selectedCategory, reason);

                          if (!mounted) return;
                          Navigator.pop(sheetContext);
                          showCuteTopPopup(
                            context,
                            title: _t('reportSentTitle'),
                            message: _t('reportSentDesc'),
                            type: CutePopupType.success,
                          );
                        },
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
                          _t('report'),
                          style: _text.labelLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _reportDiary(DiaryModel diary) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    if (diary.uid == currentUser.uid) return;

    await _showReportSheet(
      title: _t('reportDiaryTitle'),
      onSubmit: (category, reason) async {
        await ReportDiaryService.createReport(
          type: 'diary',
          reportedUser: diary.username,
          reportedProfile: diary.profileImage,
          reportedUid: diary.uid,
          reportedByUid: currentUser.uid,
          reportedByUsername:
              currentUser.displayName?.trim().isNotEmpty == true
                  ? currentUser.displayName!.trim()
                  : 'User',
          reportCategory: category,
          reportReason: reason,
          contentText: diary.content,
          diaryId: diary.id,
        );
      },
    );
  }

  Future<void> _deleteDiary(DiaryModel diary) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          _t('deleteTitle'),
          style: _text.titleMedium?.copyWith(
            color: _textDark,
            fontSize: 20,
          ),
        ),
        content: Text(
          _t('deleteDesc'),
          style: _text.bodyMedium?.copyWith(
            color: _textSoft,
            height: 1.5,
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
              backgroundColor: const Color(0xFFE66975),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _t('confirmDelete'),
              style: _text.labelLarge,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirestoreDiaryService().deleteDiary(diary.id);
      if (!mounted) return;
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
        title: _t('deleteFailedTitle'),
        message: _t('deleteFailedDesc'),
        type: CutePopupType.error,
      );
    }
  }

  Widget _chip({
    required String label,
    required Color bg,
    required Color fg,
    IconData? icon,
    String? asset,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (asset != null)
            Image.asset(
              asset,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.circle,
                size: 12,
                color: fg,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: _text.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required String title,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
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
              Icons.auto_stories_rounded,
              size: 36,
              color: _greenDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _text.headlineLarge?.copyWith(color: _textDark),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: _text.bodyMedium?.copyWith(
              color: _textSoft,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _diaryCard(DiaryModel diary) {
    final mood = _moodVisual(diary.mood);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isMine = currentUid != null && currentUid == diary.uid;
    final likedByMe = diary.likedBy.contains(currentUid);
    final primaryImage = _primaryImage(diary);
    final hasImage = primaryImage.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CommentPage(diary: diary)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
          border: Border.all(color: _line, width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 210,
                      child: Image.network(
                        primaryImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: mood.bg,
                          alignment: Alignment.center,
                          child: Image.asset(
                            mood.asset,
                            width: 54,
                            height: 54,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    if (diary.images.length > 1)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.46),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '+${diary.images.length - 1} ${_t('photos')}',
                            style: _text.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MoodlyInventoryFrameAvatar(
                        uid: diary.uid,
                        size: 44,
                        innerPadding: 2.5,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: _greenSoft,
                          backgroundImage: diary.profileImage.isNotEmpty
                              ? NetworkImage(diary.profileImage)
                              : null,
                          child: diary.profileImage.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: _greenDark,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diary.username,
                              style: _text.titleMedium?.copyWith(
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${diary.date} ${_monthName(diary.month)} ${diary.year} • ${diary.time}',
                              style: _text.bodyMedium?.copyWith(
                                color: _textSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'report') {
                              await _reportDiary(diary);
                            } else if (value == 'edit') {
                              await _editDiary(diary);
                            } else if (value == 'delete') {
                              await _deleteDiary(diary);
                            }
                          },
                          itemBuilder: (_) {
                            final items = <PopupMenuEntry<String>>[];

                            if (isMine) {
                              items.addAll([
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(_t('edit')),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(_t('delete')),
                                ),
                              ]);
                            } else {
                              items.add(
                                PopupMenuItem(
                                  value: 'report',
                                  child: Text(_t('report')),
                                ),
                              );
                            }

                            return items;
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        label: mood.label,
                        bg: mood.bg,
                        fg: mood.fg,
                        asset: mood.asset,
                      ),
                      _chip(
                        label: _t('public'),
                        bg: _greenMint,
                        fg: _greenDark,
                        icon: Icons.public_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    diary.title.trim().isEmpty ? '-' : diary.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _text.headlineLarge?.copyWith(
                      color: _textDark,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diary.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _text.bodyMedium?.copyWith(
                      color: _textSoft,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleLike(diary),
                        child: Row(
                          children: [
                            Icon(
                              likedByMe
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                              color: likedByMe
                                  ? const Color(0xFFE66975)
                                  : _textSoft,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${diary.likes}',
                              style: _text.bodySmall?.copyWith(
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Row(
                        children: [
                          const Icon(
                            Icons.mode_comment_outlined,
                            size: 20,
                            color: _textSoft,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${diary.comments}',
                            style: _text.bodySmall?.copyWith(
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            _t('openDiary'),
                            style: _text.bodySmall?.copyWith(
                              color: _greenDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: _greenDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t('heroDesc'),
                  style: _text.bodyMedium?.copyWith(
                    color: _textSoft,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: _greenMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: _greenDark,
              size: 36,
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
      bottomNavigationBar: MoodlyBottomNavbar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        onEmergencyTap: _onEmergencyTap,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -24,
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
            bottom: 150,
            left: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.82),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<List<DiaryModel>>(
              stream: FirestoreDiaryService().getPublicDiaries(),
              builder: (context, snapshot) {
                final all = snapshot.data ?? [];
                final visible = _applySearchAndSort(all, _query);
                final hasQuery = _query.isNotEmpty;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: _textDark,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _t('pageTitle'),
                                    style: _text.headlineLarge?.copyWith(
                                      color: _textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _hero(),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: _softShadow,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _pinkSoft,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: _onQueryChanged,
                                      style: _text.bodyMedium?.copyWith(
                                        color: _textDark,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: _t('searchHint'),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          color: _greenDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _sortChip(
                                          label: _t('sortNewest'),
                                          active: _sortMode ==
                                              _PublicDiarySort.newest,
                                          onTap: () => setState(
                                            () => _sortMode =
                                                _PublicDiarySort.newest,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _sortChip(
                                          label: _t('sortOldest'),
                                          active: _sortMode ==
                                              _PublicDiarySort.oldest,
                                          onTap: () => setState(
                                            () => _sortMode =
                                                _PublicDiarySort.oldest,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _sortChip(
                                          label: _t('sortLiked'),
                                          active: _sortMode ==
                                              _PublicDiarySort.mostLiked,
                                          onTap: () => setState(
                                            () => _sortMode =
                                                _PublicDiarySort.mostLiked,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _sortChip(
                                          label: _t('sortCommented'),
                                          active: _sortMode ==
                                              _PublicDiarySort.mostCommented,
                                          onTap: () => setState(
                                            () => _sortMode =
                                                _PublicDiarySort.mostCommented,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const Padding(
                                padding: EdgeInsets.all(36),
                                child: CircularProgressIndicator(),
                              )
                            else if (all.isEmpty)
                              _emptyState(
                                title: _t('emptyTitle'),
                                desc: _t('emptyDesc'),
                              )
                            else if (visible.isEmpty)
                              _emptyState(
                                title: _t('emptySearchTitle'),
                                desc: _t('emptySearchDesc'),
                              )
                            else
                              Column(
                                children: [
                                  if (hasQuery)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          '${visible.length} ${_t('results')}',
                                          style: _text.bodySmall?.copyWith(
                                            color: _textSoft,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ...visible.map(_diaryCard),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}