import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/chat_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_preview_page.dart';
import 'dart:async';

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
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  String chatPartnerName = 'Teman Chat';
  String chatPartnerAvatar = 'assets/profile_pic/PP_default.jpg';

  Timer? _idleTimer;
  bool _hasClosedByIdle = false;

  String? selectedActionMessageId;
  String? replyingMessageId;
  String? replyingText;
  String? replyingType;
  String? replyingSenderId;

  Timer? _typingTimer;

  String _formatMessageTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dateTime = timestamp.toDate();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour.$minute';
  }

  bool isSelectingReport = false;

  final Set<String> selectedReportMessageIds = {};

  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
      selectedReportMessages = [];

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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Laporkan Chat?'),
          content: const Text(
            'Apakah Anda yakin ingin melaporkan chat ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _chatService.reportMessages(
      messages: selectedReportMessages,
    );

    if (!mounted) return;

    setState(() {
      isSelectingReport = false;
      selectedReportMessageIds.clear();
      selectedReportMessages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat berhasil dilaporkan.'),
        backgroundColor: Colors.red,
      ),
    );

    _showAfterReportDialog();
  }

  Future<void> _showAfterReportDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Laporan Berhasil'),
          content: const Text(
            'Anda dapat menghentikan percakapan atau melanjutkan chat ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Lanjutkan'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _handleEndChat();
              },
              child: const Text('Berhenti Matching'),
            ),
          ],
        );
      },
    );
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
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Tarik Napas Dulu...'),
            content: Text(
              data['warningMessage'] ??
                  'Harap berbicara dengan lebih sopan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Oke, Aku Mengerti'),
              ),
            ],
          );
        },
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

    _startIdleWatcher();
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

  @override
  void dispose() {
    _idleTimer?.cancel();
    _typingTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (roomId == null) return;

    await _chatService.sendMessage(
      roomId: roomId!,
      text: _messageController.text,
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
    final controller = TextEditingController(text: oldText);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Pesan'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Tulis ulang pesan...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (roomId == null) return;

                await _chatService.deleteMessageForEveryone(
                  roomId: roomId!,
                  messageId: messageId,
                );

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () async {
                if (roomId == null) return;

                await _chatService.editMessage(
                  roomId: roomId!,
                  messageId: messageId,
                  newText: controller.text,
                );

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);

                  // nanti reply bisa kita sambung di step berikutnya
                  _setReplyMessage(doc);
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.reply_rounded, size: 32, color: Colors.green),
                    SizedBox(height: 6),
                    Text('Reply'),
                  ],
                ),
              ),
              GestureDetector(
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
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_rounded, size: 32, color: Colors.red),
                    SizedBox(height: 6),
                    Text('Lapor'),
                  ],
                ),
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
      if (roomId == null) return;
      if (_hasClosedByIdle) return;

      final roomDoc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();

      if (!roomDoc.exists) {
        _hasClosedByIdle = true;

        if (!mounted) return;

        Navigator.of(context).pop();
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

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Room ditutup otomatis karena tidak ada aktivitas selama 5 menit.',
            ),
          ),
        );

        Navigator.of(context).pop();
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
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data['replyTo']['text'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
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

  Future<void> _handleEndChat() async {
    if (roomId == null) return;

    await _chatService.endChatRoom(roomId!);

    if (!mounted) return;

    Navigator.of(context).pop();
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
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: Colors.black87,
                  ),
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
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/profile_pic/PP_default.jpg',
                            fit: BoxFit.cover,
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

                                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                    stream: _chatService.roomStream(roomId!),
                                    builder: (context, snapshot) {
                                      final typingUsers = snapshot.data?.data()?['typingUsers'] ?? [];

                                      final isOtherTyping = typingUsers is List &&
                                          typingUsers.any(
                                            (uid) => uid != FirebaseAuth.instance.currentUser?.uid,
                                          );

                                      if (!isOtherTyping) return const SizedBox();

                                      return const Padding(
                                        padding: EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          'Sedang mengetik...',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),

                                  buildSystemMessage(
                                    prefix: '',
                                    highlight: 'Jika sama-sama diam, room akan ditutup otomatis dalam 5 menit.',
                                    suffix: '',
                                  ),
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
                                              if (isMe && selectedActionMessageId == doc.id)
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedActionMessageId = null;
                                                    });

                                                    _showEditMessageDialog(doc.id, text);
                                                  },
                                                  child: Container(
                                                    width: 38,
                                                    height: 38,
                                                    margin: const EdgeInsets.only(right: 6),
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF75BE62),
                                                    ),
                                                    child: const Icon(
                                                      Icons.edit_rounded,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),

                                              GestureDetector(
                                                onLongPress: () {
                                                  final type = data['type'] ?? 'text';

                                                  if (isMe && type == 'text') {
                                                    setState(() {
                                                      selectedActionMessageId =
                                                          selectedActionMessageId == doc.id ? null : doc.id;
                                                    });
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
                                                  } else {
                                                    setState(() {
                                                      selectedActionMessageId = null;
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
                                                        : isMe
                                                            ? const Color(0xFFE9F6E2)
                                                            : pinkBubble,
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedReportMessages.length} pesan dipilih untuk dilaporkan',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _confirmReportMessages,
                              icon: const Icon(Icons.warning_rounded, color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isSelectingReport = false;
                                  selectedReportMessageIds.clear();
                                  selectedReportMessages.clear();
                                });
                              },
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                replyingText ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  replyingMessageId = null;
                                });
                              },
                              child: const Icon(Icons.close),
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

                                          _chatService.updateTypingStatus(
                                            roomId: roomId!,
                                            isTyping: value.isNotEmpty,
                                          );

                                          _typingTimer?.cancel();
                                          _typingTimer = Timer(const Duration(seconds: 2), () {
                                            if (roomId == null) return;

                                            _chatService.updateTypingStatus(
                                              roomId: roomId!,
                                              isTyping: false,
                                            );
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Bagaimana kabarmu?',
                                          hintStyle: TextStyle(
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8CCF68),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'GIF',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                          ),
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