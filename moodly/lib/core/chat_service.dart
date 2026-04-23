import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> ensureDebugRoom() async {
    const String roomId = 'debug_room_1';

    final roomRef = _firestore.collection('chat_rooms').doc(roomId);

    await roomRef.set({
      'roomId': roomId,
      'title': 'Kangen Liburan',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'participants': FieldValue.arrayUnion([
        _auth.currentUser?.uid,
      ]),
    }, SetOptions(merge: true));

    return roomId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String roomId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chat_rooms').doc(roomId).set({
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}