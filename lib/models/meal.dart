import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum MealType { breakfast, lunch, dinner, snack }

enum MealCategory { protein, carbs, vegetables, fruits, dairy, nuts, other }

class Meal {
  final String id;
  final String name;
  final String description;
  final MealType mealType;
  final List<MealCategory> categories;
  final int calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final double fiber; // in grams
  final double sugar; // in grams
  final double sodium; // in mg
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? lastEaten;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.mealType,
    required this.categories,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.ingredients = const [],
    this.instructions = const [],
    this.imageUrl,
    this.prepTime = 0,
    this.cookTime = 0,
    this.servings = 1,
    this.isFavorite = false,
    required this.createdAt,
    this.lastEaten,
  });

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Meal(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      mealType: MealType.values.firstWhere(
        (t) => t.toString() == 'MealType.${data['mealType']}',
        orElse: () => MealType.snack,
      ),
      categories:
          (data['categories'] as List<dynamic>?)
              ?.map(
                (c) => MealCategory.values.firstWhere(
                  (cat) => cat.toString() == 'MealCategory.$c',
                  orElse: () => MealCategory.other,
                ),
              )
              .toList() ??
          [],
      calories: data['calories'] ?? 0,
      protein: (data['protein'] ?? 0.0).toDouble(),
      carbs: (data['carbs'] ?? 0.0).toDouble(),
      fat: (data['fat'] ?? 0.0).toDouble(),
      fiber: (data['fiber'] ?? 0.0).toDouble(),
      sugar: (data['sugar'] ?? 0.0).toDouble(),
      sodium: (data['sodium'] ?? 0.0).toDouble(),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      imageUrl: data['imageUrl'],
      prepTime: data['prepTime'] ?? 0,
      cookTime: data['cookTime'] ?? 0,
      servings: data['servings'] ?? 1,
      isFavorite: data['isFavorite'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastEaten: data['lastEaten'] != null
          ? (data['lastEaten'] as Timestamp).toDate()
          : null,
    );
  }

  factory Meal.fromMap(Map<String, dynamic> data) {
    return Meal(
      id: data['id'] ?? const Uuid().v4(),
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      mealType: MealType.values.firstWhere(
        (t) => t.toString() == 'MealType.${data['mealType']}',
        orElse: () => MealType.snack,
      ),
      categories:
          (data['categories'] as List<dynamic>?)
              ?.map(
                (c) => MealCategory.values.firstWhere(
                  (cat) => cat.toString() == 'MealCategory.$c',
                  orElse: () => MealCategory.other,
                ),
              )
              .toList() ??
          [],
      calories: data['calories'] ?? 0,
      protein: (data['protein'] ?? 0.0).toDouble(),
      carbs: (data['carbs'] ?? 0.0).toDouble(),
      fat: (data['fat'] ?? 0.0).toDouble(),
      fiber: (data['fiber'] ?? 0.0).toDouble(),
      sugar: (data['sugar'] ?? 0.0).toDouble(),
      sodium: (data['sodium'] ?? 0.0).toDouble(),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      imageUrl: data['imageUrl'],
      prepTime: data['prepTime'] ?? 0,
      cookTime: data['cookTime'] ?? 0,
      servings: data['servings'] ?? 1,
      isFavorite: data['isFavorite'] ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              data['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
      lastEaten: data['lastEaten'] != null
          ? (data['lastEaten'] is Timestamp
                ? (data['lastEaten'] as Timestamp).toDate()
                : DateTime.parse(data['lastEaten']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'mealType': mealType.toString().split('.').last,
      'categories': categories
          .map((c) => c.toString().split('.').last)
          .toList(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastEaten': lastEaten != null ? Timestamp.fromDate(lastEaten!) : null,
    };
  }

  Meal copyWith({
    String? id,
    String? name,
    String? description,
    MealType? mealType,
    List<MealCategory>? categories,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    List<String>? ingredients,
    List<String>? instructions,
    String? imageUrl,
    int? prepTime,
    int? cookTime,
    int? servings,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? lastEaten,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mealType: mealType ?? this.mealType,
      categories: categories ?? this.categories,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      lastEaten: lastEaten ?? this.lastEaten,
    );
  }

  // Get total time
  int get totalTime => prepTime + cookTime;

  // Get macro percentages
  double get proteinPercentage {
    final totalMacroCalories = (protein * 4) + (carbs * 4) + (fat * 9);
    return totalMacroCalories > 0
        ? (protein * 4) / totalMacroCalories * 100
        : 0;
  }

  double get carbsPercentage {
    final totalMacroCalories = (protein * 4) + (carbs * 4) + (fat * 9);
    return totalMacroCalories > 0 ? (carbs * 4) / totalMacroCalories * 100 : 0;
  }

  double get fatPercentage {
    final totalMacroCalories = (protein * 4) + (carbs * 4) + (fat * 9);
    return totalMacroCalories > 0 ? (fat * 9) / totalMacroCalories * 100 : 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Meal(id: $id, name: $name, calories: $calories, mealType: $mealType)';
  }
}

class MealPlan {
  final String id;
  final DateTime date;
  final List<Meal> meals;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final DateTime createdAt;

  MealPlan({
    required this.id,
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.createdAt,
  });

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final mealsData = data['meals'] as List<dynamic>? ?? [];

    return MealPlan(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      meals: mealsData.map((mealData) => Meal.fromMap(mealData)).toList(),
      totalCalories: data['totalCalories'] ?? 0,
      totalProtein: (data['totalProtein'] ?? 0.0).toDouble(),
      totalCarbs: (data['totalCarbs'] ?? 0.0).toDouble(),
      totalFat: (data['totalFat'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MealPlan copyWith({
    String? id,
    DateTime? date,
    List<Meal>? meals,
    int? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
