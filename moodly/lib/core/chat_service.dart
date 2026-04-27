import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'cloudinary_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> ensureDebugRoom() async {
    const String roomId = 'debug_room_1';
    final user = _auth.currentUser;

    final roomRef = _firestore.collection('chat_rooms').doc(roomId);

    await roomRef.set({
      'roomId': roomId,
      'title': 'Kangen Liburan',
      'status': 'active',
      'lastActivityAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      if (user != null)
        'participants': FieldValue.arrayUnion([user.uid]),
    }, SetOptions(merge: true));

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'currentRoomId': roomId,
        'status': 'chatting',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return roomId;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> roomStream(String roomId) {
    return _firestore.collection('chat_rooms').doc(roomId).snapshots();
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
    String? replyToMessageId,
    String? replyText,
    String? replyType,
    String? replySenderId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final roomRef = _firestore.collection('chat_rooms').doc(roomId);

    await roomRef.collection('messages').add({
      'type': 'text',
      'senderId': user.uid,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
      'seenBy': [user.uid],
      'isEdited': false,
      'isDeleted': false,
      if (replyToMessageId != null)
        'replyTo': {
          'messageId': replyToMessageId,
          'text': replyText ?? '',
          'type': replyType ?? 'text',
          'senderId': replySenderId,
        },
    });

    await roomRef.set({
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastActivityAt': FieldValue.serverTimestamp(),
      'status': 'active',
    }, SetOptions(merge: true));
  }

  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;

    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);

    final messageSnap = await messageRef.get();
    final data = messageSnap.data();

    if (data == null) return;
    if (data['senderId'] != user.uid) return;
    if (data['type'] != 'text') return;
    if (data['isDeleted'] == true) return;

    await messageRef.update({
      'text': trimmed,
      'isEdited': true,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMessageForEveryone({
    required String roomId,
    required String messageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);

    final messageSnap = await messageRef.get();
    final data = messageSnap.data();

    if (data == null) return;
    if (data['senderId'] != user.uid) return;

    await messageRef.update({
      'isDeleted': true,
      'type': 'deleted',
      'text': 'Pesan dihapus',
      'imageUrl': null,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markMessagesAsSeen({
    required String roomId,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    for (final doc in messages) {
      final data = doc.data();
      final senderId = data['senderId'];

      if (senderId == user.uid) continue;

      final seenBy = data['seenBy'];

      if (seenBy is List && seenBy.contains(user.uid)) continue;

      batch.update(doc.reference, {
        'seenBy': FieldValue.arrayUnion([user.uid]),
      });
    }

    await batch.commit();
  }

  Future<void> updateTypingStatus({
    required String roomId,
    required bool isTyping,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final roomRef = _firestore.collection('chat_rooms').doc(roomId);

    await roomRef.set({
      'typingUsers': isTyping
          ? FieldValue.arrayUnion([user.uid])
          : FieldValue.arrayRemove([user.uid]),
      'lastActivityAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> reportMessages({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (messages.isEmpty) return;

    final reportedUid = messages.first.data()['senderId'];

    final reporterUserDoc =
        await _firestore.collection('users').doc(user.uid).get();

    final reportedUserDoc =
        await _firestore.collection('users').doc(reportedUid).get();

    final reportRef = _firestore.collection('reports').doc();

    await reportRef.set({
      'reportId': reportRef.id,
      'reporterUid': user.uid,
      'reportedUid': reportedUid,
      'reporterInfo': {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'userData': reporterUserDoc.data(),
      },
      'reportedUserInfo': {
        'uid': reportedUid,
        'userData': reportedUserDoc.data(),
      },
      'reportedMessages': messages.map((doc) {
        final data = doc.data();

        return {
          'messageId': doc.id,
          'senderId': data['senderId'],
          'type': data['type'],
          'text': data['text'],
          'imageUrl': data['imageUrl'],
          'viewMode': data['viewMode'],
          'createdAt': data['createdAt'],
          'isEdited': data['isEdited'],
          'isDeleted': data['isDeleted'],
        };
      }).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    await _firestore.collection('users').doc(reportedUid).set({
      'hasWarning': true,
      'warningMessage':
          'Percakapanmu telah dilaporkan. Harap berbicara dengan lebih sopan.',
      'warningUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendImageMessage({
    required String roomId,
    required File imageFile,
    required String viewMode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final uploadResult = await CloudinaryService.uploadImage(imageFile);

      final imageUrl = uploadResult['imageUrl']!;
      final publicId = uploadResult['publicId']!;

      int maxViews = 999999;
      if (viewMode == 'once') {
        maxViews = 1;
      } else if (viewMode == 'twice') {
        maxViews = 2;
      }

      final roomRef = _firestore.collection('chat_rooms').doc(roomId);

      await roomRef.collection('messages').add({
        'type': 'image',
        'senderId': user.uid,
        'imageUrl': imageUrl,
        'cloudinaryPublicId': publicId,
        'viewMode': viewMode,
        'maxViews': maxViews,
        'viewCountByUser': {},
        'createdAt': FieldValue.serverTimestamp(),
        'seenBy': [user.uid],
        'isEdited': false,
        'isDeleted': false,
      });

      await roomRef.set({
        'lastMessage': '[Foto]',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
        'status': 'active',
      }, SetOptions(merge: true));
    } catch (e) {
      print('ERROR sendImageMessage: $e');
    }
  }

  Future<void> endChatRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    final messagesSnapshot = await roomRef.collection('messages').get();

    final batch = _firestore.batch();

    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(roomRef);

    await batch.commit();

    await _firestore.collection('users').doc(user.uid).set({
      'status': 'idle',
      'currentRoomId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> findMatch() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final waitingRef = _firestore.collection('waiting_users');

    // ambil 1 user lain
    final snapshot = await waitingRef
        .orderBy('createdAt')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty &&
        snapshot.docs.first.id != user.uid) {
      
      final otherUserDoc = snapshot.docs.first;
      final otherUid = otherUserDoc.id;

      // ❌ hapus dari queue
      await waitingRef.doc(otherUid).delete();

      // 🔥 buat room baru
      final roomRef = _firestore.collection('chat_rooms').doc();

      await roomRef.set({
        'roomId': roomRef.id,
        'participants': [user.uid, otherUid],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // update user A
      await _firestore.collection('users').doc(user.uid).set({
        'currentRoomId': roomRef.id,
        'status': 'chatting',
      }, SetOptions(merge: true));

      // update user B
      await _firestore.collection('users').doc(otherUid).set({
        'currentRoomId': roomRef.id,
        'status': 'chatting',
      }, SetOptions(merge: true));

      return roomRef.id;
    }

    // ❌ belum ada pasangan → masuk queue
    await waitingRef.doc(user.uid).set({
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return null;
  }

  Future<void> cleanupExpiredIdleRooms() async {
    final fiveMinutesAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(minutes: 5)),
    );

    final snapshot = await _firestore
        .collection('chat_rooms')
        .where('status', isEqualTo: 'idle')
        .where('idleAt', isLessThanOrEqualTo: fiveMinutesAgo)
        .get();

    for (final roomDoc in snapshot.docs) {
      final data = roomDoc.data();
      final participants = data['participants'];

      if (participants is List) {
        final batch = _firestore.batch();

        for (final uid in participants) {
          final userRef = _firestore.collection('users').doc(uid);

          batch.set(userRef, {
            'currentRoomId': null,
            'status': 'idle',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        final messages = await roomDoc.reference.collection('messages').get();

        for (final message in messages.docs) {
          batch.delete(message.reference);
        }

        batch.delete(roomDoc.reference);

        await batch.commit();
      }
    }
  }
}