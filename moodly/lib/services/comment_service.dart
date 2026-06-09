import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _commentRef(String diaryId) {
    return _db.collection('public_diary').doc(diaryId).collection('comments');
  }

  static DocumentReference<Map<String, dynamic>> _commentDoc(
    String diaryId,
    String commentId,
  ) {
    return _commentRef(diaryId).doc(commentId);
  }

  static Future<void> _syncCommentCount(String diaryId) async {
    final snapshot = await _commentRef(diaryId).get();
    final total = snapshot.docs.length;

    final batch = _db.batch();

    final publicDiaryDoc = _db.collection('public_diary').doc(diaryId);
    final privateDiaryDoc = _db.collection('diaries').doc(diaryId);

    batch.set(publicDiaryDoc, {'comments': total}, SetOptions(merge: true));
    batch.set(privateDiaryDoc, {'comments': total}, SetOptions(merge: true));

    await batch.commit();
  }

  static Future<void> addComment({
    required String diaryId,
    required String username,
    required String profileImage,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await _commentRef(diaryId).add({
      'uid': user?.uid ?? '',
      'username': username,
      'profile_image': profileImage,
      'comment': comment,
      'likes': 0,
      'likedBy': <String>[],
      'created_at': FieldValue.serverTimestamp(),
      'replies': <Map<String, dynamic>>[],
    });

    await _syncCommentCount(diaryId);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String diaryId) {
    return _commentRef(diaryId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  static Future<void> likeComment({
    required String diaryId,
    required String commentId,
    required bool isLiked,
    String? userId,
  }) async {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final ref = _commentDoc(diaryId, commentId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};
      final likedBy = List<String>.from(data['likedBy'] ?? const []);
      final currentLikes = (data['likes'] as num?)?.toInt() ?? 0;

      if (isLiked) {
        transaction.update(ref, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': currentLikes > 0 ? currentLikes - 1 : 0,
        });
      } else {
        if (!likedBy.contains(uid)) {
          transaction.update(ref, {
            'likedBy': FieldValue.arrayUnion([uid]),
            'likes': currentLikes + 1,
          });
        }
      }
    });
  }

  static Future<void> addReply({
    required String diaryId,
    required String commentId,
    required String username,
    required String profileImage,
    required String reply,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    final replyData = {
      'uid': user?.uid ?? '',
      'username': username,
      'profile_image': profileImage,
      'reply': reply,
      'likes': 0,
      'created_at': Timestamp.now(),
    };

    await _commentDoc(diaryId, commentId).update({
      'replies': FieldValue.arrayUnion([replyData]),
    });
  }

  static Future<void> deleteComment({
    required String diaryId,
    required String commentId,
  }) async {
    await _commentDoc(diaryId, commentId).delete();
    await _syncCommentCount(diaryId);
  }

  static Future<void> deleteReply({
    required String diaryId,
    required String commentId,
    required Map<String, dynamic> replyData,
  }) async {
    await _commentDoc(diaryId, commentId).update({
      'replies': FieldValue.arrayRemove([replyData]),
    });
  }
}