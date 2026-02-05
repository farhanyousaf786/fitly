import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../models/user_config.dart';
import '../../models/exercise.dart';
import '../../models/meal.dart';
import '../../models/reminder.dart';
import '../../models/workout.dart';
import '../../models/meal_plan.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection(AppConstants.usersCollection);
  final CollectionReference _workoutsCollection = FirebaseFirestore.instance
      .collection(AppConstants.workoutsCollection);
  final CollectionReference _mealsCollection = FirebaseFirestore.instance
      .collection(AppConstants.mealsCollection);

  // User Profile Methods
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: ${e.toString()}';
    }
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      await _usersCollection.doc(userProfile.id).set(userProfile.toMap());
    } catch (e) {
      throw 'Failed to create user profile: ${e.toString()}';
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      await _usersCollection.doc(userProfile.id).update(userProfile.toMap());
    } catch (e) {
      throw 'Failed to update user profile: ${e.toString()}';
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw 'Failed to delete user profile: ${e.toString()}';
    }
  }

  // User Config Methods
  Future<UserConfig?> getUserConfig(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['config'] != null
            ? UserConfig.fromMap(data!['config'])
            : null;
      }
      return null;
    } catch (e) {
      throw 'Failed to get user config: ${e.toString()}';
    }
  }

  Future<void> createUserConfig(String userId, UserConfig config) async {
    try {
      await _usersCollection.doc(userId).update({'config': config.toMap()});
    } catch (e) {
      throw 'Failed to create user config: ${e.toString()}';
    }
  }

  Future<void> updateUserConfig(String userId, UserConfig config) async {
    try {
      await _usersCollection.doc(userId).update({'config': config.toMap()});
    } catch (e) {
      throw 'Failed to update user config: ${e.toString()}';
    }
  }

  // Exercise Methods
  Future<List<Exercise>> getExercises({
    ExerciseType? type,
    DifficultyLevel? difficulty,
    MuscleGroup? muscleGroup,
    int limit = 20,
  }) async {
    try {
      Query query = _workoutsCollection
          .where('type', isEqualTo: type?.toString().split('.').last)
          .limit(limit);

      if (difficulty != null) {
        query = query.where(
          'difficulty',
          isEqualTo: difficulty.toString().split('.').last,
        );
      }

      if (muscleGroup != null) {
        query = query.where(
          'primaryMuscles',
          arrayContains: muscleGroup.toString().split('.').last,
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Exercise.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get exercises: ${e.toString()}';
    }
  }

  Future<Exercise?> getExercise(String exerciseId) async {
    try {
      final doc = await _workoutsCollection.doc(exerciseId).get();
      if (doc.exists) {
        return Exercise.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get exercise: ${e.toString()}';
    }
  }

  Future<void> saveExercise(String userId, Exercise exercise) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('savedExercises')
          .doc(exercise.id)
          .set(exercise.toMap());
    } catch (e) {
      throw 'Failed to save exercise: ${e.toString()}';
    }
  }

  Future<List<Exercise>> getSavedExercises(String userId) async {
    try {
      final querySnapshot = await _usersCollection
          .doc(userId)
          .collection('savedExercises')
          .get();
      return querySnapshot.docs
          .map((doc) => Exercise.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get saved exercises: ${e.toString()}';
    }
  }

  Future<void> removeSavedExercise(String userId, String exerciseId) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('savedExercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw 'Failed to remove saved exercise: ${e.toString()}';
    }
  }

  // Workout Methods
  Future<void> saveWorkout(String userId, Workout workout) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('workouts')
          .doc(workout.id)
          .set(workout.toMap());
    } catch (e) {
      throw 'Failed to save workout: ${e.toString()}';
    }
  }

  Future<List<Workout>> getWorkouts(String userId) async {
    try {
      final querySnapshot = await _usersCollection
          .doc(userId)
          .collection('workouts')
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Workout.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get workouts: ${e.toString()}';
    }
  }

  Future<void> deleteWorkout(String userId, String workoutId) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('workouts')
          .doc(workoutId)
          .delete();
    } catch (e) {
      throw 'Failed to delete workout: ${e.toString()}';
    }
  }

  // Meal Methods
  Future<List<Meal>> getMeals({
    MealType? type,
    MealCategory? category,
    int limit = 20,
  }) async {
    try {
      Query query = _mealsCollection.limit(limit);

      if (type != null) {
        query = query.where(
          'mealType',
          isEqualTo: type.toString().split('.').last,
        );
      }

      if (category != null) {
        query = query.where(
          'categories',
          arrayContains: category.toString().split('.').last,
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Failed to get meals: ${e.toString()}';
    }
  }

  Future<Meal?> getMeal(String mealId) async {
    try {
      final doc = await _mealsCollection.doc(mealId).get();
      if (doc.exists) {
        return Meal.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get meal: ${e.toString()}';
    }
  }

  Future<void> saveMeal(String userId, Meal meal) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('savedMeals')
          .doc(meal.id)
          .set(meal.toMap());
    } catch (e) {
      throw 'Failed to save meal: ${e.toString()}';
    }
  }

  Future<List<Meal>> getSavedMeals(String userId) async {
    try {
      final querySnapshot = await _usersCollection
          .doc(userId)
          .collection('savedMeals')
          .get();
      return querySnapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Failed to get saved meals: ${e.toString()}';
    }
  }

  Future<void> removeSavedMeal(String userId, String mealId) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('savedMeals')
          .doc(mealId)
          .delete();
    } catch (e) {
      throw 'Failed to remove saved meal: ${e.toString()}';
    }
  }

  Future<void> saveMealPlan(String userId, MealPlan mealPlan) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('mealPlans')
          .doc(mealPlan.id)
          .set(mealPlan.toMap());
    } catch (e) {
      throw 'Failed to save meal plan: ${e.toString()}';
    }
  }

  Future<List<MealPlan>> getMealPlans(String userId) async {
    try {
      final querySnapshot = await _usersCollection
          .doc(userId)
          .collection('mealPlans')
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get meal plans: ${e.toString()}';
    }
  }

  // Reminder Methods
  Future<void> createReminder(String userId, Reminder reminder) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('reminders')
          .doc(reminder.id)
          .set(reminder.toMap());
    } catch (e) {
      throw 'Failed to create reminder: ${e.toString()}';
    }
  }

  Future<List<Reminder>> getReminders(String userId) async {
    try {
      final querySnapshot = await _usersCollection
          .doc(userId)
          .collection('reminders')
          .orderBy('time')
          .get();
      return querySnapshot.docs
          .map((doc) => Reminder.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get reminders: ${e.toString()}';
    }
  }

  Future<void> updateReminder(String userId, Reminder reminder) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('reminders')
          .doc(reminder.id)
          .update(reminder.toMap());
    } catch (e) {
      throw 'Failed to update reminder: ${e.toString()}';
    }
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('reminders')
          .doc(reminderId)
          .delete();
    } catch (e) {
      throw 'Failed to delete reminder: ${e.toString()}';
    }
  }

  // Activity Tracking Methods
  Future<void> logWorkout(
    String userId,
    Map<String, dynamic> workoutData,
  ) async {
    try {
      await _usersCollection.doc(userId).collection('workoutLogs').add({
        ...workoutData,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to log workout: ${e.toString()}';
    }
  }

  Future<void> logMeal(String userId, Map<String, dynamic> mealData) async {
    try {
      await _usersCollection.doc(userId).collection('mealLogs').add({
        ...mealData,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to log meal: ${e.toString()}';
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _usersCollection
          .doc(userId)
          .collection('workoutLogs')
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw 'Failed to get workout logs: ${e.toString()}';
    }
  }

  Future<List<Map<String, dynamic>>> getMealLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _usersCollection
          .doc(userId)
          .collection('mealLogs')
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw 'Failed to get meal logs: ${e.toString()}';
    }
  }

  // Settings Methods
  Future<void> saveNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _usersCollection.doc(userId).update({
        'notificationSettings': settings,
      });
    } catch (e) {
      throw 'Failed to save notification settings: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>?> getNotificationSettings(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['notificationSettings'];
      }
      return null;
    } catch (e) {
      throw 'Failed to get notification settings: ${e.toString()}';
    }
  }

  // Utility Methods
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check username availability: ${e.toString()}';
    }
  }

  Future<void> updateLastActive(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastActive': Timestamp.now(),
      });
    } catch (e) {
      // Don't throw error for last active updates
    }
  }

  Stream<UserProfile?> userProfileStream(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  Stream<List<Reminder>> remindersStream(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('reminders')
        .orderBy('time')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reminder.fromFirestore(doc)).toList(),
        );
  }
}
