import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/chat_service.dart';
import 'ruang_chat.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  final ChatService _chatService = ChatService();

  StreamSubscription? _matchSubscription;

  @override
  void initState() {
    super.initState();
    startMatching();
  }

  // 🔥 MULAI MATCHING
  void startMatching() async {
    final roomId = await _chatService.findMatch();

    if (roomId != null) {
      goToChat(roomId);
      return;
    }

    _listenForMatch();
  }

  // 🔥 NUNGGU SAMPAI DAPET PASANGAN
  void _listenForMatch() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _matchSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      final data = doc.data();

      if (data?['currentRoomId'] != null) {
        goToChat(data!['currentRoomId']);
      }
    });
  }

  // 🔥 PINDAH KE CHAT
  void goToChat(String roomId) {
    _matchSubscription?.cancel();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatAnonimPage(roomId: roomId),
      ),
    );
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFCF),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Mencari teman ngobrol...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}