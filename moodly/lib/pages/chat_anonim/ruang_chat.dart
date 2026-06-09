import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/chat_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_preview_page.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';
import '../../widgets/shared/moodly_reward_frame_avatar.dart';

const String _prefLanguageKey = 'moodly_settings_language_code';

class ChatAnonimPage extends StatefulWidget {
  final String roomId;

  const ChatAnonimPage({
    super.key,
    required this.roomId,
  });

  @override
  State<ChatAnonimPage> createState() => _ChatAnonimPageState();
}

class _ChatAnonimPageState extends State<ChatAnonimPage> {
  bool _hasShownRoomInfoPopup = false;
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  String chatPartnerName = 'Teman Chat';
  String chatPartnerAvatar = 'assets/profile_pic/PP_default.jpg';
  String? chatPartnerUid;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roomSubscription;
  bool _hasForcedExit = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _userWarningSubscription;
  bool _isShowingWarningPopup = false;

  Timer? _idleTimer;
  bool _hasClosedByIdle = false;

  String? replyingMessageId;
  String? replyingText;
  String? replyingType;
  String? replyingSenderId;
  String? editingMessageId;
  String? editingOriginalText;

  Timer? _typingTimer;
  String _languageCode = 'id';

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'chatPartner': 'Teman Chat',
      'waitingFriend': 'Menunggu Teman',
      'youConnectedWith': 'Kamu terhubung dengan ',
      'talkPolitely': 'Berbincang dengan sopan, ',
      'respectOthers': 'hormati sesama',
      'startTelling': 'Mulailah Bercerita!',
      'today': 'Hari ini',
      'infoConversation': 'Info percakapan',
      'roomAutoClose':
          'Room akan tertutup otomatis setelah 5 menit tanpa aktivitas.',
      'takeABreath': 'Tarik napas dulu...',
      'speakPolitely': 'Harap berbicara dengan lebih sopan.',
      'conversationEnded': 'Percakapan berakhir',
      'roomUnavailable': 'Room chat sudah tidak tersedia lagi.',
      'friendEndedChat': 'Teman chat telah mengakhiri percakapan.',
      'autoRoomClosed': 'Room ditutup otomatis',
      'idleClosed':
          'Percakapan berakhir karena tidak ada aktivitas selama 5 menit.',
      'messageUpdated': 'Pesan diperbarui',
      'messageUpdatedSaved': 'Perubahan pesan sudah disimpan.',
      'messageDeleted': 'Pesan dihapus',
      'photo': 'Foto',
      'photoSeen': 'Foto sudah dilihat',
      'selectReportReason': 'Pilih alasan laporan',
      'continue': 'Lanjutkan',
      'reportQuestion': 'Laporkan pesan ini?',
      'reportQuestionDesc':
          'Pesan yang kamu pilih akan dikirim untuk ditinjau. Kamu juga bisa menghentikan percakapan setelahnya.',
      'cancel': 'Batal',
      'report': 'Laporkan',
      'reportSuccessTitle': 'Laporan berhasil dikirim',
      'reportSuccessDesc':
          'Jika kamu merasa tidak nyaman, kamu bisa menghentikan percakapan sekarang.',
      'continueChat': 'Lanjutkan',
      'stopChat': 'Berhenti Chat',
      'reportSent': 'Chat berhasil dilaporkan',
      'reportSentDesc':
          'Pesan yang kamu pilih sudah dikirim untuk ditinjau.',
      'selectedForReport': 'pesan dipilih untuk dilaporkan',
      'updateMessageHint': 'Perbarui pesanmu...',
      'messageHint': 'Bagaimana kabarmu?',
      'save': 'Simpan',
      'send': 'Kirim',
      'stop': 'Berhenti',
      'edited': 'diedit',
      'reply': 'Balas',
      'reportShort': 'Lapor',
      'editMessage': 'Mengedit pesan',
      'selectPhotoMode': 'Pilih Mode Foto',
      'normal': 'Biasa',
      'normalDesc': 'Foto bisa dilihat tanpa batas selama room aktif',
      'once': 'Sekali lihat',
      'onceDesc': 'Foto hanya bisa dibuka 1 kali',
      'twice': 'Dua kali lihat',
      'twiceDesc': 'Foto hanya bisa dibuka 2 kali',
      'reportTag1': 'Kata-kata kasar',
      'reportReason1':
          'Pesan mengandung hinaan, makian, atau bahasa menyerang.',
      'reportTag2': 'SARA',
      'reportReason2':
          'Pesan mengandung unsur suku, agama, ras, atau antargolongan.',
      'reportTag3': 'Spam',
      'reportReason3':
          'Pesan dikirim berulang, mengganggu, atau tidak relevan.',
      'reportTag4': 'Konten seksual',
      'reportReason4':
          'Pesan mengandung ajakan, unsur, atau konteks seksual yang tidak pantas.',
      'reportTag5': 'Ancaman',
      'reportReason5':
          'Pesan mengandung ancaman, intimidasi, atau membuat tidak aman.',
      'reportTag6': 'Lainnya',
      'reportReason6':
          'Konten bermasalah lain yang tidak masuk kategori di atas.',
    },
    'en': {
      'chatPartner': 'Chat Partner',
      'waitingFriend': 'Waiting for a Friend',
      'youConnectedWith': 'You are connected with ',
      'talkPolitely': 'Talk politely, ',
      'respectOthers': 'respect others',
      'startTelling': 'Start Sharing!',
      'today': 'Today',
      'infoConversation': 'Conversation info',
      'roomAutoClose':
          'The room will close automatically after 5 minutes of inactivity.',
      'takeABreath': 'Take a breath...',
      'speakPolitely': 'Please speak more politely.',
      'conversationEnded': 'Conversation ended',
      'roomUnavailable': 'The chat room is no longer available.',
      'friendEndedChat': 'Your chat partner ended the conversation.',
      'autoRoomClosed': 'Room closed automatically',
      'idleClosed':
          'The conversation ended because there was no activity for 5 minutes.',
      'messageUpdated': 'Message updated',
      'messageUpdatedSaved': 'Your message changes have been saved.',
      'messageDeleted': 'Message deleted',
      'photo': 'Photo',
      'photoSeen': 'Photo already viewed',
      'selectReportReason': 'Choose a report reason',
      'continue': 'Continue',
      'reportQuestion': 'Report this message?',
      'reportQuestionDesc':
          'The selected messages will be sent for review. You can also stop the conversation afterwards.',
      'cancel': 'Cancel',
      'report': 'Report',
      'reportSuccessTitle': 'Report submitted',
      'reportSuccessDesc':
          'If you feel uncomfortable, you can stop the conversation now.',
      'continueChat': 'Continue',
      'stopChat': 'Stop Chat',
      'reportSent': 'Chat reported',
      'reportSentDesc':
          'The selected messages have been sent for review.',
      'selectedForReport': 'messages selected for report',
      'updateMessageHint': 'Update your message...',
      'messageHint': 'How are you feeling?',
      'save': 'Save',
      'send': 'Send',
      'stop': 'Stop',
      'edited': 'edited',
      'reply': 'Reply',
      'reportShort': 'Report',
      'editMessage': 'Editing message',
      'selectPhotoMode': 'Choose Photo Mode',
      'normal': 'Normal',
      'normalDesc': 'The photo can be viewed freely while the room is active',
      'once': 'View once',
      'onceDesc': 'The photo can only be opened 1 time',
      'twice': 'View twice',
      'twiceDesc': 'The photo can only be opened 2 times',
      'reportTag1': 'Harsh language',
      'reportReason1':
          'The message contains insults, profanity, or attacking language.',
      'reportTag2': 'Discrimination',
      'reportReason2':
          'The message contains ethnic, religious, racial, or group-based attacks.',
      'reportTag3': 'Spam',
      'reportReason3':
          'The message is repetitive, disruptive, or irrelevant.',
      'reportTag4': 'Sexual content',
      'reportReason4':
          'The message contains inappropriate sexual context, invitation, or content.',
      'reportTag5': 'Threat',
      'reportReason5':
          'The message contains threats, intimidation, or makes others feel unsafe.',
      'reportTag6': 'Other',
      'reportReason6':
          'Other problematic content that does not fit the categories above.',
    },
  };

  String _t(String key) => _copy[_languageCode]?[key] ?? _copy['id']![key] ?? key;

  List<Map<String, String>> get _reportOptions => [
        {
          'tag': _t('reportTag1'),
          'reason': _t('reportReason1'),
        },
        {
          'tag': _t('reportTag2'),
          'reason': _t('reportReason2'),
        },
        {
          'tag': _t('reportTag3'),
          'reason': _t('reportReason3'),
        },
        {
          'tag': _t('reportTag4'),
          'reason': _t('reportReason4'),
        },
        {
          'tag': _t('reportTag5'),
          'reason': _t('reportReason5'),
        },
        {
          'tag': _t('reportTag6'),
          'reason': _t('reportReason6'),
        },
      ];

  String _formatMessageTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dateTime = timestamp.toDate();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour.$minute';
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_prefLanguageKey);

    if (!mounted) return;
    setState(() {
      _languageCode = savedLanguage == 'en' ? 'en' : 'id';
    });
  }

  void _showTopInfo({
    required String title,
    required String message,
    CutePopupType type = CutePopupType.info,
  }) {
    showCuteTopPopup(
      context,
      title: title,
      message: message,
      type: type,
    );
  }

  void _showRoomAutoClosePopupOnce() {
    if (_hasShownRoomInfoPopup || !mounted) return;
    _hasShownRoomInfoPopup = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _showTopInfo(
        title: _t('infoConversation'),
        message: _t('roomAutoClose'),
        type: CutePopupType.info,
      );
    });
  }

  Future<void> _forceCloseChat({
    required String title,
    required String message,
    CutePopupType type = CutePopupType.warning,
  }) async {
    if (_hasForcedExit || !mounted) return;
    _hasForcedExit = true;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeChatAnonim(),
      ),
      (route) => false,
    );
  }

  void _startUserWarningWatcher() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _userWarningSubscription?.cancel();

    _userWarningSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
      final data = doc.data();
      if (data == null) return;

      if (data['hasWarning'] == true && !_isShowingWarningPopup && mounted) {
        _isShowingWarningPopup = true;

        _showTopInfo(
          title: _t('takeABreath'),
          message: data['warningMessage'] ?? _t('speakPolitely'),
          type: CutePopupType.warning,
        );

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'hasWarning': false,
        }, SetOptions(merge: true));

        _isShowingWarningPopup = false;
      }
    });
  }

  bool isSelectingReport = false;

  final Set<String> selectedReportMessageIds = {};
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> selectedReportMessages = [];

  String? _selectedReportReason;
  String? _selectedReportTag;

  Widget buildSystemMessage({
    required String prefix,
    required String highlight,
    required String suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8BDC0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                height: 1.55,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
              children: [
                TextSpan(text: prefix),
                TextSpan(
                  text: highlight,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(text: suffix),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateChip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8BDC0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.55,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 4, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const _TypingDots(),
      ),
    );
  }

  Widget _roomNoticeCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BDC0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _t('roomAutoClose'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          height: 1.45,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFamily: 'OpenSans',
        ),
      ),
    );
  }

  String? roomId;
  bool isLoading = true;

  bool _canOpenImage(Map<String, dynamic> data, String? currentUid) {
    if (currentUid == null) return false;

    final viewMode = data['viewMode'] ?? 'normal';
    if (viewMode == 'normal') return true;

    final maxViews = data['maxViews'] ?? 1;
    final rawMap = data['viewCountByUser'];

    int currentViewCount = 0;

    if (rawMap is Map && rawMap[currentUid] is int) {
      currentViewCount = rawMap[currentUid] as int;
    }

    return currentViewCount < maxViews;
  }

  Future<void> _openImageMessage({
    required DocumentReference<Map<String, dynamic>> messageRef,
    required Map<String, dynamic> data,
  }) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final canOpen = _canOpenImage(data, currentUid);
    if (!canOpen) return;

    final imageUrl = data['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) return;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );

    final viewMode = data['viewMode'] ?? 'normal';
    if (viewMode == 'normal') return;

    await messageRef.update({
      'viewCountByUser.$currentUid': FieldValue.increment(1),
    });
  }

  Future<void> _confirmReportMessages() async {
    if (selectedReportMessages.isEmpty) return;

    final pickedReason = await _showReportReasonSheet();
    if (!pickedReason) return;

    final confirmed = await _showReportConfirmSheet();
    if (!confirmed) return;

    await _chatService.reportMessages(
      messages: selectedReportMessages,
      reportTag: _selectedReportTag ?? _t('reportTag6'),
      reportReason: _selectedReportReason ?? _t('reportReason6'),
    );

    if (!mounted) return;

    setState(() {
      isSelectingReport = false;
      selectedReportMessageIds.clear();
      selectedReportMessages.clear();
      _selectedReportTag = null;
      _selectedReportReason = null;
    });

    _showTopInfo(
      title: _t('reportSent'),
      message: _t('reportSentDesc'),
      type: CutePopupType.warning,
    );

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    _showAfterReportSheet();
  }

  Future<void> _checkWarningStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null) return;

    if (data['hasWarning'] == true && mounted) {
      _showTopInfo(
        title: _t('takeABreath'),
        message: data['warningMessage'] ?? _t('speakPolitely'),
        type: CutePopupType.warning,
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'hasWarning': false,
      }, SetOptions(merge: true));
    }
  }

  @override
  void initState() {
    super.initState();
    initChat();
  }

  Future<void> initChat() async {
    await _loadLanguagePreference();

    final id = widget.roomId;

    if (!mounted) return;

    setState(() {
      roomId = id;
      isLoading = false;
    });

    await _loadChatPartner(id);
    await _checkWarningStatus();

    _startUserWarningWatcher();
    _showRoomAutoClosePopupOnce();
    _startIdleWatcher();
    _startRoomWatcher();
  }

  Future<void> _loadChatPartner(String roomId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final roomDoc = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(roomId)
        .get();

    final roomData = roomDoc.data();
    if (roomData == null) return;

    final participants = roomData['participants'];

    if (participants is! List || participants.isEmpty) {
      setState(() {
        chatPartnerName = _t('chatPartner');
        chatPartnerAvatar = 'assets/profile_pic/PP_default.jpg';
      });
      return;
    }

    final otherUid = participants.firstWhere(
      (uid) => uid != currentUser.uid,
      orElse: () => null,
    );

    if (otherUid == null) {
      setState(() {
        chatPartnerName = _t('waitingFriend');
        chatPartnerAvatar = 'assets/profile_pic/PP_default.jpg';
      });
      return;
    }

    chatPartnerUid = otherUid.toString();

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUid)
        .get();

    final userData = userDoc.data();

    setState(() {
      chatPartnerName = userData?['nickname'] ?? _t('chatPartner');
      chatPartnerAvatar =
          userData?['avatarId'] ?? 'assets/profile_pic/PP_default.jpg';
    });
  }

  void _startRoomWatcher() {
    if (roomId == null) return;

    _roomSubscription?.cancel();

    _roomSubscription = _chatService.roomStream(roomId!).listen((doc) async {
      if (!doc.exists) {
        await _forceCloseChat(
          title: _t('conversationEnded'),
          message: _t('roomUnavailable'),
          type: CutePopupType.warning,
        );
        return;
      }

      final data = doc.data();
      final participants = (data?['participants'] as List?) ?? [];
      final status = data?['status'];

      if (participants.length < 2 || status == 'closed') {
        await _forceCloseChat(
          title: _t('conversationEnded'),
          message: _t('friendEndedChat'),
          type: CutePopupType.warning,
        );
      }
    });
  }

  @override
  void dispose() {
    _userWarningSubscription?.cancel();
    _idleTimer?.cancel();
    _typingTimer?.cancel();
    _roomSubscription?.cancel();

    if (roomId != null) {
      unawaited(
        _chatService.updateTypingStatus(
          roomId: roomId!,
          isTyping: false,
        ),
      );
    }

    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (roomId == null) return;

    final trimmed = _messageController.text.trim();
    if (trimmed.isEmpty) return;

    _typingTimer?.cancel();
    await _chatService.updateTypingStatus(
      roomId: roomId!,
      isTyping: false,
    );

    if (editingMessageId != null) {
      await _chatService.editMessage(
        roomId: roomId!,
        messageId: editingMessageId!,
        newText: trimmed,
      );

      _messageController.clear();

      setState(() {
        editingMessageId = null;
        editingOriginalText = null;
      });

      _showTopInfo(
        title: _t('messageUpdated'),
        message: _t('messageUpdatedSaved'),
        type: CutePopupType.success,
      );

      return;
    }

    await _chatService.sendMessage(
      roomId: roomId!,
      text: trimmed,
      replyToMessageId: replyingMessageId,
      replyText: replyingText,
      replyType: replyingType,
      replySenderId: replyingSenderId,
    );

    _messageController.clear();

    setState(() {
      replyingMessageId = null;
      replyingText = null;
      replyingType = null;
      replyingSenderId = null;
    });
  }

  void _cancelEditing() {
    if (roomId != null) {
      _chatService.updateTypingStatus(
        roomId: roomId!,
        isTyping: false,
      );
    }
    setState(() {
      editingMessageId = null;
      editingOriginalText = null;
    });
    _messageController.clear();
  }

  void _setReplyMessage(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    setState(() {
      replyingMessageId = doc.id;
      replyingText = data['text'] ?? '[Foto]';
      replyingType = data['type'];
      replyingSenderId = data['senderId'];
    });
  }

  Future<void> _showEditMessageDialog(String messageId, String oldText) async {
    setState(() {
      editingMessageId = messageId;
      editingOriginalText = oldText;
      replyingMessageId = null;
      replyingText = null;
      replyingType = null;
      replyingSenderId = null;
    });

    _messageController.text = oldText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  void _showMyMessageActions(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final type = data['type'] ?? 'text';

    if (type != 'text') return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                      children: [
                        Text(
                          _t('selectReportReason'),
                          style:
                              Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: 22,
                                    color: Colors.black,
                                  ),
                        ),
                        const SizedBox(height: 18),
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

  Widget _actionSheetItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.12),
            ),
            child: Icon(
              icon,
              size: 26,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showOtherUserMessageActions(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionSheetItem(
                icon: Icons.reply_rounded,
                label: _t('reply'),
                iconColor: const Color(0xFF6FB65B),
                onTap: () {
                  Navigator.pop(context);
                  _setReplyMessage(doc);
                },
              ),
              _actionSheetItem(
                icon: Icons.warning_rounded,
                label: _t('reportShort'),
                iconColor: const Color(0xFFE36A77),
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    isSelectingReport = true;

                    if (!selectedReportMessageIds.contains(doc.id)) {
                      selectedReportMessageIds.add(doc.id);
                      selectedReportMessages.add(doc);
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startIdleWatcher() {
    _idleTimer?.cancel();

    _idleTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (roomId == null || _hasClosedByIdle || _hasForcedExit) return;

      final roomDoc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();

      if (!roomDoc.exists) {
        _hasClosedByIdle = true;
        await _forceCloseChat(
          title: _t('conversationEnded'),
          message: _t('roomUnavailable'),
          type: CutePopupType.warning,
        );
        return;
      }

      final data = roomDoc.data();
      final lastActivityAt = data?['lastActivityAt'];

      if (lastActivityAt is! Timestamp) return;

      final lastActivityTime = lastActivityAt.toDate();
      final idleDuration = DateTime.now().difference(lastActivityTime);

      if (idleDuration >= const Duration(minutes: 5)) {
        _hasClosedByIdle = true;

        await _chatService.closeRoomIfIdle(
          roomId: roomId!,
          idleLimit: const Duration(minutes: 5),
        );

        await _forceCloseChat(
          title: _t('autoRoomClosed'),
          message: _t('idleClosed'),
          type: CutePopupType.warning,
        );
      }
    });
  }

  Future<String?> _showImageModePicker() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFF3F9DB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t('selectPhotoMode'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(_t('normal')),
                  subtitle: Text(_t('normalDesc')),
                  onTap: () => Navigator.pop(context, 'normal'),
                ),
                ListTile(
                  title: Text(_t('once')),
                  subtitle: Text(_t('onceDesc')),
                  onTap: () => Navigator.pop(context, 'once'),
                ),
                ListTile(
                  title: Text(_t('twice')),
                  subtitle: Text(_t('twiceDesc')),
                  onTap: () => Navigator.pop(context, 'twice'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent(
    DocumentReference<Map<String, dynamic>> messageRef,
    Map<String, dynamic> data,
    String text,
    String? currentUid,
  ) {
    final type = data['type'] ?? 'text';

    if (type == 'deleted') {
      return Text(
        _t('messageDeleted'),
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }

    if (type == 'image') {
      final canOpen = _canOpenImage(data, currentUid);
      final viewMode = data['viewMode'] ?? 'normal';

      if (viewMode == 'normal') {
        return GestureDetector(
          onTap: () => _openImageMessage(
            messageRef: messageRef,
            data: data,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              data['imageUrl'],
              width: 180,
              height: 180,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: canOpen
            ? () => _openImageMessage(
                  messageRef: messageRef,
                  data: data,
                )
            : null,
        child: Container(
          width: 140,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canOpen ? Icons.refresh_rounded : Icons.lock_rounded,
                  size: 22,
                  color: Colors.black54,
                ),
                const SizedBox(height: 8),
                Text(
                  canOpen ? _t('photo') : _t('photoSeen'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data['replyTo'] != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7E8EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              data['replyTo']['text'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7B6670),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePickImage() async {
    if (roomId == null) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewPage(
          imageFile: imageFile,
          roomId: roomId!,
        ),
      ),
    );
  }

  Future<bool> _showReportReasonSheet() async {
    String? tempTag = _selectedReportTag;
    String? tempReason = _selectedReportReason;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.78,
              minChildSize: 0.55,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFCF8),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E0),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                          children: [
                            Text(
                              _t('selectReportReason'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontSize: 22,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            ..._reportOptions.map((option) {
                              final isSelected = tempTag == option['tag'];

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    tempTag = option['tag'];
                                    tempReason = option['reason'];
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 14, 14, 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFF1F3)
                                        : const Color(0xFFF7F4EF),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE36A77)
                                          : const Color(0xFFE8E2D8),
                                      width: isSelected ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        margin: const EdgeInsets.only(top: 2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFFE36A77)
                                                : const Color(0xFFC9C2B7),
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? const Color(0xFFFFD9DF)
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: Color(0xFFE36A77),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              option['tag'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF2B2B2B),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              option['reason'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                height: 1.45,
                                                color: Color(0xFF666666),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: tempTag == null || tempReason == null
                                    ? null
                                    : () {
                                        _selectedReportTag = tempTag;
                                        _selectedReportReason = tempReason;
                                        Navigator.pop(context, true);
                                      },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF84C76A),
                                  disabledBackgroundColor:
                                      const Color(0xFFCCE0C2),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  _t('continue'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
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
      },
    );

    return result ?? false;
  }

  Future<bool> _showReportConfirmSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('reportQuestion'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t('reportQuestionDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: const Color(0xFFF4F0F1),
                      ),
                      child: Text(
                        _t('cancel'),
                        style: const TextStyle(
                          color: Color(0xFF7A6872),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFE36A77),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _t('report'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> _showAfterReportSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('reportSuccessTitle'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t('reportSuccessDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: const Color(0xFFF4F0F1),
                      ),
                      child: Text(
                        _t('continueChat'),
                        style: const TextStyle(
                          color: Color(0xFF7A6872),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _handleEndChat();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF84C76A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _t('stopChat'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleEndChat() async {
    if (roomId == null) return;

    await _chatService.endChatRoom(roomId!);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeChatAnonim(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE8EFCF);
    const pinkBubble = Color(0xFFFFFFFF);
    const greenButton = Color(0xFF84C76A);
    const inputBg = Color(0xFFF5F5F5);
    const shadowColor = Color(0x22000000);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 74,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0x22000000),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 42),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Center(
                      child: Text(
                        chatPartnerName,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ),
                  MoodlyInventoryFrameAvatar(
                    uid: chatPartnerUid,
                    size: 42,
                    innerPadding: 2.5,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFA8F0D6),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          chatPartnerAvatar,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/profile_pic/PP_default.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _chatService.messagesStream(roomId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  !snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final docs = snapshot.data?.docs
                                      .where((doc) =>
                                          doc.data()['createdAt'] != null)
                                      .toList() ??
                                  [];
                              final currentUid =
                                  FirebaseAuth.instance.currentUser?.uid;

                              if (docs.isNotEmpty) {
                                _chatService.markMessagesAsSeen(
                                  roomId: roomId!,
                                  messages: docs,
                                );
                              }

                              return ListView(
                                clipBehavior: Clip.hardEdge,
                                padding: EdgeInsets.fromLTRB(
                                  18,
                                  0,
                                  18,
                                  MediaQuery.of(context).viewInsets.bottom + 125,
                                ),
                                children: [
                                  const SizedBox(height: 10),
                                  buildSystemMessage(
                                    prefix: _t('youConnectedWith'),
                                    highlight: chatPartnerName,
                                    suffix: '!',
                                  ),
                                  buildSystemMessage(
                                    prefix: _t('talkPolitely'),
                                    highlight: _t('respectOthers'),
                                    suffix: '!',
                                  ),
                                  buildSystemMessage(
                                    prefix: '',
                                    highlight: _t('startTelling'),
                                    suffix: '',
                                  ),
                                  buildDateChip(_t('today')),
                                  const SizedBox(height: 10),
                                  ...docs.map((doc) {
                                    final data = doc.data();
                                    final text = data['text'] ?? '';
                                    final senderId = data['senderId'];
                                    final isMe = senderId == currentUid;
                                    final isLast = doc == docs.last;
                                    final createdAt =
                                        data['createdAt'] as Timestamp?;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: Column(
                                        crossAxisAlignment: isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: isMe
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onLongPress: () {
                                                  final type =
                                                      data['type'] ?? 'text';

                                                  if (isMe && type == 'text') {
                                                    _showMyMessageActions(doc);
                                                  } else if (!isMe) {
                                                    _showOtherUserMessageActions(
                                                        doc);
                                                  }
                                                },
                                                onTap: () {
                                                  if (isSelectingReport &&
                                                      !isMe) {
                                                    setState(() {
                                                      if (selectedReportMessageIds
                                                          .contains(doc.id)) {
                                                        selectedReportMessageIds
                                                            .remove(doc.id);
                                                        selectedReportMessages
                                                            .removeWhere(
                                                                (item) =>
                                                                    item.id ==
                                                                    doc.id);
                                                      } else {
                                                        selectedReportMessageIds
                                                            .add(doc.id);
                                                        selectedReportMessages
                                                            .add(doc);
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxWidth: 265,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        selectedReportMessageIds
                                                                .contains(doc.id)
                                                            ? const Color(
                                                                0xFFFFD6D6)
                                                            : editingMessageId ==
                                                                    doc.id
                                                                ? const Color(
                                                                    0xFFFFF1F3)
                                                                : isMe
                                                                    ? const Color(
                                                                        0xFFE9F6E2)
                                                                    : pinkBubble,
                                                    border: editingMessageId ==
                                                            doc.id
                                                        ? Border.all(
                                                            color: const Color(
                                                                0xFFF4B7C1),
                                                            width: 1.4,
                                                          )
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              18),
                                                      topRight:
                                                          const Radius.circular(
                                                              18),
                                                      bottomLeft:
                                                          Radius.circular(
                                                              isMe ? 18 : 6),
                                                      bottomRight:
                                                          Radius.circular(
                                                              isMe ? 6 : 18),
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: shadowColor,
                                                        blurRadius: 8,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: _buildMessageContent(
                                                    doc.reference,
                                                    data,
                                                    text,
                                                    currentUid,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (data['isEdited'] == true)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text(
                                                _t('edited'),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black45,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          if (isLast)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(_formatMessageTime(createdAt)),
                                                const SizedBox(width: 4),
                                                if (isMe)
                                                  Icon(
                                                    (data['seenBy'] != null &&
                                                            (data['seenBy']
                                                                        as List)
                                                                    .length >
                                                                1)
                                                        ? Icons.done_all
                                                        : Icons.done,
                                                    size: 14,
                                                    color: (data['seenBy'] !=
                                                                null &&
                                                            (data['seenBy']
                                                                        as List)
                                                                    .length >
                                                                1)
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                  ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                    stream: _chatService.roomStream(roomId!),
                                    builder: (context, snapshot) {
                                      final typingUsers =
                                          snapshot.data?.data()?['typingUsers'] ??
                                              [];

                                      final isOtherTyping = typingUsers is List &&
                                          typingUsers.any(
                                            (uid) =>
                                                uid !=
                                                FirebaseAuth
                                                    .instance.currentUser?.uid,
                                          );

                                      if (!isOtherTyping) {
                                        return const SizedBox();
                                      }
                                      return _typingBubble();
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    if (isSelectingReport)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 78,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFF4C7CF),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8D3D9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_rounded,
                                  color: Color(0xFFE36A77),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${selectedReportMessages.length} ${_t('selectedForReport')}',
                                  style: const TextStyle(
                                    color: Color(0xFF6C5962),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _confirmReportMessages,
                                icon: const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF84C76A),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isSelectingReport = false;
                                    selectedReportMessageIds.clear();
                                    selectedReportMessages.clear();
                                  });
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF8D737C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (replyingMessageId != null)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF4C7CF),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF39AAA),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  replyingText ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6C5962),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    replyingMessageId = null;
                                    replyingText = null;
                                    replyingType = null;
                                    replyingSenderId = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF8D737C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (editingMessageId != null)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF4C7CF),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF84C76A),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _messageController.text.isNotEmpty
                                      ? _messageController.text
                                      : (editingOriginalText ?? _t('editMessage')),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5B6953),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _cancelEditing,
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF7B8A72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: bgColor,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _handleEndChat,
                              child: Container(
                                width: 95,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: greenButton,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: shadowColor,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _t('stop'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 42,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: shadowColor,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _handlePickImage,
                                      child: const Icon(
                                        Icons.image_outlined,
                                        size: 20,
                                        color: Color(0xFF86B864),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        onChanged: (value) {
                                          if (roomId == null) return;

                                          _typingTimer?.cancel();

                                          if (editingMessageId != null) {
                                            setState(() {});
                                          }

                                          if (value.trim().isEmpty) {
                                            _chatService.updateTypingStatus(
                                              roomId: roomId!,
                                              isTyping: false,
                                            );
                                            return;
                                          }

                                          _chatService.updateTypingStatus(
                                            roomId: roomId!,
                                            isTyping: true,
                                          );

                                          _typingTimer = Timer(
                                              const Duration(seconds: 2), () {
                                            if (roomId == null) return;

                                            _chatService.updateTypingStatus(
                                              roomId: roomId!,
                                              isTyping: false,
                                            );
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: editingMessageId != null
                                              ? _t('updateMessageHint')
                                              : _t('messageHint'),
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF8A8A8A),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textInputAction: TextInputAction.send,
                                        onSubmitted: (_) => _handleSend(),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _handleSend,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: editingMessageId != null
                                              ? const Color(0xFFF39AAA)
                                              : const Color(0xFF8CCF68),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              editingMessageId != null
                                                  ? Icons.check_rounded
                                                  : Icons.send_rounded,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              editingMessageId != null
                                                  ? _t('save')
                                                  : _t('send'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final progress = (_controller.value - (index * 0.12)) % 1.0;
        final opacity = 0.35 + (0.65 * (1 - ((progress - 0.5).abs() * 2)));
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color:
                const Color(0xFF8A5A8D).withOpacity(opacity.clamp(0.25, 1.0)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(0),
        _dot(1),
        _dot(2),
      ],
    );
  }
}