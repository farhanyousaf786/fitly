import 'package:cloud_firestore/cloud_firestore.dart';
import 'meal.dart';
import 'exercise.dart';
import 'mental_health_practice.dart';
import 'reminder.dart';
import 'ui_config.dart';

enum FitnessGoal {
  loseWeight,
  buildMuscle,
  maintainWeight,
  improveEndurance,
  increaseStrength,
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive,
}

enum Gender { male, female, other }

class UserConfig {
  final String? userId;
  final String
  goalType; // "weight_loss", "muscle_gain", "mental_health", "energy", "general_wellness"
  final String goalTitle;
  final String targetDescription;

  // Physical metrics
  final int age;
  final Gender gender;
  final double height; // in cm
  final double weight; // in kg
  final FitnessGoal fitnessGoal;
  final ActivityLevel activityLevel;

  // Personalized Plans
  final Map<String, Meal>? dietPlan;
  final Map<String, List<Exercise>>? exercisePlan;
  final int? waterGoal;
  final Map<String, String>? sleepSchedule;
  final List<MentalHealthPractice>? mentalHealthPractices;
  final List<Reminder> reminders;
  final UIConfig? uiConfig;
  final String motivationalMessage;

  // Preferences & Settings
  final List<String> preferredWorkoutTypes;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final int workoutDaysPerWeek;
  final int workoutMinutesPerSession;
  final bool enableNotifications;
  final bool enableWorkoutReminders;
  final bool enableMealReminders;
  final bool enableHydrationReminders;
  final DateTime? lastUpdated;

  UserConfig({
    this.userId,
    required this.goalType,
    required this.goalTitle,
    required this.targetDescription,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.activityLevel,
    this.dietPlan,
    this.exercisePlan,
    this.waterGoal,
    this.sleepSchedule,
    this.mentalHealthPractices,
    this.reminders = const [],
    this.uiConfig,
    required this.motivationalMessage,
    this.preferredWorkoutTypes = const [],
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.workoutDaysPerWeek = 3,
    this.workoutMinutesPerSession = 30,
    this.enableNotifications = true,
    this.enableWorkoutReminders = true,
    this.enableMealReminders = true,
    this.enableHydrationReminders = true,
    this.lastUpdated,
  });

  factory UserConfig.fromMap(Map<String, dynamic> map) {
    // Helper to parse diet plan
    Map<String, Meal>? parseDietPlan(Map<String, dynamic>? dietMap) {
      if (dietMap == null) return null;
      return dietMap.map((key, value) => MapEntry(key, Meal.fromMap(value)));
    }

    // Helper to parse exercise plan
    Map<String, List<Exercise>>? parseExercisePlan(
      Map<String, dynamic>? exerciseMap,
    ) {
      if (exerciseMap == null) return null;
      return exerciseMap.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => Exercise.fromMap(e)).toList(),
        ),
      );
    }

    return UserConfig(
      userId: map['userId'],
      goalType: map['goalType'] ?? 'general_wellness',
      goalTitle: map['goalTitle'] ?? 'Fitness Goal',
      targetDescription:
          map['targetDescription'] ?? 'Achieve your fitness goals',
      age: map['age'] ?? 25,
      gender: Gender.values.firstWhere(
        (g) => g.toString() == 'Gender.${map['gender']}',
        orElse: () => Gender.other,
      ),
      height: (map['height'] ?? 170.0).toDouble(),
      weight: (map['weight'] ?? 70.0).toDouble(),
      fitnessGoal: FitnessGoal.values.firstWhere(
        (g) => g.toString() == 'FitnessGoal.${map['fitnessGoal']}',
        orElse: () => FitnessGoal.maintainWeight,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (a) => a.toString() == 'ActivityLevel.${map['activityLevel']}',
        orElse: () => ActivityLevel.moderatelyActive,
      ),
      dietPlan: parseDietPlan(map['dietPlan']),
      exercisePlan: parseExercisePlan(map['exercisePlan']),
      waterGoal: map['waterGoal'],
      sleepSchedule: map['sleepSchedule'] != null
          ? Map<String, String>.from(map['sleepSchedule'])
          : null,
      mentalHealthPractices: map['mentalHealthPractices'] != null
          ? (map['mentalHealthPractices'] as List)
                .map((p) => MentalHealthPractice.fromMap(p))
                .toList()
          : null,
      reminders: map['reminders'] != null
          ? (map['reminders'] as List).map((r) => Reminder.fromMap(r)).toList()
          : [],
      uiConfig: map['uiConfig'] != null
          ? UIConfig.fromMap(map['uiConfig'])
          : null,
      motivationalMessage: map['motivationalMessage'] ?? 'Stay active!',
      preferredWorkoutTypes: List<String>.from(
        map['preferredWorkoutTypes'] ?? [],
      ),
      dietaryRestrictions: List<String>.from(map['dietaryRestrictions'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      workoutDaysPerWeek: map['workoutDaysPerWeek'] ?? 3,
      workoutMinutesPerSession: map['workoutMinutesPerSession'] ?? 30,
      enableNotifications: map['enableNotifications'] ?? true,
      enableWorkoutReminders: map['enableWorkoutReminders'] ?? true,
      enableMealReminders: map['enableMealReminders'] ?? true,
      enableHydrationReminders: map['enableHydrationReminders'] ?? true,
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'goalType': goalType,
      'goalTitle': goalTitle,
      'targetDescription': targetDescription,
      'age': age,
      'gender': gender.toString().split('.').last,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal.toString().split('.').last,
      'activityLevel': activityLevel.toString().split('.').last,
      'dietPlan': dietPlan?.map((key, value) => MapEntry(key, value.toMap())),
      'exercisePlan': exercisePlan?.map(
        (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()),
      ),
      'waterGoal': waterGoal,
      'sleepSchedule': sleepSchedule,
      'mentalHealthPractices': mentalHealthPractices
          ?.map((p) => p.toMap())
          .toList(),
      'reminders': reminders.map((r) => r.toMap()).toList(),
      'uiConfig': uiConfig?.toMap(),
      'motivationalMessage': motivationalMessage,
      'preferredWorkoutTypes': preferredWorkoutTypes,
      'dietaryRestrictions': dietaryRestrictions,
      'allergies': allergies,
      'workoutDaysPerWeek': workoutDaysPerWeek,
      'workoutMinutesPerSession': workoutMinutesPerSession,
      'enableNotifications': enableNotifications,
      'enableWorkoutReminders': enableWorkoutReminders,
      'enableMealReminders': enableMealReminders,
      'enableHydrationReminders': enableHydrationReminders,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  UserConfig copyWith({
    String? userId,
    String? goalType,
    String? goalTitle,
    String? targetDescription,
    int? age,
    Gender? gender,
    double? height,
    double? weight,
    FitnessGoal? fitnessGoal,
    ActivityLevel? activityLevel,
    Map<String, Meal>? dietPlan,
    Map<String, List<Exercise>>? exercisePlan,
    int? waterGoal,
    Map<String, String>? sleepSchedule,
    List<MentalHealthPractice>? mentalHealthPractices,
    List<Reminder>? reminders,
    UIConfig? uiConfig,
    String? motivationalMessage,
    List<String>? preferredWorkoutTypes,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    int? workoutDaysPerWeek,
    int? workoutMinutesPerSession,
    bool? enableNotifications,
    bool? enableWorkoutReminders,
    bool? enableMealReminders,
    bool? enableHydrationReminders,
    DateTime? lastUpdated,
  }) {
    return UserConfig(
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      goalTitle: goalTitle ?? this.goalTitle,
      targetDescription: targetDescription ?? this.targetDescription,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietPlan: dietPlan ?? this.dietPlan,
      exercisePlan: exercisePlan ?? this.exercisePlan,
      waterGoal: waterGoal ?? this.waterGoal,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      mentalHealthPractices:
          mentalHealthPractices ?? this.mentalHealthPractices,
      reminders: reminders ?? this.reminders,
      uiConfig: uiConfig ?? this.uiConfig,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
      preferredWorkoutTypes:
          preferredWorkoutTypes ?? this.preferredWorkoutTypes,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      workoutMinutesPerSession:
          workoutMinutesPerSession ?? this.workoutMinutesPerSession,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableWorkoutReminders:
          enableWorkoutReminders ?? this.enableWorkoutReminders,
      enableMealReminders: enableMealReminders ?? this.enableMealReminders,
      enableHydrationReminders:
          enableHydrationReminders ?? this.enableHydrationReminders,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Calculate BMI
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
  double get bmr {
    switch (gender) {
      case Gender.male:
        return 10 * weight + 6.25 * height - 5 * age + 5;
      case Gender.female:
        return 10 * weight + 6.25 * height - 5 * age - 161;
      case Gender.other:
        return 10 * weight + 6.25 * height - 5 * age; // Average
    }
  }

  // Calculate daily calorie needs based on activity level
  double get dailyCalorieNeeds {
    final activityMultiplier = switch (activityLevel) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
      ActivityLevel.extremelyActive => 1.9,
    };

    return bmr * activityMultiplier;
  }

  // Adjust calories based on fitness goal
  double get targetCalories {
    switch (fitnessGoal) {
      case FitnessGoal.loseWeight:
        return dailyCalorieNeeds * 0.85; // 15% deficit
      case FitnessGoal.buildMuscle:
        return dailyCalorieNeeds * 1.15; // 15% surplus
      case FitnessGoal.maintainWeight:
      case FitnessGoal.improveEndurance:
      case FitnessGoal.increaseStrength:
        return dailyCalorieNeeds;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserConfig &&
        other.age == age &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        other.fitnessGoal == fitnessGoal &&
        other.activityLevel == activityLevel;
  }

  @override
  int get hashCode {
    return Object.hash(age, gender, height, weight, fitnessGoal, activityLevel);
  }

  @override
  String toString() {
    return 'UserConfig(goalTitle: $goalTitle, goalType: $goalType)';
  }
}
