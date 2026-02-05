import 'package:cloud_firestore/cloud_firestore.dart';

enum ExerciseType { cardio, strength, flexibility, balance, sports, other }

enum DifficultyLevel { beginner, intermediate, advanced, expert }

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  legs,
  glutes,
  core,
  calves,
  forearms,
  fullBody,
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final ExerciseType type;
  final DifficultyLevel difficulty;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> instructions;
  final List<String> tips;
  final List<String> equipment;
  final int duration; // in seconds for cardio/flexibility
  final int sets; // for strength exercises
  final int reps; // for strength exercises
  final double weight; // in kg for strength exercises
  final int restTime; // in seconds between sets
  final int caloriesPerMinute;
  final bool isFavorite;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    this.imageUrl,
    this.videoUrl,
    this.instructions = const [],
    this.tips = const [],
    this.equipment = const [],
    this.duration = 0,
    this.sets = 0,
    this.reps = 0,
    this.weight = 0.0,
    this.restTime = 60,
    this.caloriesPerMinute = 5,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory Exercise.fromMap(Map<String, dynamic> data, {String? id}) {
    return Exercise(
      id: id ?? data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: ExerciseType.values.firstWhere(
        (t) => t.toString() == 'ExerciseType.${data['type']}',
        orElse: () => ExerciseType.other,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.toString() == 'DifficultyLevel.${data['difficulty']}',
        orElse: () => DifficultyLevel.beginner,
      ),
      primaryMuscles:
          (data['primaryMuscles'] as List<dynamic>?)
              ?.map(
                (m) => MuscleGroup.values.firstWhere(
                  (muscle) => muscle.toString() == 'MuscleGroup.$m',
                  orElse: () => MuscleGroup.fullBody,
                ),
              )
              .toList() ??
          [],
      secondaryMuscles:
          (data['secondaryMuscles'] as List<dynamic>?)
              ?.map(
                (m) => MuscleGroup.values.firstWhere(
                  (muscle) => muscle.toString() == 'MuscleGroup.$m',
                  orElse: () => MuscleGroup.fullBody,
                ),
              )
              .toList() ??
          [],
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      instructions: List<String>.from(data['instructions'] ?? []),
      tips: List<String>.from(data['tips'] ?? []),
      equipment: List<String>.from(data['equipment'] ?? []),
      duration: data['duration'] ?? 0,
      sets: data['sets'] ?? 0,
      reps: data['reps'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
      restTime: data['restTime'] ?? 60,
      caloriesPerMinute: data['caloriesPerMinute'] ?? 5,
      isFavorite: data['isFavorite'] ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] != null
          ? DateTime.parse(data['createdAt'].toString())
          : DateTime.now(),
    );
  }

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    return Exercise.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'primaryMuscles': primaryMuscles
          .map((m) => m.toString().split('.').last)
          .toList(),
      'secondaryMuscles': secondaryMuscles
          .map((m) => m.toString().split('.').last)
          .toList(),
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'instructions': instructions,
      'tips': tips,
      'equipment': equipment,
      'duration': duration,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
      'caloriesPerMinute': caloriesPerMinute,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    ExerciseType? type,
    DifficultyLevel? difficulty,
    List<MuscleGroup>? primaryMuscles,
    List<MuscleGroup>? secondaryMuscles,
    String? imageUrl,
    String? videoUrl,
    List<String>? instructions,
    List<String>? tips,
    List<String>? equipment,
    int? duration,
    int? sets,
    int? reps,
    double? weight,
    int? restTime,
    int? caloriesPerMinute,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      equipment: equipment ?? this.equipment,
      duration: duration ?? this.duration,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      caloriesPerMinute: caloriesPerMinute ?? this.caloriesPerMinute,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get estimated calories for this exercise
  int get estimatedCalories {
    if (type == ExerciseType.cardio) {
      return (duration / 60 * caloriesPerMinute).round();
    } else {
      // For strength exercises, estimate based on sets and reps
      final totalTime =
          (sets * (reps * 3 + restTime)) / 60; // 3 seconds per rep
      return (totalTime * caloriesPerMinute).round();
    }
  }

  // Get formatted duration
  String get formattedDuration {
    if (duration > 0) {
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      if (minutes > 0) {
        return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
      } else {
        return '${seconds}s';
      }
    } else if (sets > 0 && reps > 0) {
      return '$sets sets × $reps reps';
    } else {
      return 'N/A';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, type: $type, difficulty: $difficulty)';
  }
}

class Workout {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int totalDuration; // in minutes
  final int totalCalories;
  final DifficultyLevel difficulty;
  final List<MuscleGroup> targetMuscles;
  final List<String> equipment;
  final DateTime createdAt;
  final bool isFavorite;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.totalDuration,
    required this.totalCalories,
    required this.difficulty,
    required this.targetMuscles,
    this.equipment = const [],
    required this.createdAt,
    this.isFavorite = false,
  });

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final exercisesData = data['exercises'] as List<dynamic>? ?? [];

    return Workout(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      exercises: exercisesData
          .map((exerciseData) => Exercise.fromMap(exerciseData))
          .toList(),
      totalDuration: data['totalDuration'] ?? 0,
      totalCalories: data['totalCalories'] ?? 0,
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.toString() == 'DifficultyLevel.${data['difficulty']}',
        orElse: () => DifficultyLevel.beginner,
      ),
      targetMuscles:
          (data['targetMuscles'] as List<dynamic>?)
              ?.map(
                (m) => MuscleGroup.values.firstWhere(
                  (muscle) => muscle.toString() == 'MuscleGroup.$m',
                  orElse: () => MuscleGroup.fullBody,
                ),
              )
              .toList() ??
          [],
      equipment: List<String>.from(data['equipment'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'difficulty': difficulty.toString().split('.').last,
      'targetMuscles': targetMuscles
          .map((m) => m.toString().split('.').last)
          .toList(),
      'equipment': equipment,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFavorite': isFavorite,
    };
  }

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<Exercise>? exercises,
    int? totalDuration,
    int? totalCalories,
    DifficultyLevel? difficulty,
    List<MuscleGroup>? targetMuscles,
    List<String>? equipment,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      totalDuration: totalDuration ?? this.totalDuration,
      totalCalories: totalCalories ?? this.totalCalories,
      difficulty: difficulty ?? this.difficulty,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      equipment: equipment ?? this.equipment,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workout && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Workout(id: $id, name: $name, exercises: ${exercises.length}, duration: $totalDuration min)';
  }
}
