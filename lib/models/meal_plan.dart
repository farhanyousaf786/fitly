import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlan {
  final String? id;
  final String title;
  final List<String> mealIds;
  final DateTime date;

  MealPlan({
    this.id,
    required this.title,
    required this.mealIds,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'mealIds': mealIds,
      'date': Timestamp.fromDate(date),
    };
  }

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      title: data['title'] ?? '',
      mealIds: List<String>.from(data['mealIds'] ?? []),
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
