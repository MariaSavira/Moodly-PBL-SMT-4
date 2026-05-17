import 'package:cloud_firestore/cloud_firestore.dart';

class MoodlyNotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String uniqueKey;
  final bool isRead;
  final DateTime createdAt;
  final String? ctaLabel;
  final Map<String, dynamic> payload;

  const MoodlyNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.uniqueKey,
    required this.isRead,
    required this.createdAt,
    this.ctaLabel,
    this.payload = const {},
  });

  factory MoodlyNotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return MoodlyNotificationModel(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      type: (data['type'] ?? 'info').toString(),
      uniqueKey: (data['uniqueKey'] ?? '').toString(),
      isRead: data['isRead'] == true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      ctaLabel: data['ctaLabel']?.toString(),
      payload: Map<String, dynamic>.from(data['payload'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'uniqueKey': uniqueKey,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'ctaLabel': ctaLabel,
      'payload': payload,
    };
  }
}