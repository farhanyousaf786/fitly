import 'package:cloud_firestore/cloud_firestore.dart';

enum ExerciseType { cardio, strength, flexibility, balance, sports }

enum DifficultyLevel { beginner, intermediate, advanced }

enum MuscleGroup { chest, back, shoulders, arms, legs, core, fullBody }

class Exercise {
  final String? id;
  final String name;
  final String? sets;
  final String? reps;
  final String? duration;
  final String difficulty;
  final String instructions;
  final String? gifUrl;

  Exercise({
    this.id,
    required this.name,
    this.sets,
    this.reps,
    this.duration,
    required this.difficulty,
    required this.instructions,
    this.gifUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'difficulty': difficulty,
      'instructions': instructions,
      'gifUrl': gifUrl,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'] ?? '',
      sets: map['sets'],
      reps: map['reps'],
      duration: map['duration'],
      difficulty: map['difficulty'] ?? 'Medium',
      instructions: map['instructions'] ?? '',
      gifUrl: map['gifUrl'],
    );
  }

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exercise.fromMap({...data, 'id': doc.id});
  }
}
