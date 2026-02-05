import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String? id;
  final String title;
  final List<String> exerciseIds;
  final DateTime createdAt;

  Workout({
    this.id,
    required this.title,
    required this.exerciseIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'exerciseIds': exerciseIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      title: data['title'] ?? '',
      exerciseIds: List<String>.from(data['exerciseIds'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
