import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/chat_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_preview_page.dart';
import 'dart:async';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';

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

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roomSubscription;
  bool _hasForcedExit = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userWarningSubscription;
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

  String _formatMessageTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dateTime = timestamp.toDate();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour.$minute';
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
        title: 'Info percakapan',
        message: 'Room akan tertutup otomatis setelah 5 menit tanpa aktivitas.',
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
          title: 'Tarik napas dulu...',
          message: data['warningMessage'] ??
              'Harap berbicara dengan lebih sopan.',
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

  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
      selectedReportMessages = [];
  
  String? _selectedReportReason;
  String? _selectedReportTag;

  final List<Map<String, String>> _reportOptions = const [
    {
      'tag': 'Kata-kata kasar',
      'reason': 'Pesan mengandung hinaan, makian, atau bahasa menyerang.',
    },
    {
      'tag': 'SARA',
      'reason': 'Pesan mengandung unsur suku, agama, ras, atau antargolongan.',
    },
    {
      'tag': 'Spam',
      'reason': 'Pesan dikirim berulang, mengganggu, atau tidak relevan.',
    },
    {
      'tag': 'Konten seksual',
      'reason': 'Pesan mengandung ajakan, unsur, atau konteks seksual yang tidak pantas.',
    },
    {
      'tag': 'Ancaman',
      'reason': 'Pesan mengandung ancaman, intimidasi, atau membuat tidak aman.',
    },
    {
      'tag': 'Lainnya',
      'reason': 'Konten bermasalah lain yang tidak masuk kategori di atas.',
    },
  ];

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
                height: 1.55, // 🔥 ini bikin rapi kayak "Hari ini"
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
      child: const Text(
        'Room akan tertutup otomatis setelah 5 menit tanpa aktivitas.',
        textAlign: TextAlign.center,
        style: TextStyle(
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
      reportTag: _selectedReportTag ?? 'Lainnya',
      reportReason: _selectedReportReason ?? 'Konten bermasalah.',
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
      title: 'Chat berhasil dilaporkan',
      message: 'Pesan yang kamu pilih sudah dikirim untuk ditinjau.',
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
        title: 'Tarik napas dulu...',
        message: data['warningMessage'] ??
            'Harap berbicara dengan lebih sopan.',
        type: CutePopupType.warning,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
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
        chatPartnerName = 'Teman Chat';
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
        chatPartnerName = 'Menunggu Teman';
        chatPartnerAvatar = 'assets/profile_pic/PP_default.jpg';
      });
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUid)
        .get();

    final userData = userDoc.data();

    setState(() {
      chatPartnerName = userData?['nickname'] ?? 'Teman Chat';
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
          title: 'Percakapan berakhir',
          message: 'Room chat sudah tidak tersedia lagi.',
          type: CutePopupType.warning,
        );
        return;
      }

      final data = doc.data();
      final participants = (data?['participants'] as List?) ?? [];
      final status = data?['status'];

      if (participants.length < 2 || status == 'closed') {
        await _forceCloseChat(
          title: 'Percakapan berakhir',
          message: 'Teman chat telah mengakhiri percakapan.',
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
        title: 'Pesan diperbarui',
        message: 'Perubahan pesan sudah disimpan.',
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
    final text = data['text'] ?? '';
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
              decoration: BoxDecoration(
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
                      color: Color(0xFFE5E5E0),
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
                          'Pilih alasan laporan',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 18),

                        // semua option alasan laporan taruh di sini
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
                label: 'Balas',
                iconColor: const Color(0xFF6FB65B),
                onTap: () {
                  Navigator.pop(context);
                  _setReplyMessage(doc);
                },
              ),
              _actionSheetItem(
                icon: Icons.warning_rounded,
                label: 'Lapor',
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
          title: 'Percakapan berakhir',
          message: 'Room chat sudah tidak tersedia lagi.',
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
          title: 'Room ditutup otomatis',
          message: 'Percakapan berakhir karena tidak ada aktivitas selama 5 menit.',
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
                const Text(
                  'Pilih Mode Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Biasa'),
                  subtitle: const Text('Foto bisa dilihat tanpa batas selama room aktif'),
                  onTap: () => Navigator.pop(context, 'normal'),
                ),
                ListTile(
                  title: const Text('Sekali lihat'),
                  subtitle: const Text('Foto hanya bisa dibuka 1 kali'),
                  onTap: () => Navigator.pop(context, 'once'),
                ),
                ListTile(
                  title: const Text('Dua kali lihat'),
                  subtitle: const Text('Foto hanya bisa dibuka 2 kali'),
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
      return const Text(
        'Pesan dihapus',
        style: TextStyle(
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
                  canOpen ? 'Foto' : 'Foto sudah dilihat',
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

    // 👉 pindah ke halaman preview
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
                              'Pilih alasan laporan',
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
                                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  disabledBackgroundColor: const Color(0xFFCCE0C2),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Lanjutkan',
                                  style: TextStyle(
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
              const Text(
                'Laporkan pesan ini?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pesan yang kamu pilih akan dikirim untuk ditinjau. Kamu juga bisa menghentikan percakapan setelahnya.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      child: const Text(
                        'Batal',
                        style: TextStyle(
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
                      child: const Text(
                        'Laporkan',
                        style: TextStyle(
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
              const Text(
                'Laporan berhasil dikirim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Jika kamu merasa tidak nyaman, kamu bisa menghentikan percakapan sekarang.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      child: const Text(
                        'Lanjutkan',
                        style: TextStyle(
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
                      child: const Text(
                        'Berhenti Chat',
                        style: TextStyle(
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
    const pinkSoft = Color(0xFFF4BFC3);
    const pinkBubble = Color(0xFFFFFFFF);
    const greenButton = Color(0xFF84C76A);
    const greenButtonDark = Color(0xFF5FA84D);
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
                  Container(
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
                                .where((doc) => doc.data()['createdAt'] != null)
                                .toList() ?? [];
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
                                    prefix: 'Kamu terhubung dengan ',
                                    highlight: chatPartnerName,
                                    suffix: '!',
                                  ),
                                  buildSystemMessage(
                                    prefix: 'Berbincang dengan sopan, ',
                                    highlight: 'hormati sesama',
                                    suffix: '!',
                                  ),
                                  buildSystemMessage(
                                    prefix: '',
                                    highlight: 'Mulailah Bercerita!',
                                    suffix: '',
                                  ),

                                  buildDateChip('Hari ini'),

                                  const SizedBox(height: 10),

                                  ...docs.map((doc) {
                                    final data = doc.data();
                                    final text = data['text'] ?? '';
                                    final senderId = data['senderId'];
                                    final isMe = senderId == currentUid;
                                    final isLast = doc == docs.last;

                                    final createdAt = data['createdAt'] as Timestamp?;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: Column(
                                        crossAxisAlignment: isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onLongPress: () {
                                                  final type = data['type'] ?? 'text';

                                                  if (isMe && type == 'text') {
                                                    _showMyMessageActions(doc);
                                                  } else if (!isMe) {
                                                    _showOtherUserMessageActions(doc);
                                                  }
                                                },
                                                onTap: () {
                                                  if (isSelectingReport && !isMe) {
                                                    setState(() {
                                                      if (selectedReportMessageIds.contains(doc.id)) {
                                                        selectedReportMessageIds.remove(doc.id);
                                                        selectedReportMessages.removeWhere((item) => item.id == doc.id);
                                                      } else {
                                                        selectedReportMessageIds.add(doc.id);
                                                        selectedReportMessages.add(doc);
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  constraints: const BoxConstraints(
                                                    maxWidth: 265,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: selectedReportMessageIds.contains(doc.id)
                                                      ? const Color(0xFFFFD6D6)
                                                      : editingMessageId == doc.id
                                                          ? const Color(0xFFFFF1F3)
                                                          : isMe
                                                              ? const Color(0xFFE9F6E2)
                                                              : pinkBubble,
                                                    border: editingMessageId == doc.id
                                                      ? Border.all(
                                                          color: const Color(0xFFF4B7C1),
                                                          width: 1.4,
                                                        )
                                                      : null,
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: const Radius.circular(18),
                                                      topRight: const Radius.circular(18),
                                                      bottomLeft: Radius.circular(isMe ? 18 : 6),
                                                      bottomRight: Radius.circular(isMe ? 6 : 18),
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
                                          const Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              'diedit',
                                              style: TextStyle(
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
                                                          (data['seenBy'] as List).length > 1)
                                                      ? Icons.done_all
                                                      : Icons.done,
                                                  size: 14,
                                                  color: (data['seenBy'] != null &&
                                                          (data['seenBy'] as List).length > 1)
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
                                      final typingUsers = snapshot.data?.data()?['typingUsers'] ?? [];

                                      final isOtherTyping = typingUsers is List &&
                                          typingUsers.any(
                                            (uid) => uid != FirebaseAuth.instance.currentUser?.uid,
                                          );

                                      if (!isOtherTyping) return const SizedBox();
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                  '${selectedReportMessages.length} pesan dipilih untuk dilaporkan',
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
                                      : (editingOriginalText ?? 'Mengedit pesan'),
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
                                child: const Center(
                                  child: Text(
                                    'Berhenti',
                                    style: TextStyle(
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
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

                                          _typingTimer = Timer(const Duration(seconds: 2), () {
                                            if (roomId == null) return;

                                            _chatService.updateTypingStatus(
                                              roomId: roomId!,
                                              isTyping: false,
                                            );
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: editingMessageId != null
                                              ? 'Perbarui pesanmu...'
                                              : 'Bagaimana kabarmu?',
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
                                        duration: const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: editingMessageId != null
                                              ? const Color(0xFFF39AAA)
                                              : const Color(0xFF8CCF68),
                                          borderRadius: BorderRadius.circular(10),
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
                                              editingMessageId != null ? 'Simpan' : 'Kirim',
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
            color: const Color(0xFF8A5A8D).withOpacity(opacity.clamp(0.25, 1.0)),
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