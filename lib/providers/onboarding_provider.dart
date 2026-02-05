import 'package:flutter/foundation.dart';
import '../models/user_config.dart';
import '../providers/user_provider.dart';
import '../services/api/ai_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final AiService _aiService;

  OnboardingProvider({
    required UserProvider userProvider,
    required AiService aiService,
  }) : _userProvider = userProvider,
       _aiService = aiService;

  // Onboarding State
  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _onboardingData = {};

  // Temporary data during onboarding
  String? _firstName;
  String? _lastName;
  int? _age;
  Gender? _gender;
  double? _height;
  double? _weight;
  FitnessGoal? _fitnessGoal;
  ActivityLevel? _activityLevel;
  List<String> _preferredWorkoutTypes = [];
  List<String> _dietaryRestrictions = [];
  List<String> _allergies = [];
  int _workoutDaysPerWeek = 3;
  int _workoutMinutesPerSession = 30;
  bool _enableNotifications = true;
  bool _enableWorkoutReminders = true;
  bool _enableMealReminders = true;
  bool _enableHydrationReminders = true;

  // Temporary user config (before signup)
  UserConfig? _tempUserConfig;

  // Getters
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get progress => (_currentStep + 1) / _totalSteps;
  UserConfig? get userConfig => _tempUserConfig;

  // Step getters
  bool get isPersonalInfoStep => _currentStep == 0;
  bool get isPhysicalMetricsStep => _currentStep == 1;
  bool get isFitnessGoalsStep => _currentStep == 2;
  bool get isPreferencesStep => _currentStep == 3;
  bool get isNotificationStep => _currentStep == 4;

  // Data getters
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  int? get age => _age;
  Gender? get gender => _gender;
  double? get height => _height;
  double? get weight => _weight;
  FitnessGoal? get fitnessGoal => _fitnessGoal;
  ActivityLevel? get activityLevel => _activityLevel;
  List<String> get preferredWorkoutTypes => _preferredWorkoutTypes;
  List<String> get dietaryRestrictions => _dietaryRestrictions;
  List<String> get allergies => _allergies;
  int get workoutDaysPerWeek => _workoutDaysPerWeek;
  int get workoutMinutesPerSession => _workoutMinutesPerSession;
  bool get enableNotifications => _enableNotifications;
  bool get enableWorkoutReminders => _enableWorkoutReminders;
  bool get enableMealReminders => _enableMealReminders;
  bool get enableHydrationReminders => _enableHydrationReminders;

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

  // Navigation methods
  void nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // Data setters for each step
  void updatePersonalInfo({String? firstName, String? lastName}) {
    _firstName = firstName;
    _lastName = lastName;
    notifyListeners();
  }

  void updatePhysicalMetrics({
    int? age,
    Gender? gender,
    double? height,
    double? weight,
  }) {
    _age = age;
    _gender = gender;
    _height = height;
    _weight = weight;
    notifyListeners();
  }

  void updateFitnessGoals({
    FitnessGoal? fitnessGoal,
    ActivityLevel? activityLevel,
  }) {
    _fitnessGoal = fitnessGoal;
    _activityLevel = activityLevel;
    notifyListeners();
  }

  void updatePreferences({
    List<String>? preferredWorkoutTypes,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    int? workoutDaysPerWeek,
    int? workoutMinutesPerSession,
  }) {
    _preferredWorkoutTypes = preferredWorkoutTypes ?? _preferredWorkoutTypes;
    _dietaryRestrictions = dietaryRestrictions ?? _dietaryRestrictions;
    _allergies = allergies ?? _allergies;
    _workoutDaysPerWeek = workoutDaysPerWeek ?? _workoutDaysPerWeek;
    _workoutMinutesPerSession =
        workoutMinutesPerSession ?? _workoutMinutesPerSession;
    notifyListeners();
  }

  void updateNotifications({
    bool? enableNotifications,
    bool? enableWorkoutReminders,
    bool? enableMealReminders,
    bool? enableHydrationReminders,
  }) {
    _enableNotifications = enableNotifications ?? _enableNotifications;
    _enableWorkoutReminders = enableWorkoutReminders ?? _enableWorkoutReminders;
    _enableMealReminders = enableMealReminders ?? _enableMealReminders;
    _enableHydrationReminders =
        enableHydrationReminders ?? _enableHydrationReminders;
    notifyListeners();
  }

  // Validation methods for each step
  bool validatePersonalInfoStep() {
    return _firstName != null &&
        _firstName!.isNotEmpty &&
        _lastName != null &&
        _lastName!.isNotEmpty;
  }

  bool validatePhysicalMetricsStep() {
    return _age != null &&
        _age! >= 10 &&
        _age! <= 120 &&
        _gender != null &&
        _height != null &&
        _height! >= 50 &&
        _height! <= 300 &&
        _weight != null &&
        _weight! >= 20 &&
        _weight! <= 500;
  }

  bool validateFitnessGoalsStep() {
    return _fitnessGoal != null && _activityLevel != null;
  }

  bool validatePreferencesStep() {
    return _workoutDaysPerWeek >= 1 &&
        _workoutDaysPerWeek <= 7 &&
        _workoutMinutesPerSession >= 10 &&
        _workoutMinutesPerSession <= 180;
  }

  bool validateNotificationStep() {
    return true; // This step is always valid
  }

  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return validatePersonalInfoStep();
      case 1:
        return validatePhysicalMetricsStep();
      case 2:
        return validateFitnessGoalsStep();
      case 3:
        return validatePreferencesStep();
      case 4:
        return validateNotificationStep();
      default:
        return false;
    }
  }

  // Get AI recommendations based on current data
  Future<Map<String, dynamic>> getAiRecommendations() async {
    if (_age == null || _gender == null || _height == null || _weight == null) {
      return {};
    }

    try {
      _setLoading(true);
      _clearError();

      final recommendations = await _aiService.getFitnessRecommendations(
        age: _age!,
        gender: _gender!.toString().split('.').last,
        height: _height!,
        weight: _weight!,
        fitnessGoal: _fitnessGoal?.toString().split('.').last,
        activityLevel: _activityLevel?.toString().split('.').last,
      );

      return recommendations;
    } catch (e) {
      _setError('Failed to get AI recommendations: ${e.toString()}');
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // Complete onboarding and create user config
  Future<bool> completeOnboarding() async {
    if (!validateCurrentStep()) {
      _setError('Please complete the current step before proceeding');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Create user config
      final userConfig = UserConfig(
        age: _age!,
        gender: _gender!,
        height: _height!,
        weight: _weight!,
        fitnessGoal: _fitnessGoal!,
        activityLevel: _activityLevel!,
        preferredWorkoutTypes: _preferredWorkoutTypes,
        dietaryRestrictions: _dietaryRestrictions,
        allergies: _allergies,
        workoutDaysPerWeek: _workoutDaysPerWeek,
        workoutMinutesPerSession: _workoutMinutesPerSession,
        enableNotifications: _enableNotifications,
        enableWorkoutReminders: _enableWorkoutReminders,
        enableMealReminders: _enableMealReminders,
        enableHydrationReminders: _enableHydrationReminders,
        lastUpdated: DateTime.now(),
      );

      // Update user profile with names
      if (_firstName != null && _lastName != null) {
        await _userProvider.updateBasicInfo(
          firstName: _firstName,
          lastName: _lastName,
        );
      }

      // Create user config
      final success = await _userProvider.createUserConfig(userConfig);

      if (success) {
        // Reset onboarding state
        _resetOnboarding();
      }

      return success;
    } catch (e) {
      _setError('Failed to complete onboarding: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset onboarding
  void _resetOnboarding() {
    _currentStep = 0;
    _firstName = null;
    _lastName = null;
    _age = null;
    _gender = null;
    _height = null;
    _weight = null;
    _fitnessGoal = null;
    _activityLevel = null;
    _preferredWorkoutTypes = [];
    _dietaryRestrictions = [];
    _allergies = [];
    _workoutDaysPerWeek = 3;
    _workoutMinutesPerSession = 30;
    _enableNotifications = true;
    _enableWorkoutReminders = true;
    _enableMealReminders = true;
    _enableHydrationReminders = true;
    _clearError();
    notifyListeners();
  }

  void restartOnboarding() {
    _resetOnboarding();
  }

  // Save temporary config (before signup)
  void saveTempConfig(UserConfig config) {
    _tempUserConfig = config;
    notifyListeners();
  }

  // Clear temporary config
  void clearTempConfig() {
    _tempUserConfig = null;
    notifyListeners();
  }

  // Get step title
  String getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Physical Metrics';
      case 2:
        return 'Fitness Goals';
      case 3:
        return 'Preferences';
      case 4:
        return 'Notifications';
      default:
        return '';
    }
  }

  // Get step description
  String getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Tell us about yourself';
      case 1:
        return 'Your current physical measurements';
      case 2:
        return 'What do you want to achieve?';
      case 3:
        return 'Customize your experience';
      case 4:
        return 'Stay on track with reminders';
      default:
        return '';
    }
  }

  // Check if can proceed to next step
  bool get canProceed => validateCurrentStep();

  // Check if can go to previous step
  bool get canGoBack => _currentStep > 0;

  // Check if is last step
  bool get isLastStep => _currentStep == _totalSteps - 1;

  void clearError() {
    _clearError();
  }
}
