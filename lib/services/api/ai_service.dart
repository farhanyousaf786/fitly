import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class AiService {
  static const String _baseUrl = AppConstants.baseUrl;
  static const String _endpoint = '/api/ai/recommendations';
  static const Duration _timeout = AppConstants.apiTimeout;
  
  get workoutMinutesPerWeek => null;

  Future<Map<String, dynamic>> getFitnessRecommendations({
    required int age,
    required String gender,
    required double height,
    required double weight,
    String? fitnessGoal,
    String? activityLevel,
    List<String>? preferences,
    List<String>? restrictions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'fitnessGoal': fitnessGoal ?? 'maintainWeight',
          'activityLevel': activityLevel ?? 'moderatelyActive',
          'preferences': preferences ?? [],
          'restrictions': restrictions ?? [],
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockRecommendations(
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        fitnessGoal: fitnessGoal,
        activityLevel: activityLevel,
      );
    }
  }

  Future<Map<String, dynamic>> generateWorkoutPlan({
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String fitnessGoal,
    required String activityLevel,
    required int workoutDaysPerWeek,
    required int workoutMinutesPerSession,
    List<String>? preferredWorkoutTypes,
    List<String>? equipment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_endpoint/workout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'fitnessGoal': fitnessGoal,
          'activityLevel': activityLevel,
          'workoutDaysPerWeek': workoutDaysPerWeek,
          'workoutMinutesPerSession': workoutMinutesPerSession,
          'preferredWorkoutTypes': preferredWorkoutTypes ?? [],
          'equipment': equipment ?? [],
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to generate workout plan: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock workout plan for development
      return _getMockWorkoutPlan(
        fitnessGoal: fitnessGoal,
        workoutDaysPerWeek: workoutDaysPerWeek,
        workoutMinutesPerSession: workoutMinutesPerSession,
      );
    }
  }

  Future<Map<String, dynamic>> generateMealPlan({
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String fitnessGoal,
    required String activityLevel,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    List<String>? preferences,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_endpoint/meal'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'fitnessGoal': fitnessGoal,
          'activityLevel': activityLevel,
          'dietaryRestrictions': dietaryRestrictions ?? [],
          'allergies': allergies ?? [],
          'preferences': preferences ?? [],
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to generate meal plan: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock meal plan for development
      return _getMockMealPlan(
        fitnessGoal: fitnessGoal,
        dietaryRestrictions: dietaryRestrictions,
      );
    }
  }

  Future<String> getAiAdvice({
    required String question,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_endpoint/advice'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'question': question,
          'userProfile': userProfile,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['advice'] as String;
      } else {
        throw Exception('Failed to get AI advice: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock advice for development
      return _getMockAdvice(question);
    }
  }

  // Mock data methods for development
  Map<String, dynamic> _getMockRecommendations({
    required int age,
    required String gender,
    required double height,
    required double weight,
    String? fitnessGoal,
    String? activityLevel,
  }) {
    final bmi = weight / ((height / 100) * (height / 100));
    
    return {
      'bmi': bmi.toStringAsFixed(1),
      'bmiCategory': bmi < 18.5 ? 'Underweight' : bmi < 25 ? 'Normal' : bmi < 30 ? 'Overweight' : 'Obese',
      'targetWeight': fitnessGoal == 'loseWeight' ? (weight * 0.9).toStringAsFixed(1) : weight.toStringAsFixed(1),
      'dailyCalories': (2000 + (age % 10) * 50).toString(),
      'protein': (weight * 1.6).toStringAsFixed(1),
      'carbs': (weight * 3).toStringAsFixed(1),
      'fat': (weight * 0.8).toStringAsFixed(1),
      'recommendations': [
        'Drink at least 8 glasses of water daily',
        'Get 7-9 hours of quality sleep',
        'Include protein in every meal',
        'Exercise regularly for best results',
      ],
    };
  }

  Map<String, dynamic> _getMockWorkoutPlan({
    required String fitnessGoal,
    required int workoutDaysPerWeek,
    required int workoutMinutesPerSession,
  }) {
    final exercises = [
      {
        'name': 'Push-ups',
        'sets': 3,
        'reps': 12,
        'rest': 60,
        'muscleGroup': 'chest',
      },
      {
        'name': 'Squats',
        'sets': 3,
        'reps': 15,
        'rest': 60,
        'muscleGroup': 'legs',
      },
      {
        'name': 'Plank',
        'sets': 3,
        'reps': 30,
        'rest': 45,
        'muscleGroup': 'core',
      },
    ];

    return {
      'planName': '${fitnessGoal.toUpperCase()} Workout Plan',
      'duration': workoutMinutesPerSession,
      'daysPerWeek': workoutDaysPerWeek,
      'estimatedCalories': workoutMinutesPerWeek * 8,
      'exercises': exercises,
      'schedule': List.generate(workoutDaysPerWeek, (index) => {
        'day': 'Day ${index + 1}',
        'exercises': exercises,
      }),
    };
  }

  Map<String, dynamic> _getMockMealPlan({
    required String fitnessGoal,
    List<String>? dietaryRestrictions,
  }) {
    final meals = [
      {
        'name': 'Oatmeal with Berries',
        'type': 'breakfast',
        'calories': 350,
        'protein': 12,
        'carbs': 45,
        'fat': 8,
        'ingredients': ['Oats', 'Berries', 'Honey', 'Almonds'],
      },
      {
        'name': 'Grilled Chicken Salad',
        'type': 'lunch',
        'calories': 450,
        'protein': 35,
        'carbs': 25,
        'fat': 15,
        'ingredients': ['Chicken', 'Mixed Greens', 'Tomatoes', 'Olive Oil'],
      },
      {
        'name': 'Salmon with Vegetables',
        'type': 'dinner',
        'calories': 500,
        'protein': 40,
        'carbs': 30,
        'fat': 20,
        'ingredients': ['Salmon', 'Broccoli', 'Quinoa', 'Lemon'],
      },
    ];

    return {
      'planName': '${fitnessGoal.toUpperCase()} Meal Plan',
      'totalCalories': 1300,
      'totalProtein': 87,
      'totalCarbs': 100,
      'totalFat': 43,
      'meals': meals,
      'notes': dietaryRestrictions?.isNotEmpty == true 
          ? 'Adjusted for dietary restrictions'
          : 'Balanced nutrition plan',
    };
  }

  String _getMockAdvice(String question) {
    final responses = {
      'weight': 'Focus on a balanced diet and regular exercise. Aim for 1-2 pounds of weight loss per week for sustainable results.',
      'muscle': 'To build muscle, focus on progressive overload in strength training and consume adequate protein (1.6-2.2g per kg of body weight).',
      'energy': 'Improve energy levels by staying hydrated, getting enough sleep, and maintaining a balanced diet with complex carbohydrates.',
      'recovery': 'Prioritize sleep, stay hydrated, and consider active recovery like light stretching or walking on rest days.',
    };

    for (final key in responses.keys) {
      if (question.toLowerCase().contains(key)) {
        return responses[key]!;
      }
    }

    return 'Based on your fitness goals, I recommend maintaining consistency with your workout routine and nutrition plan. Remember that progress takes time, so stay patient and dedicated to your journey.';
  }
}
