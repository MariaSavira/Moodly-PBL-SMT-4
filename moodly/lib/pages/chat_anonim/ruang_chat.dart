import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/chat_service.dart';

class ChatAnonimPage extends StatefulWidget {
  const ChatAnonimPage({super.key});

  @override
  State<ChatAnonimPage> createState() => _ChatAnonimPageState();
}

class _ChatAnonimPageState extends State<ChatAnonimPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  String? roomId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initChat();
  }

  Future<void> initChat() async {
    final id = await _chatService.ensureDebugRoom();

    if (!mounted) return;

    setState(() {
      roomId = id;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (roomId == null) return;

    await _chatService.sendMessage(
      roomId: roomId!,
      text: _messageController.text,
    );

    _messageController.clear();
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Kangen Liburan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
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
                        'assets/profile_pic/PP_2.png',
                        fit: BoxFit.cover,
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
                        const SizedBox(height: 14),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: pinkSoft,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.notifications_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Kamu terhubung dengan Kangen Liburan!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: pinkSoft,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Berbincang dengan sopan, ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'hormati sesama!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: pinkSoft,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            'Mulailah Bercerita!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

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

                              final docs = snapshot.data?.docs ?? [];
                              final currentUid =
                                  FirebaseAuth.instance.currentUser?.uid;

                              return ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  0,
                                  18,
                                  110,
                                ),
                                children: [
                                  const SizedBox(height: 260),

                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD6D6D6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Hari ini',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B6B6B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  ...docs.map((doc) {
                                    final data = doc.data();
                                    final text = data['text'] ?? '';
                                    final senderId = data['senderId'];
                                    final isMe = senderId == currentUid;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: Column(
                                        crossAxisAlignment: isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: 265,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isMe
                                                  ? const Color(0xFFE9F6E2)
                                                  : pinkBubble,
                                              borderRadius: BorderRadius.only(
                                                topLeft: const Radius.circular(18),
                                                topRight:
                                                    const Radius.circular(18),
                                                bottomLeft: Radius.circular(
                                                  isMe ? 18 : 6,
                                                ),
                                                bottomRight: Radius.circular(
                                                  isMe ? 6 : 18,
                                                ),
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: shadowColor,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              text,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            '09.41',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF8D8D8D),
                                              fontWeight: FontWeight.w600,
                                            ),
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

                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Row(
                        children: [
                          Container(
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
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
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
                                  const Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: Color(0xFF86B864),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        hintText: 'Bagaimana kabarmu?',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF8A8A8A),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}