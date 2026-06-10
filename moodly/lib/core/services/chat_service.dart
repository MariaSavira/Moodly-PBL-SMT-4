import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'cloudinary_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Map<String, dynamic> _buildChatNotice({
    required String title,
    required String message,
    String type = 'warning',
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String? _normalizeGender(dynamic value) {
    final raw = value?.toString().trim().toLowerCase();
    if (raw == null || raw.isEmpty) return null;

    if (raw == 'male' ||
        raw == 'laki-laki' ||
        raw == 'laki_laki' ||
        raw == 'cowok' ||
        raw == 'pria') {
      return 'male';
    }

    if (raw == 'female' ||
        raw == 'perempuan' ||
        raw == 'cewek' ||
        raw == 'wanita') {
      return 'female';
    }

    return null;
  }

  String _normalizePreference(dynamic value) {
    final raw = value?.toString().trim().toLowerCase();

    if (raw == 'male' ||
        raw == 'laki-laki' ||
        raw == 'laki_laki' ||
        raw == 'cowok' ||
        raw == 'pria') {
      return 'male';
    }

    if (raw == 'female' ||
        raw == 'perempuan' ||
        raw == 'cewek' ||
        raw == 'wanita') {
      return 'female';
    }

    return 'all';
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool _hasActivePremiumFromMap(Map<String, dynamic>? data) {
    if (data == null) return false;

    final legacyPremium = data['isPremium'] == true;
    final premiumTier = (data['premiumTier'] ?? '').toString().trim();
    final premiumStatus = (data['premiumStatus'] ?? '').toString().trim();
    final premiumExpiresAt = _parseDate(data['premiumExpiresAt']);

    final expired =
        premiumExpiresAt != null && DateTime.now().isAfter(premiumExpiresAt);

    if (expired) return false;

    if (legacyPremium) return true;

    final isTierPremium = premiumTier == 'premium' || premiumTier == 'student';
    return isTierPremium && premiumStatus == 'active';
  }

  bool _isGenderCompatible({
    required String selfGender,
    required String selfPreference,
    required String otherGender,
    required String otherPreference,
  }) {
    final selfAccepts =
        selfPreference == 'all' || selfPreference == otherGender;
    final otherAccepts =
        otherPreference == 'all' || otherPreference == selfGender;

    return selfAccepts && otherAccepts;
  }

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
      if (user != null) 'participants': FieldValue.arrayUnion([user.uid]),
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
    required String reportTag,
    required String reportReason,
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
      'reportTag': reportTag,
      'reportReason': reportReason,
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
    final roomSnap = await roomRef.get();

    if (!roomSnap.exists) return;

    final data = roomSnap.data();
    final participants = data?['participants'];

    final messagesSnapshot = await roomRef.collection('messages').get();
    final batch = _firestore.batch();

    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    if (participants is List) {
      for (final uid in participants) {
        final userRef = _firestore.collection('users').doc(uid);
        final isInitiator = uid == user.uid;

        batch.set(
          userRef,
          {
            'status': 'idle',
            'currentRoomId': null,
            'updatedAt': FieldValue.serverTimestamp(),
            'chatNotice': _buildChatNotice(
              title: 'Percakapan berakhir',
              message: isInitiator
                  ? 'Kamu telah mengakhiri percakapan.'
                  : 'Teman chat telah mengakhiri percakapan.',
              type: isInitiator ? 'info' : 'warning',
            ),
          },
          SetOptions(merge: true),
        );
      }
    }

    batch.delete(roomRef);
    await batch.commit();
  }

  Future<String?> findMatch({
    String preferredGender = 'all',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final waitingRef = _firestore.collection('waiting_users');
    final userRef = _firestore.collection('users').doc(user.uid);
    final selfWaitingRef = waitingRef.doc(user.uid);

    try {
      final selfUserSnap = await userRef.get();
      final selfUserData = selfUserSnap.data() ?? {};

      final selfGender = _normalizeGender(selfUserData['gender']);
      if (selfGender == null) {
        await userRef.set({
          'status': 'idle',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        throw Exception('Gender user belum diisi.');
      }

      final selfHasPremium = _hasActivePremiumFromMap(selfUserData);
      final effectivePreference =
          selfHasPremium ? _normalizePreference(preferredGender) : 'all';

      await userRef.set(
        {
          'status': 'matching',
          'currentRoomId': null,
          'gender': selfGender,
          'preferredMatchGender': effectivePreference,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await selfWaitingRef.set(
        {
          'uid': user.uid,
          'status': 'matching',
          'userGender': selfGender,
          'preferredPartnerGender': effectivePreference,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final snapshot = await waitingRef.orderBy('createdAt').limit(20).get();

      QueryDocumentSnapshot<Map<String, dynamic>>? otherUserDoc;

      for (final doc in snapshot.docs) {
        if (doc.id == user.uid) continue;

        final otherData = doc.data();
        final otherGender = _normalizeGender(otherData['userGender']);
        final otherPreference =
            _normalizePreference(otherData['preferredPartnerGender']);

        if (otherGender == null) continue;

        final compatible = _isGenderCompatible(
          selfGender: selfGender,
          selfPreference: effectivePreference,
          otherGender: otherGender,
          otherPreference: otherPreference,
        );

        if (compatible) {
          otherUserDoc = doc;
          break;
        }
      }

      if (otherUserDoc == null) {
        return null;
      }

      final otherUid = otherUserDoc.id;
      final otherWaitingRef = waitingRef.doc(otherUid);
      final otherUserRef = _firestore.collection('users').doc(otherUid);
      final roomRef = _firestore.collection('chat_rooms').doc();

      String? resolvedRoomId;

      await _firestore.runTransaction((tx) async {
        final selfWaitSnap = await tx.get(selfWaitingRef);
        final otherWaitSnap = await tx.get(otherWaitingRef);
        final selfUserSnapTx = await tx.get(userRef);
        final otherUserSnap = await tx.get(otherUserRef);

        final selfUserDataTx = selfUserSnapTx.data() ?? {};
        final otherUserData = otherUserSnap.data() ?? {};
        final selfWaitData = selfWaitSnap.data() ?? {};
        final otherWaitData = otherWaitSnap.data() ?? {};

        final selfCurrentRoom =
            (selfUserDataTx['currentRoomId'] ?? '').toString().trim();
        final otherCurrentRoom =
            (otherUserData['currentRoomId'] ?? '').toString().trim();

        if (selfCurrentRoom.isNotEmpty) {
          resolvedRoomId = selfCurrentRoom;
          tx.delete(selfWaitingRef);
          return;
        }

        if (otherCurrentRoom.isNotEmpty) {
          return;
        }

        if (!selfWaitSnap.exists || !otherWaitSnap.exists) {
          return;
        }

        final safeSelfGender =
            _normalizeGender(selfWaitData['userGender'] ?? selfUserDataTx['gender']);
        final safeOtherGender =
            _normalizeGender(otherWaitData['userGender'] ?? otherUserData['gender']);

        if (safeSelfGender == null || safeOtherGender == null) {
          return;
        }

        final safeSelfHasPremium = _hasActivePremiumFromMap(selfUserDataTx);
        final safeOtherHasPremium = _hasActivePremiumFromMap(otherUserData);

        final safeSelfPreference = safeSelfHasPremium
            ? _normalizePreference(
                selfWaitData['preferredPartnerGender'] ??
                    selfUserDataTx['preferredMatchGender'],
              )
            : 'all';

        final safeOtherPreference = safeOtherHasPremium
            ? _normalizePreference(
                otherWaitData['preferredPartnerGender'] ??
                    otherUserData['preferredMatchGender'],
              )
            : 'all';

        final compatible = _isGenderCompatible(
          selfGender: safeSelfGender,
          selfPreference: safeSelfPreference,
          otherGender: safeOtherGender,
          otherPreference: safeOtherPreference,
        );

        if (!compatible) {
          return;
        }

        resolvedRoomId = roomRef.id;

        tx.set(roomRef, {
          'roomId': roomRef.id,
          'participants': [user.uid, otherUid],
          'participantGenders': {
            user.uid: safeSelfGender,
            otherUid: safeOtherGender,
          },
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActivityAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          userRef,
          {
            'currentRoomId': roomRef.id,
            'status': 'chatting',
            'gender': safeSelfGender,
            'preferredMatchGender': safeSelfPreference,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        tx.set(
          otherUserRef,
          {
            'currentRoomId': roomRef.id,
            'status': 'chatting',
            'gender': safeOtherGender,
            'preferredMatchGender': safeOtherPreference,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        tx.delete(selfWaitingRef);
        tx.delete(otherWaitingRef);
      });

      return resolvedRoomId;
    } catch (e, st) {
      print('ERROR findMatch: $e');
      print(st);
      rethrow;
    }
  }

  Future<void> closeRoomIfIdle({
    required String roomId,
    required Duration idleLimit,
  }) async {
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomSnap = await transaction.get(roomRef);

      if (!roomSnap.exists) return;

      final data = roomSnap.data();
      if (data == null) return;

      final lastActivityAt = data['lastActivityAt'];
      final participants = data['participants'];

      if (lastActivityAt is! Timestamp) return;

      final lastActivityTime = lastActivityAt.toDate();
      final now = DateTime.now();
      final idleDuration = now.difference(lastActivityTime);

      if (idleDuration < idleLimit) return;

      if (participants is List) {
        for (final uid in participants) {
          final userRef = _firestore.collection('users').doc(uid);

          transaction.set(
            userRef,
            {
              'status': 'idle',
              'currentRoomId': null,
              'updatedAt': FieldValue.serverTimestamp(),
              'chatNotice': _buildChatNotice(
                title: 'Room ditutup otomatis',
                message:
                    'Percakapan berakhir karena tidak ada aktivitas selama 5 menit.',
                type: 'warning',
              ),
            },
            SetOptions(merge: true),
          );
        }
      }

      transaction.delete(roomRef);
    });

    final messagesSnapshot = await roomRef.collection('messages').get();
    final batch = _firestore.batch();

    for (final message in messagesSnapshot.docs) {
      batch.delete(message.reference);
    }

    await batch.commit();
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

          batch.set(
            userRef,
            {
              'currentRoomId': null,
              'status': 'idle',
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
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