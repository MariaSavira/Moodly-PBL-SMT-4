import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/streak_service.dart';
import '../../models/diary_model.dart';
import '../../services/comment_service.dart';
import '../../services/firestore_diary_service.dart';
import '../../services/report_comment_service.dart';
import '../../services/report_diary_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../private_diary/add_diary_page.dart';
import '../setting/moodly_settings_support.dart';
import '../../widgets/shared/moodly_reward_frame_avatar.dart';

class CommentPage extends StatefulWidget {
  final DiaryModel diary;

  const CommentPage({
    super.key,
    required this.diary,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
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

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  late final PageController _imagePageController;

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  int _imageIndex = 0;
  bool _isSending = false;

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

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'pageTitle': 'Diary Publik',
      'commentHint': 'Tulis komentar yang hangat...',
      'send': 'Kirim',
      'reply': 'Balas',
      'delete': 'Hapus',
      'edit': 'Edit',
      'report': 'Laporkan',
      'cancel': 'Batal',
      'public': 'Publik',
      'writtenAt': 'Ditulis',
      'entryDate': 'Tanggal entry',
      'updatedAt': 'Diperbarui',
      'noCommentsTitle': 'Belum ada komentar',
      'noCommentsDesc':
          'Kalau kamu mau, kamu bisa jadi orang pertama yang memberi respons.',
      'emptyCommentTitle': 'Komentar masih kosong',
      'emptyCommentDesc': 'Isi komentarnya dulu ya.',
      'commentSentTitle': 'Komentar terkirim',
      'commentSentDesc': 'Komentarmu berhasil ditambahkan.',
      'replySentTitle': 'Balasan terkirim',
      'replySentDesc': 'Balasanmu berhasil ditambahkan.',
      'sendFailedTitle': 'Belum berhasil terkirim',
      'sendFailedDesc': 'Coba lagi sebentar ya.',
      'deleteDiaryTitle': 'Hapus diary publik?',
      'deleteDiaryDesc':
          'Diary ini akan hilang dari ruang publik beserta komentarnya.',
      'deleteCommentTitle': 'Hapus komentar?',
      'deleteCommentDesc': 'Komentar ini akan dihapus permanen.',
      'deleteReplyTitle': 'Hapus balasan?',
      'deleteReplyDesc': 'Balasan ini akan dihapus permanen.',
      'deleteSuccessTitle': 'Berhasil dihapus',
      'deleteSuccessDesc': 'Konten yang dipilih berhasil dihapus.',
      'deleteFailedTitle': 'Gagal menghapus',
      'deleteFailedDesc': 'Coba lagi sebentar ya.',
      'reportDiaryTitle': 'Laporkan diary',
      'reportCommentTitle': 'Laporkan komentar',
      'reportReplyTitle': 'Laporkan balasan',
      'reportReasonHint': 'Tulis alasan laporan...',
      'pickCategory': 'Pilih kategori',
      'reportSentTitle': 'Laporan terkirim',
      'reportSentDesc': 'Laporanmu berhasil dikirim ke admin.',
      'reportEmptyTitle': 'Masih kurang lengkap',
      'reportEmptyDesc': 'Pilih kategori dan isi alasan laporan dulu ya.',
      'like': 'Suka',
      'comments': 'Komentar',
      'photo': 'Foto',
      'of': 'dari',
      'morePhotos': 'foto lain',
      'moodHappy': 'Senang',
      'moodNeutral': 'Netral',
      'moodSad': 'Sedih',
      'moodAngry': 'Marah',
      'moodUnknown': 'Tanpa mood',
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
      'you': 'Kamu',
    },
    'en': {
      'pageTitle': 'Public Diary',
      'commentHint': 'Write a gentle comment...',
      'send': 'Send',
      'reply': 'Reply',
      'delete': 'Delete',
      'edit': 'Edit',
      'report': 'Report',
      'cancel': 'Cancel',
      'public': 'Public',
      'writtenAt': 'Written',
      'entryDate': 'Entry date',
      'updatedAt': 'Updated',
      'noCommentsTitle': 'No comments yet',
      'noCommentsDesc':
          'If you want, you can be the first person to respond.',
      'emptyCommentTitle': 'Comment is still empty',
      'emptyCommentDesc': 'Write the comment first.',
      'commentSentTitle': 'Comment sent',
      'commentSentDesc': 'Your comment has been added.',
      'replySentTitle': 'Reply sent',
      'replySentDesc': 'Your reply has been added.',
      'sendFailedTitle': 'Could not send yet',
      'sendFailedDesc': 'Please try again in a moment.',
      'deleteDiaryTitle': 'Delete public diary?',
      'deleteDiaryDesc':
          'This diary will disappear from the public space along with its comments.',
      'deleteCommentTitle': 'Delete comment?',
      'deleteCommentDesc': 'This comment will be permanently deleted.',
      'deleteReplyTitle': 'Delete reply?',
      'deleteReplyDesc': 'This reply will be permanently deleted.',
      'deleteSuccessTitle': 'Deleted successfully',
      'deleteSuccessDesc': 'The selected content has been deleted.',
      'deleteFailedTitle': 'Failed to delete',
      'deleteFailedDesc': 'Please try again in a moment.',
      'reportDiaryTitle': 'Report diary',
      'reportCommentTitle': 'Report comment',
      'reportReplyTitle': 'Report reply',
      'reportReasonHint': 'Write your reason...',
      'pickCategory': 'Pick a category',
      'reportSentTitle': 'Report sent',
      'reportSentDesc': 'Your report has been sent to admin.',
      'reportEmptyTitle': 'Still incomplete',
      'reportEmptyDesc':
          'Choose a category and fill in the report reason first.',
      'like': 'Likes',
      'comments': 'Comments',
      'photo': 'Photo',
      'of': 'of',
      'morePhotos': 'more photos',
      'moodHappy': 'Happy',
      'moodNeutral': 'Neutral',
      'moodSad': 'Sad',
      'moodAngry': 'Angry',
      'moodUnknown': 'No mood',
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
      'you': 'You',
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

  List<String> get _reportCategories =>
      _languageCode == 'en' ? _reportCategoriesEn : _reportCategoriesId;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await FirestoreDiaryService().ensurePublicMirror(widget.diary);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    _commentController.dispose();
    _commentFocusNode.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
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

  bool _sameIdentity({
    required String uid,
    required String username,
    required String profileImage,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    if (uid.isNotEmpty && uid == currentUser.uid) return true;

    final myName = currentUser.displayName?.trim() ?? '';
    final myPhoto = currentUser.photoURL?.trim() ?? '';
    final otherName = username.trim();
    final otherPhoto = profileImage.trim();

    if (uid.isEmpty && myName.isNotEmpty && myName == otherName) {
      if (myPhoto.isEmpty || otherPhoto.isEmpty || myPhoto == otherPhoto) {
        return true;
      }
    }

    return false;
  }

  bool _isOwnDiary(DiaryModel diary) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    return diary.uid.isNotEmpty && diary.uid == currentUser.uid;
  }

  bool _isOwnComment(Map<String, dynamic> comment) {
    return _sameIdentity(
      uid: (comment['uid'] ?? '').toString(),
      username: (comment['username'] ?? '').toString(),
      profileImage: (comment['profile_image'] ?? '').toString(),
    );
  }

  bool _isOwnReply(Map<String, dynamic> reply) {
    return _sameIdentity(
      uid: (reply['uid'] ?? '').toString(),
      username: (reply['username'] ?? '').toString(),
      profileImage: (reply['profile_image'] ?? '').toString(),
    );
  }

  String? _frameFromMap(Map<String, dynamic> data) {
    final raw = (data['activeFrameId'] ??
            data['active_frame_id'] ??
            data['frameId'] ??
            data['frame_id'])
        ?.toString()
        .trim();

    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  Future<void> _sendComment(DiaryModel diary) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      showCuteTopPopup(
        context,
        title: _t('emptyCommentTitle'),
        message: _t('emptyCommentDesc'),
        type: CutePopupType.info,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      await CommentService.addComment(
        diaryId: diary.id,
        username: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : _t('you'),
        profileImage: user.photoURL ?? '',
        comment: text,
      );

      if (!_isOwnDiary(diary)) {
        await StreakService.instance.registerPublicDiaryComment();
      }

      _commentController.clear();

      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('commentSentTitle'),
        message: _t('commentSentDesc'),
        type: CutePopupType.success,
      );
    } catch (_) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('sendFailedTitle'),
        message: _t('sendFailedDesc'),
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _showReplySheet({
    required DiaryModel diary,
    required String commentId,
    required String username,
  }) async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
                    '${_t('reply')} @$username',
                    style: _text.headlineLarge?.copyWith(
                      color: _textDark,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: _t('commentHint'),
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
                      final text = controller.text.trim();
                      if (text.isEmpty) {
                        showCuteTopPopup(
                          context,
                          title: _t('emptyCommentTitle'),
                          message: _t('emptyCommentDesc'),
                          type: CutePopupType.info,
                        );
                        return;
                      }

                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      try {
                        await CommentService.addReply(
                          diaryId: diary.id,
                          commentId: commentId,
                          username: user.displayName?.trim().isNotEmpty == true
                              ? user.displayName!.trim()
                              : _t('you'),
                          profileImage: user.photoURL ?? '',
                          reply: text,
                        );

                        if (!mounted) return;
                        Navigator.pop(sheetContext);
                        showCuteTopPopup(
                          context,
                          title: _t('replySentTitle'),
                          message: _t('replySentDesc'),
                          type: CutePopupType.success,
                        );
                      } catch (_) {
                        if (!mounted) return;
                        showCuteTopPopup(
                          context,
                          title: _t('sendFailedTitle'),
                          message: _t('sendFailedDesc'),
                          type: CutePopupType.error,
                        );
                      }
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
                      _t('send'),
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
    if (_isOwnDiary(diary)) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

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
                  : _t('you'),
          reportCategory: category,
          reportReason: reason,
          contentText: diary.content,
          diaryId: diary.id,
        );
      },
    );
  }

  Future<void> _reportComment({
    required DiaryModel diary,
    required String commentId,
    required Map<String, dynamic> comment,
  }) async {
    if (_isOwnComment(comment)) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _showReportSheet(
      title: _t('reportCommentTitle'),
      onSubmit: (category, reason) async {
        await ReportCommentService.createReport(
          type: 'comment',
          reportedUser: (comment['username'] ?? '').toString(),
          reportedProfile: (comment['profile_image'] ?? '').toString(),
          reportedUid: (comment['uid'] ?? '').toString(),
          reportedByUid: currentUser.uid,
          reportedByUsername:
              currentUser.displayName?.trim().isNotEmpty == true
                  ? currentUser.displayName!.trim()
                  : _t('you'),
          reportCategory: category,
          reportReason: reason,
          contentText: (comment['comment'] ?? '').toString(),
          diaryId: diary.id,
          commentId: commentId,
        );
      },
    );
  }

  Future<void> _reportReply({
    required DiaryModel diary,
    required String commentId,
    required Map<String, dynamic> reply,
  }) async {
    if (_isOwnReply(reply)) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _showReportSheet(
      title: _t('reportReplyTitle'),
      onSubmit: (category, reason) async {
        await ReportCommentService.createReport(
          type: 'reply',
          reportedUser: (reply['username'] ?? '').toString(),
          reportedProfile: (reply['profile_image'] ?? '').toString(),
          reportedUid: (reply['uid'] ?? '').toString(),
          reportedByUid: currentUser.uid,
          reportedByUsername:
              currentUser.displayName?.trim().isNotEmpty == true
                  ? currentUser.displayName!.trim()
                  : _t('you'),
          reportCategory: category,
          reportReason: reason,
          contentText: (reply['reply'] ?? '').toString(),
          diaryId: diary.id,
          commentId: commentId,
          replyId: ((reply['created_at'] ?? '').toString()),
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
          _t('deleteDiaryTitle'),
          style: _text.titleMedium?.copyWith(
            color: _textDark,
            fontSize: 20,
          ),
        ),
        content: Text(
          _t('deleteDiaryDesc'),
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
              _t('delete'),
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

      Navigator.pop(context, true);
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

  Future<void> _deleteComment({
    required DiaryModel diary,
    required String commentId,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          _t('deleteCommentTitle'),
          style: _text.titleMedium?.copyWith(
            color: _textDark,
            fontSize: 20,
          ),
        ),
        content: Text(
          _t('deleteCommentDesc'),
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
              _t('delete'),
              style: _text.labelLarge,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CommentService.deleteComment(
        diaryId: diary.id,
        commentId: commentId,
      );
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

  Future<void> _deleteReply({
    required DiaryModel diary,
    required String commentId,
    required Map<String, dynamic> replyData,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          _t('deleteReplyTitle'),
          style: _text.titleMedium?.copyWith(
            color: _textDark,
            fontSize: 20,
          ),
        ),
        content: Text(
          _t('deleteReplyDesc'),
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
              _t('delete'),
              style: _text.labelLarge,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CommentService.deleteReply(
        diaryId: diary.id,
        commentId: commentId,
        replyData: replyData,
      );
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

  Future<void> _toggleDiaryLike(DiaryModel diary) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final isOwnDiary = _isOwnDiary(diary);
    final wasLiked = diary.likedBy.contains(currentUser.uid);

    await FirestoreDiaryService().toggleDiaryLike(
      diaryId: diary.id,
      isPublicDiary: true,
    );

    if (!isOwnDiary && !wasLiked) {
      await StreakService.instance.registerPublicDiaryReaction();
    }
  }

  Future<void> _toggleCommentLike({
    required DiaryModel diary,
    required String commentId,
    required Map<String, dynamic> comment,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final likedBy = List<String>.from(comment['likedBy'] ?? const []);
    final isLiked = likedBy.contains(uid);

    await CommentService.likeComment(
      diaryId: diary.id,
      commentId: commentId,
      isLiked: isLiked,
      userId: uid,
    );
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

  void _openImageViewer(List<String> images, int initialIndex) {
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
                    itemCount: images.length,
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
                          images[index],
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
                  if (images.length > 1)
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
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_t('photo')} ${currentIndex + 1} ${_t('of')} ${images.length}',
                              style: _text.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
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
                                  borderRadius: BorderRadius.circular(999),
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

  Widget _diaryHeaderCard(DiaryModel diary) {
    final mood = _moodVisual(diary.mood);
    final user = FirebaseAuth.instance.currentUser;
    final isMine = _isOwnDiary(diary);
    final likedByMe = user != null && diary.likedBy.contains(user.uid);
    final images = diary.images
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
        border: Border.all(color: _line, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: PageView.builder(
                      controller: _imagePageController,
                      itemCount: images.length,
                      onPageChanged: (value) {
                        setState(() {
                          _imageIndex = value;
                        });
                      },
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () => _openImageViewer(images, index),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: mood.bg,
                              alignment: Alignment.center,
                              child: Image.asset(
                                mood.asset,
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (images.length > 1)
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
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_t('photo')} ${_imageIndex + 1} ${_t('of')} ${images.length}',
                              style: _text.bodySmall?.copyWith(
                                color: _greenDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(images.length, (index) {
                              final active = index == _imageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(left: 6),
                                width: active ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? _greenDark
                                      : _greenDark.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(999),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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
                            '${_weekdayShort(_entryDateTime(diary).weekday)}, ${diary.date} ${_monthName(diary.month)} ${diary.year} • ${diary.time}',
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

                        if (!isMine) {
                          items.add(
                            PopupMenuItem(
                              value: 'report',
                              child: Text(_t('report')),
                            ),
                          );
                        }

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
                const SizedBox(height: 14),
                Text(
                  diary.title.trim().isEmpty ? '-' : diary.title,
                  style: _text.headlineLarge?.copyWith(
                    color: _textDark,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  diary.content,
                  style: _text.bodyMedium?.copyWith(
                    color: _textSoft,
                    fontSize: 15,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleDiaryLike(diary),
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentCard({
    required DiaryModel diary,
    required String commentId,
    required Map<String, dynamic> comment,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    final isMine = _isOwnComment(comment);
    final diaryOwner = _isOwnDiary(diary);
    final canDelete = isMine || diaryOwner;

    final likedBy = List<String>.from(comment['likedBy'] ?? const []);
    final isLiked = user != null && likedBy.contains(user.uid);
    final replies = List<Map<String, dynamic>>.from(
      (comment['replies'] as List? ?? []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
        border: Border.all(color: _line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MoodlyInventoryFrameAvatar(
                uid: (comment['uid'] ?? '').toString(),
                explicitFrameId: _frameFromMap(comment),
                size: 40,
                innerPadding: 2.5,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: _greenSoft,
                  backgroundImage: (comment['profile_image'] ?? '')
                          .toString()
                          .trim()
                          .isNotEmpty
                      ? NetworkImage((comment['profile_image'] ?? '').toString())
                      : null,
                  child: (comment['profile_image'] ?? '')
                          .toString()
                          .trim()
                          .isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: _greenDark,
                          size: 20,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (comment['username'] ?? '').toString(),
                  style: _text.titleMedium?.copyWith(color: _textDark),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'report') {
                    await _reportComment(
                      diary: diary,
                      commentId: commentId,
                      comment: comment,
                    );
                  } else if (value == 'delete') {
                    await _deleteComment(
                      diary: diary,
                      commentId: commentId,
                    );
                  }
                },
                itemBuilder: (_) {
                  final items = <PopupMenuEntry<String>>[];

                  if (!isMine) {
                    items.add(
                      PopupMenuItem(
                        value: 'report',
                        child: Text(_t('report')),
                      ),
                    );
                  }

                  if (canDelete) {
                    items.add(
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(_t('delete')),
                      ),
                    );
                  }

                  return items;
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            (comment['comment'] ?? '').toString(),
            style: _text.bodyMedium?.copyWith(
              color: _textDark,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleCommentLike(
                  diary: diary,
                  commentId: commentId,
                  comment: comment,
                ),
                child: Row(
                  children: [
                    Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: isLiked
                          ? const Color(0xFFE66975)
                          : _textSoft,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${comment['likes'] ?? 0}',
                      style: _text.bodySmall?.copyWith(color: _textDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showReplySheet(
                  diary: diary,
                  commentId: commentId,
                  username: (comment['username'] ?? '').toString(),
                ),
                child: Text(
                  _t('reply'),
                  style: _text.bodySmall?.copyWith(
                    color: _greenDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (replies.isNotEmpty) ...[
            const SizedBox(height: 14),
            Column(
              children: replies.map((reply) {
                final replyIsMine = _isOwnReply(reply);
                final replyCanDelete = replyIsMine || _isOwnDiary(diary);

                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _greenMint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          MoodlyInventoryFrameAvatar(
                            uid: (reply['uid'] ?? '').toString(),
                            explicitFrameId: _frameFromMap(reply),
                            size: 34,
                            innerPadding: 2.2,
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: _greenSoft,
                              backgroundImage: (reply['profile_image'] ?? '')
                                      .toString()
                                      .trim()
                                      .isNotEmpty
                                  ? NetworkImage((reply['profile_image'] ?? '').toString())
                                  : null,
                              child: (reply['profile_image'] ?? '')
                                      .toString()
                                      .trim()
                                      .isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: _greenDark,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              (reply['username'] ?? '').toString(),
                              style: _text.bodySmall?.copyWith(
                                color: _textDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'report') {
                                await _reportReply(
                                  diary: diary,
                                  commentId: commentId,
                                  reply: reply,
                                );
                              } else if (value == 'delete') {
                                await _deleteReply(
                                  diary: diary,
                                  commentId: commentId,
                                  replyData: reply,
                                );
                              }
                            },
                            itemBuilder: (_) {
                              final items = <PopupMenuEntry<String>>[];

                              if (!replyIsMine) {
                                items.add(
                                  PopupMenuItem(
                                    value: 'report',
                                    child: Text(_t('report')),
                                  ),
                                );
                              }

                              if (replyCanDelete) {
                                items.add(
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(_t('delete')),
                                  ),
                                );
                              }

                              return items;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          (reply['reply'] ?? '').toString(),
                          style: _text.bodyMedium?.copyWith(
                            color: _textDark,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyComments() {
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
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: _greenMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: _greenDark,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _t('noCommentsTitle'),
            textAlign: TextAlign.center,
            style: _text.headlineLarge?.copyWith(
              color: _textDark,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t('noCommentsDesc'),
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

  Widget _commentInput(DiaryModel diary) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: _bg,
          border: Border(
            top: BorderSide(color: _line),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: _t('commentHint'),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isSending ? null : () => _sendComment(diary),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('public_diary')
          .doc(widget.diary.id)
          .snapshots(),
      builder: (context, diarySnapshot) {
        final diaryData = diarySnapshot.data?.data();
        final diary = diaryData == null
            ? widget.diary
            : DiaryModel.fromFirestore(widget.diary.id, diaryData);

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
              _t('pageTitle'),
              style: _text.headlineLarge?.copyWith(
                color: _textDark,
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned(
                top: -42,
                right: -24,
                child: Container(
                  width: 165,
                  height: 165,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pinkSoft.withOpacity(0.72),
                  ),
                ),
              ),
              Positioned(
                bottom: 140,
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
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: CommentService.getComments(diary.id),
                        builder: (context, commentSnapshot) {
                          final docs = commentSnapshot.data?.docs ?? [];

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                            children: [
                              _diaryHeaderCard(diary),
                              const SizedBox(height: 16),
                              if (commentSnapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  docs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(36),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (docs.isEmpty)
                                _emptyComments()
                              else
                                Column(
                                  children: docs.map((doc) {
                                    final comment =
                                        Map<String, dynamic>.from(doc.data());
                                    return _commentCard(
                                      diary: diary,
                                      commentId: doc.id,
                                      comment: comment,
                                    );
                                  }).toList(),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    _commentInput(diary),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}