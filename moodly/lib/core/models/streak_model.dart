import 'package:cloud_firestore/cloud_firestore.dart';

class StreakModel {
  int currentDay;
  int totalPoints;
  int freezeLeft;
  bool freezeActive;
  List<bool> completed;
  DateTime lastUpdate;

  StreakModel({
    required this.currentDay,
    required this.totalPoints,
    required this.freezeLeft,
    required this.freezeActive,
    required this.completed,
    required this.lastUpdate,
  });

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      currentDay: map['currentDay'] ?? 1,
      totalPoints: map['totalPoints'] ?? 0,
      freezeLeft: map['freezeLeft'] ?? 2,
      freezeActive: map['freezeActive'] ?? false,
      completed: List<bool>.from(map['completed'] ?? []),
      lastUpdate: (map['lastUpdate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentDay': currentDay,
      'totalPoints': totalPoints,
      'freezeLeft': freezeLeft,
      'freezeActive': freezeActive,
      'completed': completed,
      'lastUpdate': lastUpdate,
    };
  }
}