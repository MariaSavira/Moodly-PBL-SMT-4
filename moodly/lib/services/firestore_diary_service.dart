import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/diary_model.dart';

class FirestoreDiaryService {
  FirestoreDiaryService._();
  static final FirestoreDiaryService instance = FirestoreDiaryService._();

  factory FirestoreDiaryService() => instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _diaryRef =>
      _db.collection('diaries');

  CollectionReference<Map<String, dynamic>> get _publicDiaryRef =>
      _db.collection('public_diary');

  String? get currentUid => _auth.currentUser?.uid;

  static Future<void> updateCommentCount({
    required String diaryId,
    required int total,
  }) async {
    await instance.syncCommentCount(
      diaryId: diaryId,
      count: total,
    );
  }

  String _normalizeMonth(String month) => month.trim().toUpperCase();

  int _monthNumber(String code) {
    const map = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MEI': 5,
      'JUN': 6,
      'JUL': 7,
      'AGS': 8,
      'SEP': 9,
      'OKT': 10,
      'NOV': 11,
      'DES': 12,
    };
    return map[code.toUpperCase()] ?? 1;
  }

  DateTime _entryDateTime(DiaryModel diary) {
    final parts = diary.time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(
      diary.year,
      _monthNumber(diary.month),
      diary.date,
      hour,
      minute,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  DateTime _endOfWeek(DateTime date) {
    return _startOfWeek(date).add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  DocumentReference<Map<String, dynamic>> _privateDoc(String diaryId) {
    return _diaryRef.doc(diaryId);
  }

  DocumentReference<Map<String, dynamic>> _publicDoc(String diaryId) {
    return _publicDiaryRef.doc(diaryId);
  }

    DocumentReference<Map<String, dynamic>> _moodDoc(String uid) {
      return _db.collection('moods').doc(uid);
    }

    String _dateKeyFromParts({
      required int year,
      required String month,
      required int date,
    }) {
      final monthNumber = _monthNumber(month);
      return '$year-${monthNumber.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}';
    }

    String _canonicalMoodValue(String raw) {
      switch (raw.trim().toLowerCase()) {
        case 'happy':
        case 'senang':
          return 'Senang';
        case 'neutral':
        case 'netral':
          return 'Netral';
        case 'sad':
        case 'sedih':
          return 'Sedih';
        case 'angry':
        case 'marah':
          return 'Marah';
        default:
          return 'Netral';
      }
    }

    String _previewNote(String raw) => raw.trim();

    Future<void> _syncMoodMirrorFromDiary({
      required String uid,
      required int year,
      required String month,
      required int date,
      required String mood,
      required String note,
    }) async {
      final dateKey = _dateKeyFromParts(
        year: year,
        month: month,
        date: date,
      );

      final cleanNote = _previewNote(note);

      final payload = <String, dynamic>{
        'uid': uid,
        'entries': {dateKey: _canonicalMoodValue(mood)},
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (cleanNote.isNotEmpty) {
        payload['notes'] = {dateKey: cleanNote};
      }

      await _moodDoc(uid).set(payload, SetOptions(merge: true));

      if (cleanNote.isEmpty) {
        try {
          await _moodDoc(uid).update({
            'notes.$dateKey': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          // Abaikan kalau field notes belum ada.
        }
      }
    }

    Future<void> _rebuildDiaryMirrorForDate({
      required String uid,
      required String dateKey,
    }) async {
      final parts = dateKey.split('-');
      if (parts.length != 3) return;

      final year = int.tryParse(parts[0]);
      final monthNumber = int.tryParse(parts[1]);
      final date = int.tryParse(parts[2]);

      if (year == null || monthNumber == null || date == null) return;

      const monthMap = {
        1: 'JAN',
        2: 'FEB',
        3: 'MAR',
        4: 'APR',
        5: 'MEI',
        6: 'JUN',
        7: 'JUL',
        8: 'AGS',
        9: 'SEP',
        10: 'OKT',
        11: 'NOV',
        12: 'DES',
      };

      final monthCode = monthMap[monthNumber] ?? 'JAN';

      final snapshot = await _diaryRef
          .where('uid', isEqualTo: uid)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: monthCode)
          .where('date', isEqualTo: date)
          .get();

      final items = snapshot.docs.map(_fromDoc).toList()
        ..sort((a, b) {
          final aTime = a.updatedAt ?? a.createdAt;
          final bTime = b.updatedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });

      if (items.isEmpty) {
        try {
          await _moodDoc(uid).update({
            'notes.$dateKey': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          // Abaikan kalau notes belum ada.
        }
        return;
      }

      final latest = items.first;

      await _syncMoodMirrorFromDiary(
        uid: uid,
        year: latest.year,
        month: latest.month,
        date: latest.date,
        mood: latest.mood,
        note: latest.content,
      );
    }

  Future<void> _deletePublicMirrorWithComments(String diaryId) async {
    final publicDoc = _publicDoc(diaryId);
    final publicSnap = await publicDoc.get();

    if (!publicSnap.exists) return;

    final commentsSnap = await publicDoc.collection('comments').get();
    final batch = _db.batch();

    for (final comment in commentsSnap.docs) {
      batch.delete(comment.reference);
    }

    batch.delete(publicDoc);
    await batch.commit();
  }

  Map<String, dynamic> _payloadForFirestore(DiaryModel diary) {
    return {
      'id': diary.id,
      'uid': diary.uid,
      'title': diary.title,
      'content': diary.content,
      'time': diary.time,
      'date': diary.date,
      'month': _normalizeMonth(diary.month),
      'year': diary.year,
      'isPublic': diary.isPublic,
      'username': diary.username,
      'mood': diary.mood,
      'image_url': diary.imageUrl,
      'profileImage': diary.profileImage,
      'images': diary.images,
      'likes': diary.likes,
      'comments': diary.comments,
      'likedBy': diary.likedBy,
      'createdAt': diary.createdAt,
      'updatedAt': diary.updatedAt,
      'created_at': diary.createdAt,
      'updated_at': diary.updatedAt,
    };
  }

  DiaryModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return DiaryModel.fromFirestore(doc.id, doc.data() ?? {});
  }

    Future<String> createDiary({
      required String title,
      required String content,
      required String time,
      required int date,
      required String month,
      required int year,
      required bool isPublic,
      required String mood,
      List<String> images = const [],
      String imageUrl = '',
    }) async {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User belum login.');
      }

      final privateDoc = _diaryRef.doc();
      final publicDoc = _publicDiaryRef.doc(privateDoc.id);
      final now = DateTime.now();

      final diary = DiaryModel(
        id: privateDoc.id,
        uid: user.uid,
        title: title.trim(),
        content: content.trim(),
        time: time,
        date: date,
        month: _normalizeMonth(month),
        year: year,
        isPublic: isPublic,
        username: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'Anonymous',
        mood: mood.trim().isEmpty ? 'netral' : mood.trim(),
        imageUrl: imageUrl.isNotEmpty
            ? imageUrl
            : (images.isNotEmpty ? images.first : ''),
        profileImage: user.photoURL ?? '',
        images: images,
        createdAt: now,
        updatedAt: now,
        likedBy: const [],
        likes: 0,
        comments: 0,
      );

      final payload = _payloadForFirestore(diary);
      final batch = _db.batch();

      batch.set(privateDoc, {
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (isPublic) {
        batch.set(publicDoc, {
          ...payload,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      await _syncMoodMirrorFromDiary(
        uid: user.uid,
        year: diary.year,
        month: diary.month,
        date: diary.date,
        mood: diary.mood,
        note: diary.content,
      );

      return privateDoc.id;
    }

  Future<void> updateDiary({
    required String diaryId,
    required String title,
    required String content,
    required String time,
    required int date,
    required String month,
    required int year,
    required bool isPublic,
    required String mood,
    required String username,
    required String profileImage,
    required String uid,
    List<String> images = const [],
    String imageUrl = '',
    DateTime? createdAt,
    int likes = 0,
    int comments = 0,
    List likedBy = const [],
  }) async {
    final oldSnap = await _privateDoc(diaryId).get();
    final oldDiary = oldSnap.exists && oldSnap.data() != null
        ? _fromDoc(oldSnap)
        : null;

    final normalizedMonth = _normalizeMonth(month);
    final privateDoc = _privateDoc(diaryId);
    final publicDoc = _publicDoc(diaryId);

    final payload = <String, dynamic>{
      'id': diaryId,
      'uid': uid,
      'title': title.trim(),
      'content': content.trim(),
      'time': time,
      'date': date,
      'month': normalizedMonth,
      'year': year,
      'isPublic': isPublic,
      'username': username,
      'mood': mood.trim().isEmpty ? 'netral' : mood.trim(),
      'image_url': imageUrl.isNotEmpty
          ? imageUrl
          : (images.isNotEmpty ? images.first : ''),
      'profileImage': profileImage,
      'images': images,
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (createdAt != null) {
      payload['createdAt'] = Timestamp.fromDate(createdAt);
      payload['created_at'] = Timestamp.fromDate(createdAt);
    }

    await privateDoc.set(payload, SetOptions(merge: true));

    if (isPublic) {
      await publicDoc.set(payload, SetOptions(merge: true));
    } else {
      await _deletePublicMirrorWithComments(diaryId);
    }

    await _syncMoodMirrorFromDiary(
      uid: uid,
      year: year,
      month: normalizedMonth,
      date: date,
      mood: mood,
      note: content,
    );

    if (oldDiary != null) {
      final oldDateKey = _dateKeyFromParts(
        year: oldDiary.year,
        month: oldDiary.month,
        date: oldDiary.date,
      );

      final newDateKey = _dateKeyFromParts(
        year: year,
        month: normalizedMonth,
        date: date,
      );

      if (oldDateKey != newDateKey) {
        await _rebuildDiaryMirrorForDate(
          uid: uid,
          dateKey: oldDateKey,
        );
      }
    }
  }

  Future<void> deleteDiary(String diaryId) async {
    final existing = await getDiaryById(diaryId);

    await _deletePublicMirrorWithComments(diaryId);
    await _privateDoc(diaryId).delete();

    if (existing != null && existing.uid.isNotEmpty) {
      await _rebuildDiaryMirrorForDate(
        uid: existing.uid,
        dateKey: _dateKeyFromParts(
          year: existing.year,
          month: existing.month,
          date: existing.date,
        ),
      );
    }
  }

  Future<void> _deletePublicCommentsOnly(String diaryId) async {
    final publicDoc = _publicDoc(diaryId);
    final publicSnap = await publicDoc.get();
    if (!publicSnap.exists) return;

    final commentDocs = await publicDoc.collection('comments').get();
    final batch = _db.batch();

    for (final comment in commentDocs.docs) {
      batch.delete(comment.reference);
    }

    await batch.commit();
  }

  Future<DiaryModel?> getDiaryById(String diaryId) async {
    final doc = await _privateDoc(diaryId).get();
    if (!doc.exists || doc.data() == null) return null;
    return _fromDoc(doc);
  }

  Stream<DiaryModel?> watchDiaryById(String diaryId) {
    return _privateDoc(diaryId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return _fromDoc(doc);
    });
  }

  Stream<List<DiaryModel>> getUserDiaries() {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);

    return _diaryRef.where('uid', isEqualTo: uid).snapshots().map((snapshot) {
      final items = snapshot.docs.map(_fromDoc).toList();
      items.sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));
      return items;
    });
  }

  Stream<List<DiaryModel>> getPrivateDiaries(String month, int year) {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);

    final normalizedMonth = _normalizeMonth(month);

    return _diaryRef
        .where('uid', isEqualTo: uid)
        .where('month', isEqualTo: normalizedMonth)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(_fromDoc).toList();
      items.sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));
      return items;
    });
  }

  Stream<List<DiaryModel>> getUserDiariesByYear(int year) {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);

    return _diaryRef
        .where('uid', isEqualTo: uid)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(_fromDoc).toList();
      items.sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));
      return items;
    });
  }

  Stream<List<DiaryModel>> getUserDiariesByWeek(DateTime anchor) {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);

    final start = _startOfWeek(anchor);
    final end = _endOfWeek(anchor);

    return _diaryRef.where('uid', isEqualTo: uid).snapshots().map((snapshot) {
      final items = snapshot.docs.map(_fromDoc).where((diary) {
        final entry = _entryDateTime(diary);
        return !entry.isBefore(start) && !entry.isAfter(end);
      }).toList();

      items.sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));
      return items;
    });
  }

  Stream<List<DiaryModel>> searchUserDiaries(String query) {
    final uid = currentUid;
    final clean = query.trim().toLowerCase();
    if (uid == null || clean.isEmpty) return Stream.value([]);

    return _diaryRef.where('uid', isEqualTo: uid).snapshots().map((snapshot) {
      final items = snapshot.docs.map(_fromDoc).where((diary) {
        final month = diary.month.toLowerCase();
        final title = diary.title.toLowerCase();
        final content = diary.content.toLowerCase();
        final mood = diary.mood.toLowerCase();
        final dateText = '${diary.date} $month ${diary.year}'.toLowerCase();

        return title.contains(clean) ||
            content.contains(clean) ||
            mood.contains(clean) ||
            dateText.contains(clean);
      }).toList();

      items.sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));
      return items;
    });
  }

  Stream<List<DiaryModel>> getPublicDiaries({int limit = 50}) {
    final sourceStream =
        _diaryRef.where('isPublic', isEqualTo: true).snapshots();

    final mirrorStream = _publicDiaryRef.snapshots();

    return Stream.multi((controller) {
      List<DiaryModel> sourceItems = [];
      List<DiaryModel> mirrorItems = [];

      void emitMerged() {
        final merged = <String, DiaryModel>{};

        for (final item in sourceItems) {
          merged[item.id] = item;
        }

        for (final item in mirrorItems) {
          merged[item.id] = item;
        }

        final items = merged.values.toList()
          ..sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));

        controller.add(
          items.length > limit ? items.take(limit).toList() : items,
        );
      }

      final sub1 = sourceStream.listen(
        (snapshot) {
          sourceItems = snapshot.docs.map(_fromDoc).toList();
          emitMerged();
        },
        onError: controller.addError,
      );

      final sub2 = mirrorStream.listen(
        (snapshot) {
          mirrorItems = snapshot.docs.map(_fromDoc).toList();
          emitMerged();
        },
        onError: controller.addError,
      );

      controller.onCancel = () async {
        await sub1.cancel();
        await sub2.cancel();
      };
    });
  }

  Stream<List<DiaryModel>> searchPublicDiaries(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return Stream.value([]);

    return getPublicDiaries(limit: 999).map((items) {
      final filtered = items.where((diary) {
        final title = diary.title.toLowerCase();
        final content = diary.content.toLowerCase();
        final username = diary.username.toLowerCase();
        final mood = diary.mood.toLowerCase();
        final dateText = '${diary.date} ${diary.month} ${diary.year}'.toLowerCase();

        return title.contains(clean) ||
            content.contains(clean) ||
            username.contains(clean) ||
            mood.contains(clean) ||
            dateText.contains(clean);
      }).toList();

      filtered.sort((a, b) => _entryDateTime(b).compareTo(_entryDateTime(a)));
      return filtered;
    });
  }

  Future<void> ensurePublicMirror(DiaryModel diary) async {
    if (!diary.isPublic) return;

    final publicRef = _publicDoc(diary.id);
    final publicSnap = await publicRef.get();

    if (publicSnap.exists) return;

    final payload = {
      'id': diary.id,
      'uid': diary.uid,
      'title': diary.title,
      'content': diary.content,
      'time': diary.time,
      'date': diary.date,
      'month': _normalizeMonth(diary.month),
      'year': diary.year,
      'isPublic': true,
      'username': diary.username,
      'mood': diary.mood,
      'image_url': diary.imageUrl,
      'profileImage': diary.profileImage,
      'images': diary.images,
      'likes': diary.likes,
      'comments': diary.comments,
      'likedBy': diary.likedBy,
      'createdAt': Timestamp.fromDate(diary.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'created_at': Timestamp.fromDate(diary.createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    };

    await publicRef.set(payload, SetOptions(merge: true));
  }

  Future<void> toggleDiaryLike({
    required String diaryId,
    required bool isPublicDiary,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('User belum login.');

    final targetRef = isPublicDiary ? _publicDoc(diaryId) : _privateDoc(diaryId);
    final targetSnap = await targetRef.get();

    if (!targetSnap.exists || targetSnap.data() == null) {
      throw Exception('Diary tidak ditemukan.');
    }

    final data = targetSnap.data()!;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final alreadyLiked = likedBy.contains(uid);

    final likeUpdate = {
      'likedBy': alreadyLiked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
      'likes': FieldValue.increment(alreadyLiked ? -1 : 1),
      'updatedAt': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    batch.set(targetRef, likeUpdate, SetOptions(merge: true));

    final mirrorRef = isPublicDiary ? _privateDoc(diaryId) : _publicDoc(diaryId);
    final mirrorSnap = await mirrorRef.get();
    if (mirrorSnap.exists) {
      batch.set(mirrorRef, likeUpdate, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> syncCommentCount({
    required String diaryId,
    required int count,
  }) async {
    final privateRef = _privateDoc(diaryId);
    final publicRef = _publicDoc(diaryId);

    final batch = _db.batch();

    batch.set(privateRef, {
      'comments': count,
      'updatedAt': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final publicSnap = await publicRef.get();
    if (publicSnap.exists) {
      batch.set(publicRef, {
        'comments': count,
        'updatedAt': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}