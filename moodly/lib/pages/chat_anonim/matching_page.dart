import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/chat_service.dart';
import 'ruang_chat.dart';
import 'homepage_chat_anonim.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _matchSubscription;
  late final AnimationController _pulseController;

  bool _isSearching = true;
  bool _isFound = false;
  bool _isPreparingMatch = false;
  bool _isEnteringChat = false;

  String? _pendingRoomId;

  String myNickname = 'Kamu';
  String myAvatar = 'assets/profile_pic/PP.png';

  String partnerNickname = 'Teman Baru';
  String partnerAvatar = 'assets/profile_pic/PP_default.jpg';

  static const Color _bgColor = Color(0xFFF3FADC);
  static const Color _greenMain = Color(0xFF84C76A);
  static const Color _greenSoft = Color(0xFFBFE3AF);
  static const Color _greenDark = Color(0xFF5FA84D);
  static const Color _pinkSoft = Color(0xFFF8BDC0);
  static const Color _pinkLight = Color(0xFFFFE6EA);
  static const Color _cardColor = Color(0xFFFFFDF9);
  static const Color _textDark = Color(0xFF222222);
  static const Color _textSoft = Color(0xFF6E7D61);

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.12),
          offset: Offset(0, 3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    startMatching();
  }

  Future<void> startMatching() async {
    await _loadCurrentUserProfile();

    final roomId = await _chatService.findMatch();

    if (!mounted) return;

    if (roomId != null) {
      await _prepareMatchFound(roomId);
      return;
    }

    _listenForMatch();
  }

  void _listenForMatch() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _matchSubscription?.cancel();

    _matchSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
      final data = doc.data();
      final currentRoomId = data?['currentRoomId'];

      if (currentRoomId is String &&
          currentRoomId.isNotEmpty &&
          !_isPreparingMatch &&
          !_isFound) {
        await _prepareMatchFound(currentRoomId);
      }
    });
  }

  Future<void> _loadCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = userDoc.data();

    if (!mounted) return;

    setState(() {
      myNickname = (data?['nickname'] as String?)?.trim().isNotEmpty == true
          ? data!['nickname'] as String
          : 'Kamu';
      myAvatar = (data?['avatarId'] as String?)?.trim().isNotEmpty == true
          ? data!['avatarId'] as String
          : 'assets/profile_pic/PP.png';
    });
  }

  Future<void> _prepareMatchFound(String roomId) async {
    if (_isPreparingMatch) return;

    _isPreparingMatch = true;
    _matchSubscription?.cancel();

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;

      final roomDoc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();

      final roomData = roomDoc.data();
      final participants = (roomData?['participants'] as List?) ?? [];

      String? otherUid;
      for (final item in participants) {
        if (item is String && item != currentUid) {
          otherUid = item;
          break;
        }
      }

      await _loadCurrentUserProfile();

      if (otherUid != null) {
        final otherDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUid)
            .get();
        final otherData = otherDoc.data();

        partnerNickname =
            (otherData?['nickname'] as String?)?.trim().isNotEmpty == true
                ? otherData!['nickname'] as String
                : 'Teman Baru';

        partnerAvatar =
            (otherData?['avatarId'] as String?)?.trim().isNotEmpty == true
                ? otherData!['avatarId'] as String
                : 'assets/profile_pic/PP_default.jpg';
      }

      if (!mounted) return;

      setState(() {
        _pendingRoomId = roomId;
        _isSearching = false;
        _isFound = true;
      });
    } finally {
      _isPreparingMatch = false;
    }
  }

  Future<void> _enterChat() async {
    if (_pendingRoomId == null || _isEnteringChat) return;

    setState(() {
      _isEnteringChat = true;
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatAnonimPage(roomId: _pendingRoomId!),
      ),
    );
  }

  Future<void> _cancelMatchingQueue() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('waiting_users').doc(uid).delete();
    } catch (_) {
      // diabaikan, biar user tetap bisa keluar page walau doc queue tidak ada
    }
  }

  Future<bool> _handleBack() async {
    await _cancelMatchingQueue();
    await _matchSubscription?.cancel();

    if (!mounted) return false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeChatAnonim(),
      ),
      (route) => false,
    );

    return false;
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    _pulseController.dispose();
    _cancelMatchingQueue();
    super.dispose();
  }

  Widget _buildAvatar(String assetPath, {double size = 84}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _pinkLight,
        boxShadow: _softShadow,
        border: Border.all(
          color: const Color(0xFFF0D2D6),
          width: 4,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) {
            return Image.asset(
              'assets/profile_pic/PP_default.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.04).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEAF4D4),
                boxShadow: _softShadow,
              ),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: const Color(0xFF8A5A8D),
                    backgroundColor: _greenSoft.withOpacity(0.45),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Mencari teman ngobrol...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  color: _textDark,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Moodly sedang mencarikan teman curhat yang siap saling mendengar dengan nyaman.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.6,
                  color: _textSoft,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _pinkLight,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Tunggu sebentar yaa...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF7D5A68),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _pinkLight,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Teman ditemukan!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: const Color(0xFFE05C75),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Kamu sekarang sudah terhubung. Yuk mulai percakapan yang hangat dan saling menghargai.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.6,
                  color: _textSoft,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _buildMatchPersonCard(
                  title: 'Kamu',
                  name: myNickname,
                  avatar: myAvatar,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF8D7DC),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: Color(0xFFE05C75),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMatchPersonCard(
                  title: 'Teman baru',
                  name: partnerNickname,
                  avatar: partnerAvatar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isEnteringChat ? null : _enterChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: _greenMain,
                disabledBackgroundColor: _greenMain.withOpacity(0.65),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isEnteringChat
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Mulai ngobrol',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchPersonCard({
    required String title,
    required String name,
    required String avatar,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBEE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildAvatar(avatar, size: 74),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: _textSoft,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  color: _textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -30,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _greenSoft.withOpacity(0.30),
            ),
          ),
        ),
        Positioned(
          top: 110,
          left: -60,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pinkLight.withOpacity(0.55),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _greenSoft.withOpacity(0.22),
            ),
          ),
        ),
        Positioned(
          left: 28,
          right: 28,
          bottom: 90,
          child: IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => Transform.rotate(
                  angle: (index.isEven ? 1 : -1) * 0.35,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: index.isEven ? _greenMain : const Color(0xFFE798A7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildDecorativeBackground(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _handleBack,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.75),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isFound ? 'Teman Curhat Ditemukan' : 'Mencari Teman Curhat',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: 26,
                                  color: _textDark,
                                ),
                          ),
                        ),
                        const SizedBox(width: 52),
                      ],
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.96,
                              end: 1.0,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _isFound
                          ? KeyedSubtree(
                              key: const ValueKey('found'),
                              child: _buildFoundCard(),
                            )
                          : KeyedSubtree(
                              key: const ValueKey('searching'),
                              child: _buildSearchingCard(),
                            ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}