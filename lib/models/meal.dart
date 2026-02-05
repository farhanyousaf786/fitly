import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType { breakfast, lunch, dinner, snack }

enum MealCategory {
  highProtein,
  lowCarb,
  vegan,
  vegetarian,
  keto,
  paleo,
  glutenFree,
}

class Meal {
  final String? id;
  final String name;
  final String time;
  final List<String> foods;
  final List<String> avoid;
  final String instructions;

  Meal({
    this.id,
    required this.name,
    required this.time,
    required this.foods,
    required this.avoid,
    required this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'time': time,
      'foods': foods,
      'avoid': avoid,
      'instructions': instructions,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'] ?? '',
      time: map['time'] ?? '',
      foods: List<String>.from(map['foods'] ?? []),
      avoid: List<String>.from(map['avoid'] ?? []),
      instructions: map['instructions'] ?? '',
    );
  }

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meal.fromMap({...data, 'id': doc.id});
  }
}
