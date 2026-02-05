import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/user_config.dart';
import '../services/firebase/firestore_service.dart';
import '../services/local/shared_prefs_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  UserProvider({
    required FirestoreService firestoreService,
    required SharedPrefsService sharedPrefsService,
  }) : _firestoreService = firestoreService;

  // State
  UserProfile? _userProfile;
  UserConfig? _userConfig;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get userProfile => _userProfile;
  UserConfig? get userConfig => _userConfig;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _userProfile != null;
  bool get hasConfig => _userConfig != null;
  bool get isOnboardingComplete => _userConfig != null;

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // User Profile Methods
  Future<void> loadUserProfile(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final userProfile = await _firestoreService.getUserProfile(userId);
      _userProfile = userProfile;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile(UserProfile userProfile) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedProfile = userProfile.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to update user profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfileImage(String imageUrl) async {
    if (_userProfile == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedProfile = _userProfile!.copyWith(
        profileImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to update profile image: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // User Config Methods
  Future<void> loadUserConfig(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final userConfig = await _firestoreService.getUserConfig(userId);
      _userConfig = userConfig;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user config: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createUserConfig(UserConfig config) async {
    if (_userProfile == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final configWithTimestamp = config.copyWith(lastUpdated: DateTime.now());

      await _firestoreService.createUserConfig(
        _userProfile!.id,
        configWithTimestamp,
      );
      _userConfig = configWithTimestamp;

      // Update user profile with config
      final updatedProfile = _userProfile!.copyWith(
        config: configWithTimestamp,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create user config: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserConfig(UserConfig config) async {
    if (_userProfile == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final configWithTimestamp = config.copyWith(lastUpdated: DateTime.now());

      await _firestoreService.updateUserConfig(
        _userProfile!.id,
        configWithTimestamp,
      );
      _userConfig = configWithTimestamp;

      // Update user profile with config
      final updatedProfile = _userProfile!.copyWith(
        config: configWithTimestamp,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update user config: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBasicInfo({
    String? firstName,
    String? lastName,
    String? username,
  }) async {
    if (_userProfile == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedProfile = _userProfile!.copyWith(
        firstName: firstName ?? _userProfile!.firstName,
        lastName: lastName ?? _userProfile!.lastName,
        username: username ?? _userProfile!.username,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to update basic info: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateFitnessProfile({
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
  }) async {
    if (_userConfig == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedConfig = _userConfig!.copyWith(
        age: age ?? _userConfig!.age,
        gender: gender != null
            ? Gender.values.firstWhere(
                (g) => g.toString() == 'Gender.$gender',
                orElse: () => Gender.other,
              )
            : _userConfig!.gender,
        height: height ?? _userConfig!.height,
        weight: weight ?? _userConfig!.weight,
        fitnessGoal: fitnessGoal != null
            ? FitnessGoal.values.firstWhere(
                (g) => g.toString() == 'FitnessGoal.$fitnessGoal',
                orElse: () => FitnessGoal.maintainWeight,
              )
            : _userConfig!.fitnessGoal,
        activityLevel: activityLevel != null
            ? ActivityLevel.values.firstWhere(
                (a) => a.toString() == 'ActivityLevel.$activityLevel',
                orElse: () => ActivityLevel.moderatelyActive,
              )
            : _userConfig!.activityLevel,
        lastUpdated: DateTime.now(),
      );

      return await updateUserConfig(updatedConfig);
    } catch (e) {
      _setError('Failed to update fitness profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePreferences({
    List<String>? preferredWorkoutTypes,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    int? workoutDaysPerWeek,
    int? workoutMinutesPerSession,
    bool? enableNotifications,
    bool? enableWorkoutReminders,
    bool? enableMealReminders,
    bool? enableHydrationReminders,
  }) async {
    if (_userConfig == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedConfig = _userConfig!.copyWith(
        preferredWorkoutTypes:
            preferredWorkoutTypes ?? _userConfig!.preferredWorkoutTypes,
        dietaryRestrictions:
            dietaryRestrictions ?? _userConfig!.dietaryRestrictions,
        allergies: allergies ?? _userConfig!.allergies,
        workoutDaysPerWeek:
            workoutDaysPerWeek ?? _userConfig!.workoutDaysPerWeek,
        workoutMinutesPerSession:
            workoutMinutesPerSession ?? _userConfig!.workoutMinutesPerSession,
        enableNotifications:
            enableNotifications ?? _userConfig!.enableNotifications,
        enableWorkoutReminders:
            enableWorkoutReminders ?? _userConfig!.enableWorkoutReminders,
        enableMealReminders:
            enableMealReminders ?? _userConfig!.enableMealReminders,
        enableHydrationReminders:
            enableHydrationReminders ?? _userConfig!.enableHydrationReminders,
        lastUpdated: DateTime.now(),
      );

      return await updateUserConfig(updatedConfig);
    } catch (e) {
      _setError('Failed to update preferences: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utility Methods
  void clearError() {
    _clearError();
  }

  void clearUserData() {
    _userProfile = null;
    _userConfig = null;
    _clearError();
    notifyListeners();
  }

  // Getters for computed properties
  String? get fullName => _userProfile?.fullName;
  String? get username => _userProfile?.username;
  String? get email => _userProfile?.email;
  String? get profileImageUrl => _userProfile?.profileImageUrl;

  // Fitness metrics
  double? get bmi => _userConfig?.bmi;
  String? get bmiCategory => _userConfig?.bmiCategory;
  double? get bmr => _userConfig?.bmr;
  double? get dailyCalorieNeeds => _userConfig?.dailyCalorieNeeds;
  double? get targetCalories => _userConfig?.targetCalories;

  // Check if user has completed onboarding
  bool get hasCompletedOnboarding {
    return _userConfig != null;
  }

  // Get user stats
  Map<String, dynamic> getUserStats() {
    if (_userConfig == null) return {};

    return {
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'bmr': bmr,
      'dailyCalorieNeeds': dailyCalorieNeeds,
      'targetCalories': targetCalories,
      'fitnessGoal': _userConfig!.fitnessGoal.toString().split('.').last,
      'activityLevel': _userConfig!.activityLevel.toString().split('.').last,
      'workoutDaysPerWeek': _userConfig!.workoutDaysPerWeek,
      'workoutMinutesPerSession': _userConfig!.workoutMinutesPerSession,
    };
  }
}
